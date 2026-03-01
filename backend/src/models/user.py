from __future__ import annotations

from dataclasses import dataclass, field
from datetime import datetime, timezone
from enum import Enum
from typing import Optional


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


@dataclass
class User:
    userId: str
    phone: Optional[str] = None
    name: Optional[str] = None
    preferredLanguage: Language = Language.HINDI
    role: UserRole = UserRole.CITIZEN
    pincode: Optional[str] = None
    createdAt: str = field(default_factory=lambda: datetime.now(timezone.utc).isoformat())
    updatedAt: str = field(default_factory=lambda: datetime.now(timezone.utc).isoformat())

    def to_dynamo(self) -> dict:
        return {
            "userId": self.userId,
            "phone": self.phone,
            "name": self.name,
            "preferredLanguage": self.preferredLanguage.value if isinstance(self.preferredLanguage, Enum) else self.preferredLanguage,
            "role": self.role.value if isinstance(self.role, Enum) else self.role,
            "pincode": self.pincode,
            "createdAt": self.createdAt,
            "updatedAt": self.updatedAt,
        }

    @classmethod
    def from_dynamo(cls, item: dict) -> "User":
        return cls(
            userId=item["userId"],
            phone=item.get("phone"),
            name=item.get("name"),
            preferredLanguage=Language(item.get("preferredLanguage", "hi")),
            role=UserRole(item.get("role", "citizen")),
            pincode=item.get("pincode"),
            createdAt=item.get("createdAt", datetime.now(timezone.utc).isoformat()),
            updatedAt=item.get("updatedAt", datetime.now(timezone.utc).isoformat()),
        )
