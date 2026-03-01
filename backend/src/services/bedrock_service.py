import hashlib
import json
import re
import time
import boto3
from typing import List, Optional

from src.services.database import db
from src.utils.config import config

# Trimmed system prompt — shorter = fewer input tokens per call
SYSTEM_PROMPT_BASE = """You are GramSathi, a helpful AI assistant for rural India.
Help with: basic healthcare guidance (non-diagnostic) and local commerce.

RULES:
- NEVER diagnose. Recommend a doctor for serious conditions.
- Be concise. Use simple language.
- If intent is unclear, ask one short clarifying question.
"""

# Explicit language instruction so AI replies in the selected language
_LANGUAGE_INSTRUCTIONS = {
    "hi": "IMPORTANT: Reply ONLY in Hindi (हिंदी). Use Devanagari script.",
    "en": "IMPORTANT: Reply ONLY in English.",
    "mr": "IMPORTANT: Reply ONLY in Marathi (मराठी).",
    "ta": "IMPORTANT: Reply ONLY in Tamil (தமிழ்).",
    "te": "IMPORTANT: Reply ONLY in Telugu (తెలుగు).",
    "kn": "IMPORTANT: Reply ONLY in Kannada (ಕನ್ನಡ).",
    "bn": "IMPORTANT: Reply ONLY in Bengali (বাংলা).",
    "gu": "IMPORTANT: Reply ONLY in Gujarati (ગુજરાતી).",
}

# Free emergency detection — keyword check before spending tokens on Bedrock
_EMERGENCY_PATTERNS = [
    # English
    r"chest pain", r"heart attack", r"can'?t breathe", r"not breathing",
    r"unconscious", r"heavy bleeding", r"stroke", r"seizure", r"overdose",
    # Hindi
    r"सीने में दर्द", r"दिल का दौरा", r"सांस नहीं", r"सांस नही",
    r"बेहोश", r"बहुत खून", r"लकवा", r"दौरा", r"अचेत",
    # Emergency number mentioned → user already knows it's serious
    r"\b108\b", r"\b112\b",
]
_EMERGENCY_RE = re.compile("|".join(_EMERGENCY_PATTERNS), re.IGNORECASE)


def detect_red_flags_fast(text: str) -> bool:
    """
    Free keyword-based emergency check. No Bedrock call needed.
    Covers the vast majority of real emergencies without spending tokens.
    """
    return bool(_EMERGENCY_RE.search(text))


# ── Fast keyword-based intent pre-classification ──────────────────────────────
# Handles ~80 % of real queries without spending any Bedrock tokens.
# Only genuinely ambiguous messages fall through to the LLM classifier.

_HEALTH_INTENT_RE = re.compile(
    r"\b("
    # English symptoms / health terms
    r"fever|cough|cold|pain|ache|headache|stomach|vomit|diarr|bleed|rash|swel|breath|"
    r"doctor|hospital|clinic|medicine|tablet|capsule|injection|disease|ill|sick|"
    # Hindi health terms
    r"बुखार|खाँसी|खांसी|जुकाम|दर्द|सिरदर्द|पेट|उल्टी|दस्त|खून|सूजन|सांस|"
    r"डॉक्टर|अस्पताल|क्लीनिक|दवा|बीमारी|तबियत"
    r")\b",
    re.IGNORECASE,
)

_RETAIL_INTENT_RE = re.compile(
    r"\b("
    # English commerce terms
    r"buy|order|shop|price|cost|stock|deliver|milk|rice|wheat|vegetable|grocery|"
    r"rupee|rupees|kg|kilo|liter|litre|packet|bottle|"
    # Hindi commerce terms
    r"खरीद|ऑर्डर|दुकान|कीमत|सस्ता|महंगा|दूध|चावल|गेहूं|सब्जी|राशन|किलो|लीटर"
    r")\b",
    re.IGNORECASE,
)


def _classify_intent_fast(text: str) -> str:
    """
    Free keyword-based intent check. Returns 'health', 'retail', or '' (ambiguous).
    Ambiguous messages (matching both or neither) fall through to the LLM.
    """
    has_health = bool(_HEALTH_INTENT_RE.search(text))
    has_retail = bool(_RETAIL_INTENT_RE.search(text))
    if has_health and not has_retail:
        return "health"
    if has_retail and not has_health:
        return "retail"
    return ""


