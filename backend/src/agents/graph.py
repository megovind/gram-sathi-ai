"""
GramSathi LangGraph agent graph.

Flow:
  START → classify → (conditional) → health_advice
                                    → nearby_facilities
                                    → health_and_nearby
                                    → shops
                       each → END

classify
  Single Bedrock call using the CLASSIFIER_SYSTEM prompt (prompts.py).
  Returns structured JSON: {intent, kind, location}.
  No regex — works for any Indian language, dialect, or colloquial phrasing.

health_advice
  Bedrock chat with HEALTH_ADVISOR_EXTRA system prompt + conversation history.

health_and_nearby
  Bedrock chat with HEALTH_AND_NEARBY_EXTRA prompt for the health part,
  then Google Places for the facility cards.

nearby_facilities / shops
  Use LLM-extracted location to build a clean Google Places query.
  Falls back to GPS / pincode if no location was named.
"""
import json
import re
from typing import List, Literal, Optional, TypedDict

from langgraph.graph import END, START, StateGraph

from src.prompts import CLASSIFIER_SYSTEM, HEALTH_ADVISOR_EXTRA, HEALTH_AND_NEARBY_EXTRA
from src.services.bedrock_service import bedrock, detect_red_flags_fast
from src.services.database import db
from src.services.google_places_service import google_places
from src.utils.constants import (
    MAX_NEARBY_FACILITIES,
    MSG_EMERGENCY_RESPONSE_BY_LANG,
    SHOP_STATUS_APPROVED,
)
from src.utils.logger import logger


# ── State ─────────────────────────────────────────────────────────────────────

class QueryState(TypedDict):
    # Inputs provided by the handler
    text: str
    language: str
    user_id: str
    pincode: Optional[str]
    lat: Optional[float]
    lon: Optional[float]
    conversation_history: List[dict]
    system_extra: str
    use_cache: bool
    low_bandwidth: bool
    # Outputs populated by the graph nodes
    intent: str               # 'health_advice' | 'nearby_facilities' | 'shops'
    nearby_kind: str          # 'clinic' | 'pharmacy' | 'hospital' | 'facilities' | ''
    extracted_location: Optional[str]  # LLM-extracted city/place, None = use GPS/pincode
    reply: str                # displayed as text in the chat bubble
    tts_text: str             # spoken via Polly; may differ from reply (e.g. nearby TTS)
    facilities: List[dict]


# ── Numbered-list normaliser ──────────────────────────────────────────────────
#
# Handles all common LLM number formats:
#   "3. text"   "3.text"   "**3.**"   "**3.** text"   "3) text"
# Strips any markdown bold markers (* or **) around the number.
#
_NUMBERED_LINE_RE = re.compile(
    r"^(\s*)"          # optional leading whitespace
    r"\*{0,2}"         # optional markdown bold open  (**  or *)
    r"(\d+)"           # the number
    r"[\.\)]\s*"       # period or paren + optional space
    r"\*{0,2}"         # optional markdown bold close
    r"\s*(.*)",        # rest of line content (may be empty)
    re.DOTALL,
)

def _clean_reply(text: str) -> str:
    """
    Strip lines where the LLM accidentally wrote meta-commentary about the UI
    (e.g. "(facility cards are displayed)", "निम्नलिखित स्वास्थ्य सुविधाएं...").
    These appear when the prompt mentions "cards will be shown below".
    """
    _meta_patterns = re.compile(
        r"("
        r"\(.*?(card|कार्ड|suvidhae|सुविधा|facilit|display|प्रदर्शित).*?\)"  # parenthesised stage directions
        r"|निम्नलिखित\s+स्वास्थ्य\s+सुविधाएं"                                # "following health facilities"
        r"|following\s+(health\s+)?facilit"                                   # English equivalent
        r"|यहाँ\s+(निकटतम|पास\s+की)\s+सुविधाएं"                              # "here are the nearest facilities"
        r")",
        re.IGNORECASE | re.UNICODE,
    )
    cleaned_lines = []
    for line in text.split("\n"):
        if _meta_patterns.search(line):
            continue   # drop the whole line
        cleaned_lines.append(line)
    # Remove leading/trailing blank lines introduced by dropped lines
    result = "\n".join(cleaned_lines)
    return re.sub(r"\n{3,}", "\n\n", result).strip()


