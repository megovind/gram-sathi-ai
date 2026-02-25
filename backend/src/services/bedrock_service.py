import hashlib
import json
import re
import time
import boto3
from typing import List, Optional

from src.utils.config import config

# Trimmed system prompt — shorter = fewer input tokens per call
SYSTEM_PROMPT = """You are GramSathi, a helpful AI assistant for rural India.
Help with: basic healthcare guidance (non-diagnostic) and local commerce.

RULES:
- NEVER diagnose. Recommend a doctor for serious conditions.
- For health replies always end with: "यह सामान्य जानकारी है। डॉक्टर से परामर्श अवश्य लें।"
- Be concise. Use simple language. Reply in the user's language.
- If intent is unclear, ask one short clarifying question.
"""

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
        if cacheable:
            from src.services.dynamodb_service import dynamo
            key = _cache_key(user_message, language)
            cached = dynamo.get_response_cache(key)
            if cached:
                return cached

        messages = []
        if conversation_history:
            # Keep only the last N turns to control token count
            turns = config.BEDROCK_HISTORY_TURNS * 2  # each turn = user + assistant
            for msg in conversation_history[-turns:]:
                messages.append({"role": msg["role"], "content": msg["content"]})

        messages.append({"role": "user", "content": user_message})

        system = SYSTEM_PROMPT
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

        if cacheable:
            from src.services.dynamodb_service import dynamo
            key = _cache_key(user_message, language)
            dynamo.set_response_cache(key, reply, language)

        return reply

    def classify_intent(self, text: str) -> str:
        """Returns one of: health | retail | info | unknown"""
        prompt = (
            "Classify into exactly one word (health/retail/info/unknown):\n"
            f"Query: {text}"
        )
        intent = self.chat(prompt).strip().lower()
        valid = {"health", "retail", "info", "unknown"}
        return intent if intent in valid else "unknown"

    def generate_doctor_summary(self, symptoms: List[str], conversation_history: List[dict]) -> str:
        """Concise summary a patient can show to a doctor (US-09)."""
        symptom_list = ", ".join(symptoms) if symptoms else "not specified"
        prompt = (
            f"Write a brief doctor-ready summary (under 120 words).\n"
            f"Symptoms: {symptom_list}\n"
            f"Context: {json.dumps(conversation_history[-4:], ensure_ascii=False)}\n\n"
            "Format: Chief Complaint | Symptoms | Duration | Notes"
        )
        return self.chat(prompt)


bedrock = BedrockService()