def _cache_key(text: str, language: str) -> str:
    normalized = re.sub(r"\s+", " ", text.lower().strip())
    return hashlib.sha256(f"{language}:{normalized}".encode()).hexdigest()[:32]


class BedrockService:
    def __init__(self):
        self._client = boto3.client("bedrock-runtime", region_name=config.AWS_REGION)

    def chat(
        self,
        user_message: str,
        conversation_history: Optional[List[dict]] = None,
        system_extra: str = "",
        use_cache: bool = False,
        language: str = "hi",
    ) -> str:
        """
        Send a message to Claude and return the text reply.

        use_cache=True: check DynamoDB cache before calling Bedrock.
        Only cache when there is no prior conversation (first message).
        """
        # Only cache stateless first-message queries (no history = generic question)
        cacheable = use_cache and not conversation_history
        cache_key: Optional[str] = None
        if cacheable:
            cache_key = _cache_key(user_message, language)
            cached = db.get_response_cache(cache_key)
            if cached:
                return cached

        messages = []
        if conversation_history:
            # Keep only the last N turns to control token count
            turns = config.BEDROCK_HISTORY_TURNS * 2  # each turn = user + assistant
            for msg in conversation_history[-turns:]:
                messages.append({"role": msg["role"], "content": msg["content"]})

        messages.append({"role": "user", "content": user_message})

        system = SYSTEM_PROMPT_BASE
        lang_instruction = _LANGUAGE_INSTRUCTIONS.get(language, _LANGUAGE_INSTRUCTIONS["en"])
        system += f"\n{lang_instruction}"
        if system_extra:
            system += f"\n{system_extra}"

        body = {
            "anthropic_version": "bedrock-2023-05-31",
            "max_tokens": config.BEDROCK_MAX_TOKENS,
            "system": system,
            "messages": messages,
        }

        response = self._client.invoke_model(
            modelId=config.BEDROCK_MODEL_ID,
            contentType="application/json",
            accept="application/json",
            body=json.dumps(body),
        )

        result = json.loads(response["body"].read())
        reply = result["content"][0]["text"]

        if cacheable and cache_key:
            db.set_response_cache(cache_key, reply, language)

        return reply

    def classify_intent(self, text: str) -> str:
        """
        Returns one of: health | retail | info | unknown.
        Fast keyword check first — only calls Bedrock for ambiguous queries.
        """
        fast = _classify_intent_fast(text)
        if fast:
            return fast
        # Fall back to LLM only when keywords are ambiguous or absent
        prompt = (
            "Classify into exactly one word (health/retail/info/unknown):\n"
            f"Query: {text}"
        )
        intent = self.chat(prompt).strip().lower()
        valid = {"health", "retail", "info", "unknown"}
        return intent if intent in valid else "unknown"

    def extract_nearby_location(self, text: str) -> Optional[str]:
        """
        Extract a specific city or area name from a nearby-facility query.
        Returns the city string if the user mentioned one, else None (meaning 'near me').
        Uses a minimal prompt to keep latency and cost low.
        Only called when the app has no GPS coordinates to offer.
        """
        prompt = (
            "Extract the location from this query. "
            'Reply ONLY with valid JSON: {"location": "<city>"} or {"location": null}\n'
            f"Query: {text}"
        )
        try:
            raw = self.chat(prompt, language="en")
            match = re.search(r'\{[^}]+\}', raw, re.DOTALL)
            if not match:
                return None
            data = json.loads(match.group())
            loc = data.get("location")
            return loc.strip() if isinstance(loc, str) and loc.strip() else None
        except Exception:
            return None

    def generate_doctor_summary(
        self,
        symptoms: List[str],
        conversation_history: List[dict],
        language: str = "hi",
    ) -> str:
        """Concise summary a patient can show to a doctor (US-09)."""
        symptom_list = ", ".join(symptoms) if symptoms else "not specified"
        prompt = (
            f"Write a brief doctor-ready summary (under 120 words).\n"
            f"Symptoms: {symptom_list}\n"
            f"Context: {json.dumps(conversation_history[-4:], ensure_ascii=False)}\n\n"
            "Format: Chief Complaint | Symptoms | Duration | Notes"
        )
        return self.chat(prompt, language=language)


bedrock = BedrockService()
