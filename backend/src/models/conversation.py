from __future__ import annotations

from enum import Enum
from typing import List, Optional
from pydantic import BaseModel, Field
from datetime import datetime, timezone


class Intent(str, Enum):
    HEALTH = "health"
    RETAIL = "retail"
    INFO = "info"
    UNKNOWN = "unknown"


class MessageRole(str, Enum):
    USER = "user"
    ASSISTANT = "assistant"


class Message(BaseModel):
    role: MessageRole
    content: str
    audioUrl: Optional[str] = None
    timestamp: str = Field(default_factory=lambda: datetime.now(timezone.utc).isoformat())


class Conversation(BaseModel):
    conversationId: str
    userId: str
    intent: Intent = Intent.UNKNOWN
    language: str = "hi"
    messages: List[Message] = []
    symptoms: List[str] = []
    createdAt: str = Field(default_factory=lambda: datetime.now(timezone.utc).isoformat())
    updatedAt: str = Field(default_factory=lambda: datetime.now(timezone.utc).isoformat())

    def to_dynamo(self) -> dict:
        data = self.model_dump()
        # DynamoDB needs serializable messages list
        data["messages"] = [m.model_dump() for m in self.messages]
        return data

    @classmethod
    def from_dynamo(cls, item: dict) -> "Conversation":
        return cls(**item)
