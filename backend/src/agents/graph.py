"""
GramSathi LangGraph agent graph.

Flow:
  START → classify → (conditional) → health_advice
                                    → nearby_facilities
                                    → shops
                       each → END

classify
  Fast keyword pre-filter handles ~90% of queries without Bedrock.
  Ambiguous queries fall through to a lightweight Bedrock classification call.
  For nearby_facilities / shops intents, Bedrock also extracts the specific
  location name from the query ("Aklera", "Jaipur", etc.) or returns None
  meaning "use the user's GPS / pincode instead".

health_advice
  Delegates to BedrockService.chat() with conversation history support.

nearby_facilities / shops
  Use the LLM-extracted location to build a clean, structured Google Places
  query.  If no location was extracted, fall back to GPS coordinates (10–50 km
  radius) or pincode-anchored text search.  If nothing is available, reply
  asking the user to share their location.
"""
import re
from typing import List, Literal, Optional, TypedDict

from langgraph.graph import END, START, StateGraph

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
    reply: str
    facilities: List[dict]


# ── Fast intent classification (keyword-only, no LLM) ─────────────────────────

_FACILITY_RE = re.compile(
    r"\b(clinic|clinics|pharmacy|pharmacies|hospital|hospitals|"
    r"doctor|doctors|dispensary|medical\s+cent|health\s+cent|"
    r"क्लीनिक|फार्मेसी|अस्पताल|दवाखाना|डॉक्टर|दवाई|दवाखाने)\b",
    re.IGNORECASE,
)
_SHOP_RE = re.compile(
    r"\b(shop|shops|store|stores|grocery|groceries|kirana|market|supermarket|"
    r"दुकान|दुकानें|बाजार|किराना|राशन)\b",
    re.IGNORECASE,
)
_LOCATION_RE = re.compile(
    r"\b(nearby|near|in|at|around|close|find|search|locate|show|list|get|"
    r"give|tell|where|which|any|some|want|need|suggest|recommend|"
    r"नजदीक|पास|में|के पास|पर|ढूंढो|खोजो|बताओ|दिखाओ|कहाँ|कोई)\b",
    re.IGNORECASE,
)
_KIND_MAP = [
    ("pharmacy", re.compile(r"\b(pharmacy|pharmacies|फार्मेसी|दवाखाना|दवाई)\b", re.IGNORECASE)),
    ("hospital", re.compile(r"\b(hospital|hospitals|अस्पताल)\b", re.IGNORECASE)),
    ("clinic",   re.compile(r"\b(clinic|clinics|doctor|doctors|dispensary|क्लीनिक|डॉक्टर)\b", re.IGNORECASE)),
]

# Human-readable search term per kind — used to build clean Google queries
_KIND_SEARCH_TERM = {
    "clinic":     "clinics and doctors",
    "pharmacy":   "pharmacies",
    "hospital":   "hospitals",
    "facilities": "clinics hospitals pharmacies",
    "shops":      "shops and stores",
}


def _fast_classify(text: str) -> tuple[str, str]:
    """
    Returns (intent, nearby_kind) using keyword matching only.
    Returns ('', '') when the query is ambiguous and needs LLM classification.
    """
    has_facility = bool(_FACILITY_RE.search(text))
    has_shop     = bool(_SHOP_RE.search(text))
    has_location = bool(_LOCATION_RE.search(text))

    if has_facility and has_location:
        kind = next((k for k, p in _KIND_MAP if p.search(text)), "facilities")
        return "nearby_facilities", kind

    if has_shop and has_location:
        return "shops", ""

    return "", ""   # ambiguous — fall through to Bedrock


# ── LLM helpers ───────────────────────────────────────────────────────────────

def _llm_classify(text: str) -> tuple[str, str]:
    """Bedrock fallback for ambiguous queries (rare)."""
    prompt = (
        "Classify this user query into one of three categories:\n"
        "- nearby_facilities: user wants to FIND or LOCATE clinics, doctors, hospitals, pharmacies\n"
        "  (e.g. 'clinics', 'show me doctors', 'any pharmacy', 'hospitals near me')\n"
        "- shops: user wants to find local shops, groceries, kirana stores\n"
        "- health_advice: user describes symptoms, asks about a disease, or wants medical guidance\n"
        "  (e.g. 'I have a fever', 'what is diabetes', 'my head hurts')\n\n"
        "When in doubt between nearby_facilities and health_advice, prefer nearby_facilities "
        "if the query contains only facility-type words (clinic, doctor, hospital, pharmacy).\n\n"
        f'Query: "{text}"\n\n'
        'Reply with ONLY one word: nearby_facilities, shops, or health_advice'
    )
    try:
        raw    = bedrock.chat(prompt, language="en").strip().lower()
        intent = raw if raw in ("nearby_facilities", "shops", "health_advice") else "health_advice"
    except Exception:
        intent = "health_advice"
    return intent, ""


