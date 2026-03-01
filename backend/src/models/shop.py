from __future__ import annotations

from dataclasses import dataclass, field
from datetime import datetime, timezone
from enum import Enum
from typing import List, Optional

from src.utils.decimal_utils import from_decimal, to_decimal


class ShopStatus(str, Enum):
    PENDING = "pending"
    APPROVED = "approved"
    SUSPENDED = "suspended"


@dataclass
class InventoryItem:
    itemId: str
    name: str
    price: float
    nameHindi: Optional[str] = None
    unit: str = "piece"
    stockQty: int = 0
    category: Optional[str] = None

    def to_dict(self) -> dict:
        return {
            "itemId": self.itemId,
            "name": self.name,
            "nameHindi": self.nameHindi,
            "price": self.price,
            "unit": self.unit,
            "stockQty": self.stockQty,
            "category": self.category,
        }


@dataclass
class Shop:
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
    inventory: List[InventoryItem] = field(default_factory=list)
    createdAt: str = field(default_factory=lambda: datetime.now(timezone.utc).isoformat())
    updatedAt: str = field(default_factory=lambda: datetime.now(timezone.utc).isoformat())

    def to_dynamo(self) -> dict:
        data = {
            "shopId": self.shopId,
            "ownerId": self.ownerId,
            "name": self.name,
            "ownerName": self.ownerName,
            "phone": self.phone,
            "pincode": self.pincode,
            "address": self.address,
            "lat": self.lat,
            "lng": self.lng,
            "status": self.status.value if isinstance(self.status, Enum) else self.status,
            "inventory": [i.to_dict() for i in self.inventory],
            "createdAt": self.createdAt,
            "updatedAt": self.updatedAt,
        }
        return to_decimal(data)

    @classmethod
    def from_dynamo(cls, item: dict) -> "Shop":
        item = from_decimal(item)
        inventory = [
            InventoryItem(
                itemId=i["itemId"],
                name=i["name"],
                price=float(i.get("price", 0)),
                nameHindi=i.get("nameHindi"),
                unit=i.get("unit", "piece"),
                stockQty=int(i.get("stockQty", 0)),
                category=i.get("category"),
            )
            for i in item.get("inventory", [])
        ]
        return cls(
            shopId=item["shopId"],
            ownerId=item["ownerId"],
            name=item["name"],
            ownerName=item["ownerName"],
            phone=item["phone"],
            pincode=item["pincode"],
            address=item.get("address"),
            lat=item.get("lat"),
            lng=item.get("lng"),
            status=ShopStatus(item.get("status", "pending")),
            inventory=inventory,
            createdAt=item.get("createdAt", datetime.now(timezone.utc).isoformat()),
            updatedAt=item.get("updatedAt", datetime.now(timezone.utc).isoformat()),
        )
