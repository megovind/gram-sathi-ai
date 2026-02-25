from __future__ import annotations

from decimal import Decimal
from enum import Enum
from typing import List, Optional
from pydantic import BaseModel, Field
from datetime import datetime, timezone

from src.utils.decimal_utils import from_decimal, to_decimal


class OrderStatus(str, Enum):
    PENDING = "pending"
    CONFIRMED = "confirmed"
    READY = "ready"
    DELIVERED = "delivered"
    CANCELLED = "cancelled"


class OrderItem(BaseModel):
    itemId: str
    name: str
    qty: int
    price: float


class Order(BaseModel):
    orderId: str
    userId: str
    shopId: str
    items: List[OrderItem]
    totalAmount: float
    status: OrderStatus = OrderStatus.PENDING
    deliveryAddress: Optional[str] = None
    notes: Optional[str] = None
    createdAt: str = Field(default_factory=lambda: datetime.now(timezone.utc).isoformat())
    updatedAt: str = Field(default_factory=lambda: datetime.now(timezone.utc).isoformat())

    def to_dynamo(self) -> dict:
        data = self.model_dump()
        data["items"] = [i.model_dump() for i in self.items]
        return to_decimal(data)

    @classmethod
    def from_dynamo(cls, item: dict) -> "Order":
        return cls(**from_decimal(item))