def _renumber(text: str) -> str:
    """
    Renumber any ordered list in an LLM response so it always starts at 1.
    Handles plain numbers ("3."), bold numbers ("**3.**"), and numbers
    on their own line (number + content on next line).
    Only renumbers when the first detected list number is > 1.
    """
    lines = text.split("\n")

    first_num: Optional[int] = None
    for line in lines:
        m = _NUMBERED_LINE_RE.match(line)
        if m:
            first_num = int(m.group(2))
            break

    if first_num is None or first_num == 1:
        return text   # already correct or no numbered list found

    counter = 0
    result = []
    for line in lines:
        m = _NUMBERED_LINE_RE.match(line)
        if m:
            counter += 1
            prefix   = m.group(1)  # leading whitespace
            content  = m.group(3)  # text after the number (may be empty)
            # Reconstruct as clean "N." — strip any markdown bold from number
            rebuilt = f"{prefix}{counter}."
            if content:
                rebuilt += f" {content}"
            result.append(rebuilt)
        else:
            result.append(line)
    return "\n".join(result)


# ── Human-readable search terms for Google Places ─────────────────────────────

_KIND_SEARCH_TERM = {
    "clinic":     "clinics and doctors",
    "pharmacy":   "pharmacies",
    "hospital":   "hospitals",
    "facilities": "clinics hospitals pharmacies",
    "shops":      "shops and stores",
}

_VALID_INTENTS = frozenset(
    ("health_advice", "nearby_facilities", "health_and_nearby", "shops", "general")
)
_VALID_KINDS = frozenset(
    ("clinic", "hospital", "pharmacy", "facilities", "shops", "")
)


# ── LLM classifier (single call, structured JSON output) ──────────────────────

def _llm_classify_all(text: str) -> tuple[str, str, Optional[str]]:
    """
    One Bedrock call that returns (intent, kind, extracted_location).

    Uses the CLASSIFIER_SYSTEM prompt (prompts.py) — no regex, no separate
    location-extraction call. Works for any Indian language or Hinglish phrasing.
    Falls back to ('health_advice', '', None) on any parse error.
    """
    try:
        raw = bedrock.structured_call(
            system_prompt=CLASSIFIER_SYSTEM,
            user_message=f'Query: "{text}"',
            max_tokens=128,
        ).strip()

        # Strip any accidental markdown fences
        if raw.startswith("```"):
            raw = raw.split("```")[1]
            if raw.startswith("json"):
                raw = raw[4:]

        data     = json.loads(raw)
        intent   = data.get("intent", "health_advice").strip().lower()
        kind     = data.get("kind", "").strip().lower()
        location = data.get("location")

        if intent not in _VALID_INTENTS:
            intent = "health_advice"
        if kind not in _VALID_KINDS:
            kind = "facilities"
        if location and (not isinstance(location, str) or location.upper() == "NULL"):
            location = None

        return intent, kind, location or None

    except Exception as exc:
        logger.warning("llm_classify_all_failed", error=str(exc), text=text[:60])
        return "health_advice", "", None


# ── Graph nodes ───────────────────────────────────────────────────────────────

def classify_node(state: QueryState) -> dict:
    intent, nearby_kind, extracted_location = _llm_classify_all(state["text"])

    logger.info(
        "agent_classified",
        intent=intent,
        kind=nearby_kind,
        location=extracted_location,
        text=state["text"][:60],
    )
    return {
        "intent":             intent,
        "nearby_kind":        nearby_kind,
        "extracted_location": extracted_location,
    }


