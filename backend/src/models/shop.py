from __future__ import annotations

from decimal import Decimal
from enum import Enum
from typing import List, Optional
from pydantic import BaseModel, Field
from datetime import datetime, timezone

from src.utils.decimal_utils import from_decimal, to_decimal


class ShopStatus(str, Enum):
    PENDING = "pending"
    APPROVED = "approved"
    SUSPENDED = "suspended"


class InventoryItem(BaseModel):
    itemId: str
    name: str
    nameHindi: Optional[str] = None
    price: float
    unit: str = "piece"
    stockQty: int = 0
    category: Optional[str] = None


class Shop(BaseModel):
    shopId: str
    ownerId: str
    name: str
    ownerName: str
    phone: str
    pincode: str
    address: Optional[str] = None
    lat: Optional[float] = None
    lng: Optional[float] = None
    status: ShopStatus = ShopStatus.PENDING
    inventory: List[InventoryItem] = []
    createdAt: str = Field(default_factory=lambda: datetime.now(timezone.utc).isoformat())
    updatedAt: str = Field(default_factory=lambda: datetime.now(timezone.utc).isoformat())

    def to_dynamo(self) -> dict:
        data = self.model_dump()
        data["inventory"] = [i.model_dump() for i in self.inventory]
        return to_decimal(data)

    @classmethod
    def from_dynamo(cls, item: dict) -> "Shop":
        return cls(**from_decimal(item))