def _llm_extract_location(text: str) -> Optional[str]:
    """
    Use Bedrock to extract a specific city / town / area name from the query.

    Returns the place name (e.g. "Aklera", "Jaipur") or None when the user
    did not specify a location (e.g. "nearby clinics", "shops near me").

    This replaces brittle regex matching and works across all Indian languages,
    Hinglish, and varied phrasings:
      "shops in Aklera"           → "Aklera"
      "Aklera ke shops"           → "Aklera"
      "shops near Jaipur"         → "Jaipur"
      "जयपुर में अस्पताल"          → "Jaipur"
      "nearby clinics"            → None
      "मेरे पास दुकान"             → None
    """
    prompt = (
        f'User query: "{text}"\n\n'
        "Task: Extract the specific location name (city, town, or area) mentioned in this query.\n"
        "Rules:\n"
        "- If a specific place is named (e.g. Aklera, Delhi, Kota, Jaipur, Mumbai), "
        "reply with ONLY that place name in English.\n"
        "- If the query asks for 'nearby', 'near me', 'आसपास', 'पास में', or gives no specific place, "
        "reply with exactly: NONE\n"
        "- Do NOT include extra words. Reply with ONLY the place name or NONE."
    )
    try:
        raw     = bedrock.chat(prompt, language="en").strip()
        cleaned = raw.strip('"\'.,!? ').strip()
        if not cleaned or cleaned.upper() == "NONE":
            return None
        return cleaned
    except Exception as exc:
        logger.warning("llm_extract_location_failed", error=str(exc))
        return None   # gracefully fall back to GPS / pincode


# ── Graph nodes ───────────────────────────────────────────────────────────────

def classify_node(state: QueryState) -> dict:
    intent, nearby_kind = _fast_classify(state["text"])
    if not intent:
        intent, nearby_kind = _llm_classify(state["text"])

    # For location-based intents, ask the LLM to extract the specific place name.
    # This is far more robust than regex — handles any language, phrasing, or order.
    extracted_location: Optional[str] = None
    if intent in ("nearby_facilities", "shops"):
        extracted_location = _llm_extract_location(state["text"])

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
        try:
            reply = bedrock.chat(
                text,
                conversation_history=state["conversation_history"],
                system_extra=state["system_extra"],
                use_cache=state["use_cache"],
                language=state["language"],
            )
        except Exception as exc:
            logger.error("health_advice_bedrock_failed", error=str(exc))
            reply = _err_reply(state["language"])
    return {"reply": reply, "facilities": []}


def nearby_facilities_node(state: QueryState) -> dict:
    kind               = state["nearby_kind"] or "facilities"
    lang               = state["language"]
    lat                = state.get("lat")
    lon                = state.get("lon")
    pincode            = state.get("pincode") or None
    extracted_location = state.get("extracted_location")

    if extracted_location:
        # LLM confirmed a specific location → build a clean, precise Google query
        kind_term   = _KIND_SEARCH_TERM.get(kind, kind)
        clean_query = f"{kind_term} in {extracted_location}, India"
        logger.info("nearby_facilities_named_location", location=extracted_location, kind=kind)
        results = google_places.search_facilities(
            query=clean_query,
            kind=kind,
            lat=None, lon=None,          # ignore GPS — user specified a place
            max_results=MAX_NEARBY_FACILITIES,
            force_text_search=True,
        )
    elif lat is not None or lon is not None or pincode:
        # No named location → search near user's current position
        results = google_places.search_facilities(
            query=f"{_KIND_SEARCH_TERM.get(kind, kind)}, India",
            kind=kind,
            lat=lat,
            lon=lon,
            max_results=MAX_NEARBY_FACILITIES,
            force_text_search=False,
            pincode=pincode,
        )
    else:
        return {"reply": _no_location_reply(lang), "facilities": []}

    logger.info("nearby_facilities_searched", kind=kind, count=len(results))
    reply = _format_tts(results, kind, lang)
    return {"reply": reply, "facilities": results}


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
    reply = _format_tts(shops, "shops", lang)
    return {"reply": reply, "facilities": shops}


def _route(state: QueryState) -> Literal["health_advice", "nearby_facilities", "shops"]:
    intent = state.get("intent", "health_advice")
    if intent in ("nearby_facilities", "shops"):
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
_builder.add_node("shops",             shops_node)

_builder.add_edge(START, "classify")
_builder.add_conditional_edges("classify", _route)
_builder.add_edge("health_advice",     END)
_builder.add_edge("nearby_facilities", END)
_builder.add_edge("shops",             END)

agent_graph = _builder.compile()