def health_advice_node(state: QueryState) -> dict:
    text = state["text"]
    if detect_red_flags_fast(text):
        reply = MSG_EMERGENCY_RESPONSE_BY_LANG.get(
            state["language"], MSG_EMERGENCY_RESPONSE_BY_LANG["en"]
        )
    else:
        # Combine the focused health advisor prompt with any handler-supplied extras
        combined_extra = HEALTH_ADVISOR_EXTRA
        if state.get("system_extra"):
            combined_extra = f"{HEALTH_ADVISOR_EXTRA}\n{state['system_extra']}"
        try:
            reply = bedrock.chat(
                text,
                conversation_history=state["conversation_history"],
                system_extra=combined_extra,
                use_cache=state["use_cache"],
                language=state["language"],
            )
        except Exception as exc:
            logger.error("health_advice_bedrock_failed", error=str(exc))
            reply = _err_reply(state["language"])
    return {"reply": reply, "tts_text": reply, "facilities": []}


def nearby_facilities_node(state: QueryState) -> dict:
    """Pure location search — no health complaint in the query."""
    kind               = state["nearby_kind"] or "facilities"
    lang               = state["language"]
    lat                = state.get("lat")
    lon                = state.get("lon")
    pincode            = state.get("pincode") or None
    extracted_location = state.get("extracted_location")

    results = _fetch_facilities(kind, extracted_location, lat, lon, pincode)
    if results is None:
        msg = _no_location_reply(lang)
        return {"reply": msg, "tts_text": msg, "facilities": []}

    logger.info("nearby_facilities_searched", kind=kind, count=len(results))
    # reply is empty so the TTS text never renders as visible bubble text.
    # tts_text is passed to Polly so the user still hears the facility names read out.
    tts = _format_tts(results, kind, lang)
    return {"reply": "", "tts_text": tts, "facilities": results}


def health_and_nearby_node(state: QueryState) -> dict:
    """
    User expressed a health problem AND wants a nearby facility.
    Runs two agents in sequence:
      1. Bedrock → dynamic health advice for the specific complaint
      2. Google Places → real nearby facilities
    Returns the advice as reply text and the places as the facilities array.
    The frontend renders both: advice bubble + facility cards below.
    """
    text               = state["text"]
    lang               = state["language"]
    kind               = state["nearby_kind"] or "facilities"
    lat                = state.get("lat")
    lon                = state.get("lon")
    pincode            = state.get("pincode") or None
    extracted_location = state.get("extracted_location")

    # ── Agent 1: Health advice via Bedrock ────────────────────────────────────
    if detect_red_flags_fast(text):
        health_reply = MSG_EMERGENCY_RESPONSE_BY_LANG.get(
            lang, MSG_EMERGENCY_RESPONSE_BY_LANG["en"]
        )
    else:
        # Use the health+nearby prompt so the model knows cards follow
        combined_extra = HEALTH_AND_NEARBY_EXTRA
        if state.get("system_extra"):
            combined_extra = f"{HEALTH_AND_NEARBY_EXTRA}\n{state['system_extra']}"
        try:
            health_reply = bedrock.chat(
                text,
                conversation_history=state["conversation_history"],
                system_extra=combined_extra,
                use_cache=state["use_cache"],
                language=lang,
            )
        except Exception as exc:
            logger.error("health_and_nearby_bedrock_failed", error=str(exc))
            health_reply = _err_reply(lang)
    # ── Agent 2: Nearby facilities via Google Places ──────────────────────────
    results = _fetch_facilities(kind, extracted_location, lat, lon, pincode)
    if results is None:
        results = []   # no location — health advice still shown; no cards

    logger.info("health_and_nearby_done", kind=kind, count=len(results))
    return {"reply": health_reply, "tts_text": health_reply, "facilities": results}


