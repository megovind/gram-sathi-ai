from __future__ import annotations

from dataclasses import dataclass, field
from datetime import datetime, timezone
from enum import Enum
from typing import List, Optional


class Intent(str, Enum):
    HEALTH = "health"
    RETAIL = "retail"
    INFO = "info"
    UNKNOWN = "unknown"


class MessageRole(str, Enum):
    USER = "user"
    ASSISTANT = "assistant"


@dataclass
class Message:
    role: MessageRole
    content: str
    audioUrl: Optional[str] = None
    timestamp: str = field(default_factory=lambda: datetime.now(timezone.utc).isoformat())

    def to_dict(self) -> dict:
        return {
            "role": self.role.value if isinstance(self.role, Enum) else self.role,
            "content": self.content,
            "audioUrl": self.audioUrl,
            "timestamp": self.timestamp,
        }


@dataclass
class Conversation:
    conversationId: str
    userId: str
    intent: Intent = Intent.UNKNOWN
    language: str = "hi"
    messages: List[Message] = field(default_factory=list)
    symptoms: List[str] = field(default_factory=list)
    createdAt: str = field(default_factory=lambda: datetime.now(timezone.utc).isoformat())
    updatedAt: str = field(default_factory=lambda: datetime.now(timezone.utc).isoformat())

    def to_dynamo(self) -> dict:
        return {
            "conversationId": self.conversationId,
            "userId": self.userId,
            "intent": self.intent.value if isinstance(self.intent, Enum) else self.intent,
            "language": self.language,
            "messages": [m.to_dict() for m in self.messages],
            "symptoms": self.symptoms,
            "createdAt": self.createdAt,
            "updatedAt": self.updatedAt,
        }

    @classmethod
    def from_dynamo(cls, item: dict) -> "Conversation":
        messages = [
            Message(
                role=MessageRole(m.get("role", "user")),
                content=m.get("content", ""),
                audioUrl=m.get("audioUrl"),
                timestamp=m.get("timestamp", datetime.now(timezone.utc).isoformat()),
            )
            for m in item.get("messages", [])
        ]
        return cls(
            conversationId=item["conversationId"],
            userId=item["userId"],
            intent=Intent(item.get("intent", "unknown")),
            language=item.get("language", "hi"),
            messages=messages,
            symptoms=item.get("symptoms", []),
            createdAt=item.get("createdAt", datetime.now(timezone.utc).isoformat()),
            updatedAt=item.get("updatedAt", datetime.now(timezone.utc).isoformat()),
        )
