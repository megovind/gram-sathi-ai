from __future__ import annotations

from dataclasses import dataclass, field
from datetime import datetime, timezone
from enum import Enum
from typing import List, Optional

from src.utils.decimal_utils import from_decimal, to_decimal


class OrderStatus(str, Enum):
    PENDING = "pending"
    CONFIRMED = "confirmed"
    READY = "ready"
    DELIVERED = "delivered"
    CANCELLED = "cancelled"


@dataclass
class OrderItem:
    itemId: str
    name: str
    qty: int
    price: float

    def to_dict(self) -> dict:
        return {
            "itemId": self.itemId,
            "name": self.name,
            "qty": self.qty,
            "price": self.price,
        }


@dataclass
class Order:
    orderId: str
    userId: str
    shopId: str
    items: List[OrderItem]
    totalAmount: float
    status: OrderStatus = OrderStatus.PENDING
    deliveryAddress: Optional[str] = None
    notes: Optional[str] = None
    createdAt: str = field(default_factory=lambda: datetime.now(timezone.utc).isoformat())
    updatedAt: str = field(default_factory=lambda: datetime.now(timezone.utc).isoformat())

    def to_dynamo(self) -> dict:
        data = {
            "orderId": self.orderId,
            "userId": self.userId,
            "shopId": self.shopId,
            "items": [i.to_dict() for i in self.items],
            "totalAmount": self.totalAmount,
            "status": self.status.value if isinstance(self.status, Enum) else self.status,
            "deliveryAddress": self.deliveryAddress,
            "notes": self.notes,
            "createdAt": self.createdAt,
            "updatedAt": self.updatedAt,
        }
        return to_decimal(data)

    @classmethod
    def from_dynamo(cls, item: dict) -> "Order":
        item = from_decimal(item)
        items = [
            OrderItem(
                itemId=i["itemId"],
                name=i["name"],
                qty=int(i.get("qty", 0)),
                price=float(i.get("price", 0)),
            )
            for i in item.get("items", [])
        ]
        return cls(
            orderId=item["orderId"],
            userId=item["userId"],
            shopId=item["shopId"],
            items=items,
            totalAmount=float(item.get("totalAmount", 0)),
            status=OrderStatus(item.get("status", "pending")),
            deliveryAddress=item.get("deliveryAddress"),
            notes=item.get("notes"),
            createdAt=item.get("createdAt", datetime.now(timezone.utc).isoformat()),
            updatedAt=item.get("updatedAt", datetime.now(timezone.utc).isoformat()),
        )