def shops_node(state: QueryState) -> dict:
    lang               = state["language"]
    lat                = state.get("lat")
    lon                = state.get("lon")
    pincode            = state.get("pincode") or None
    extracted_location = state.get("extracted_location")

    shops: list = []

    if extracted_location:
        # LLM confirmed a specific location → skip DynamoDB, query Google directly
        clean_query = f"shops and stores in {extracted_location}, India"
        logger.info("shops_named_location_search", location=extracted_location)
        shops = google_places.search_facilities(
            query=clean_query,
            kind="shops",
            lat=None, lon=None,
            max_results=MAX_NEARBY_FACILITIES,
            force_text_search=True,
        )
    else:
        # No named location — need GPS or pincode
        if lat is None and lon is None and not pincode:
            return {"reply": _no_location_reply(lang), "facilities": []}

        # 1. Registered GramSathi shops from DynamoDB (highest priority)
        if pincode:
            all_db = db.get_shops_by_pincode(pincode)
            shops  = [s for s in all_db if s.get("status") == SHOP_STATUS_APPROVED][:MAX_NEARBY_FACILITIES]

        # 2. Fall back to Google Places (GPS nearby or pincode-anchored text search)
        if not shops:
            shops = google_places.search_facilities(
                query="shops and stores, India",
                kind="shops",
                lat=lat,
                lon=lon,
                max_results=MAX_NEARBY_FACILITIES,
                force_text_search=False,
                pincode=pincode,
            )

    logger.info("shops_searched", location=extracted_location, count=len(shops))
    tts = _format_tts(shops, "shops", lang)
    return {"reply": "", "tts_text": tts, "facilities": shops}


def _fetch_facilities(
    kind: str,
    extracted_location: Optional[str],
    lat: Optional[float],
    lon: Optional[float],
    pincode: Optional[str],
) -> Optional[list]:
    """
    Shared facility-fetching logic used by both nearby_facilities_node and
    health_and_nearby_node. Returns a list of place dicts, or None when no
    location data is available at all.
    """
    if extracted_location:
        kind_term   = _KIND_SEARCH_TERM.get(kind, kind)
        clean_query = f"{kind_term} in {extracted_location}, India"
        logger.info("fetch_facilities_named_location", location=extracted_location, kind=kind)
        return google_places.search_facilities(
            query=clean_query,
            kind=kind,
            lat=None, lon=None,
            max_results=MAX_NEARBY_FACILITIES,
            force_text_search=True,
        )
    if lat is not None or lon is not None or pincode:
        return google_places.search_facilities(
            query=f"{_KIND_SEARCH_TERM.get(kind, kind)}, India",
            kind=kind,
            lat=lat,
            lon=lon,
            max_results=MAX_NEARBY_FACILITIES,
            force_text_search=False,
            pincode=pincode,
        )
    return None   # caller decides how to handle the no-location case


def _route(state: QueryState) -> Literal["health_advice", "nearby_facilities", "shops", "health_and_nearby"]:
    intent = state.get("intent", "health_advice")
    if intent in ("nearby_facilities", "shops", "health_and_nearby"):
        return intent
    return "health_advice"


# ── TTS formatter ─────────────────────────────────────────────────────────────

