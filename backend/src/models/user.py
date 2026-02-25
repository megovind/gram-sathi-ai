from __future__ import annotations

from enum import Enum
from typing import Optional
from pydantic import BaseModel, Field
from datetime import datetime, timezone


class Language(str, Enum):
    HINDI = "hi"
    ENGLISH = "en"
    MARATHI = "mr"
    TAMIL = "ta"
    TELUGU = "te"
    KANNADA = "kn"
    BENGALI = "bn"
    GUJARATI = "gu"


class UserRole(str, Enum):
    CITIZEN = "citizen"
    SHOP_OWNER = "shop_owner"
    HEALTHCARE_WORKER = "healthcare_worker"


class User(BaseModel):
    userId: str
    phone: Optional[str] = None
    name: Optional[str] = None
    preferredLanguage: Language = Language.HINDI
    role: UserRole = UserRole.CITIZEN
    pincode: Optional[str] = None
    createdAt: str = Field(default_factory=lambda: datetime.now(timezone.utc).isoformat())
    updatedAt: str = Field(default_factory=lambda: datetime.now(timezone.utc).isoformat())

    def to_dynamo(self) -> dict:
        return self.model_dump()

    @classmethod
    def from_dynamo(cls, item: dict) -> "User":
        return cls(**item)