def _format_tts(items: List[dict], kind: str, language: str) -> str:
    _empty = {
        "hi": {
            "clinic":     "आसपास कोई क्लीनिक नहीं मिली।",
            "pharmacy":   "आसपास कोई फार्मेसी नहीं मिली।",
            "hospital":   "आसपास कोई अस्पताल नहीं मिला।",
            "facilities": "आसपास कोई स्वास्थ्य सेवा नहीं मिली।",
            "shops":      "आसपास कोई दुकान नहीं मिली।",
        },
        "en": {
            "clinic":     "No clinics found nearby.",
            "pharmacy":   "No pharmacies found nearby.",
            "hospital":   "No hospitals found nearby.",
            "facilities": "No health facilities found nearby.",
            "shops":      "No shops found nearby.",
        },
    }
    _intro = {
        "hi": {
            "clinic":     lambda n: f"{n} क्लीनिक मिली।",
            "pharmacy":   lambda n: f"{n} फार्मेसी मिली।",
            "hospital":   lambda n: f"{n} अस्पताल मिले।",
            "facilities": lambda n: f"{n} स्वास्थ्य सेवाएं मिलीं।",
            "shops":      lambda n: f"{n} दुकानें मिलीं।",
        },
        "en": {
            "clinic":     lambda n: f"Found {n} clinic(s).",
            "pharmacy":   lambda n: f"Found {n} pharmacy(ies).",
            "hospital":   lambda n: f"Found {n} hospital(s).",
            "facilities": lambda n: f"Found {n} health facility(ies).",
            "shops":      lambda n: f"Found {n} shop(s).",
        },
    }

    # Non-Hindi Indian languages fall back to Hindi for TTS phrases
    lang = language if language in ("hi", "en") else "hi"

    if not items:
        return _empty.get(lang, _empty["en"]).get(kind, "No results found.")

    count    = len(items)
    intro_fn = _intro.get(lang, _intro["en"]).get(kind)
    intro    = intro_fn(count) if intro_fn else f"Found {count} result(s)."

    parts = [intro]
    for i, place in enumerate(items[:3], 1):
        name  = place.get("name", "?")
        phone = place.get("phone", "")
        parts.append(f" {i}. {name}.")
        if phone:
            parts.append(f" Phone: {phone}.")
    return "".join(parts)



def _err_reply(language: str) -> str:
    return (
        "माफ करें, अभी जानकारी उपलब्ध नहीं है। कृपया दोबारा कोशिश करें।"
        if language == "hi"
        else "Sorry, I could not process your request. Please try again."
    )


def _no_location_reply(language: str) -> str:
    _msgs = {
        "hi": "आसपास खोजने के लिए कृपया अपना स्थान साझा करें या पिनकोड बताएं। जैसे — 'कोटा में क्लीनिक' या GPS चालू करें।",
        "en": "To find nearby results, please enable GPS or mention a location — for example, 'clinics in Kota'.",
        "mr": "जवळची माहिती शोधण्यासाठी कृपया GPS चालू करा किंवा स्थान सांगा — उदा. 'पुण्यात क्लीनिक'.",
        "ta": "அருகிலுள்ளவற்றை தேட GPS இயக்கவும் அல்லது இடத்தைக் குறிப்பிடவும் — எ.கா. 'சென்னையில் கிளினிக்'.",
        "te": "దగ్గరలో వెతకడానికి GPS ఆన్ చేయండి లేదా స్థలం చెప్పండి — ఉదా. 'హైదరాబాద్‌లో క్లినిక్'.",
        "kn": "ಹತ್ತಿರದ ಫಲಿತಾಂಶಗಳಿಗಾಗಿ GPS ಆನ್ ಮಾಡಿ ಅಥವಾ ಸ್ಥಳ ಹೇಳಿ — ಉದಾ. 'ಬೆಂಗಳೂರಿನಲ್ಲಿ ಕ್ಲಿನಿಕ್'.",
        "bn": "কাছাকাছি খুঁজতে GPS চালু করুন বা স্থান বলুন — যেমন 'কলকাতায় ক্লিনিক'।",
        "gu": "નજીકનાં પરિણામો માટે GPS ચાલુ કરો અથવા સ્થળ જણાવો — જેમ કે 'અમદાવાદમાં ક્લિનિક'.",
    }
    return _msgs.get(language, _msgs["en"])


# ── Build and compile the graph ───────────────────────────────────────────────

_builder = StateGraph(QueryState)
_builder.add_node("classify",          classify_node)
_builder.add_node("health_advice",     health_advice_node)
_builder.add_node("nearby_facilities", nearby_facilities_node)
_builder.add_node("health_and_nearby", health_and_nearby_node)
_builder.add_node("shops",             shops_node)

_builder.add_edge(START, "classify")
_builder.add_conditional_edges("classify", _route)
_builder.add_edge("health_advice",     END)
_builder.add_edge("nearby_facilities", END)
_builder.add_edge("health_and_nearby", END)
_builder.add_edge("shops",             END)

agent_graph = _builder.compile()
