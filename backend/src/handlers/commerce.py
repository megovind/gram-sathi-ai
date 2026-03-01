"""
Commerce handler (US-10, US-11, US-12)

POST /commerce/shops        – discover nearby local shops (public)
POST /commerce/order        – place an order (auth required)
GET  /commerce/order/{id}   – get order status (auth required)
"""
import re
import uuid
from datetime import datetime, timezone
from decimal import Decimal, ROUND_HALF_UP

from src.models.order import Order, OrderItem, OrderStatus
from src.services.database import db
from src.services.sns_service import sns
from src.utils.auth import require_auth
from src.utils.config import config
from src.utils.constants import (
    ERR_FORBIDDEN,
    ERR_INVALID_ITEM_DATA,
    ERR_ITEM_PRICE_NEGATIVE,
    ERR_ITEM_QTY_POSITIVE,
    ERR_ORDER_ID_REQUIRED,
    ERR_ORDER_NOT_FOUND,
    ERR_PINCODE_FORMAT,
    ERR_PINCODE_REQUIRED,
    ERR_ROUTE_NOT_FOUND,
    ERR_SHOP_ID_AND_ITEMS_REQUIRED,
    ERR_SHOP_NOT_FOUND,
    ERR_TOO_MANY_ITEMS,
    MSG_ORDER_CONFIRMED,
    ORDER_ID_DISPLAY_LEN,
    SHOP_STATUS_APPROVED,
)
from src.utils.logger import logger
from src.utils.response import error, ok, parse_body

_PINCODE_RE = re.compile(r"^\d{6}$")


def handler(event: dict, context) -> dict:
    method = event.get("httpMethod", "GET")
    path = event.get("path", "")

    if method == "POST" and path.endswith("/shops"):
        return _discover_shops(event)
    if method == "POST" and path.endswith("/order"):
        return _place_order(event)
    if method == "GET" and "/order/" in path:
        order_id = (event.get("pathParameters") or {}).get("orderId", "")
        return _get_order(event, order_id)

    return error(ERR_ROUTE_NOT_FOUND, 404)


def _discover_shops(event: dict) -> dict:
    """Public — no auth needed to browse shops (US-10)."""
    body = parse_body(event)
    pincode: str = body.get("pincode", "").strip()
    category: str = body.get("category", "")

    if not pincode:
        return error(ERR_PINCODE_REQUIRED, 400)
    if not _PINCODE_RE.match(pincode):
        return error(ERR_PINCODE_FORMAT, 400)

    shops = db.get_shops_by_pincode(pincode)
    shops = [s for s in shops if s.get("status") == SHOP_STATUS_APPROVED]
    if category:
        shops = [s for s in shops if s.get("category") == category]

    return ok({"pincode": pincode, "shops": shops})


def _place_order(event: dict) -> dict:
    """Authenticated — place an order (US-11, US-12)."""
    user_id, auth_err = require_auth(event)
    if auth_err:
        return auth_err

    body = parse_body(event)
    shop_id: str = body.get("shopId", "")
    items_raw: list = body.get("items", [])
    delivery_address: str = body.get("deliveryAddress", "")
    notes: str = body.get("notes", "")

    if not shop_id or not items_raw:
        return error(ERR_SHOP_ID_AND_ITEMS_REQUIRED, 400)
    if len(items_raw) > config.MAX_ORDER_ITEMS:
        return error(ERR_TOO_MANY_ITEMS.format(config.MAX_ORDER_ITEMS), 400)

    shop = db.get_shop(shop_id)
    if not shop:
        return error(ERR_SHOP_NOT_FOUND, 404)

    try:
        order_items = [
            OrderItem(
                itemId=i["itemId"],
                name=i["name"],
                qty=int(i["qty"]),
                price=float(i["price"]),
            )
            for i in items_raw
        ]
    except (KeyError, ValueError) as exc:
        return error(ERR_INVALID_ITEM_DATA.format(str(exc)), 400)

    if any(item.qty <= 0 for item in order_items):
        return error(ERR_ITEM_QTY_POSITIVE, 400)
    if any(item.price < 0 for item in order_items):
        return error(ERR_ITEM_PRICE_NEGATIVE, 400)

    # Use Decimal arithmetic to avoid float rounding errors on currency
    total = float(
        sum(
            Decimal(str(item.qty)) * Decimal(str(item.price))
            for item in order_items
        ).quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)
    )
    now = datetime.now(timezone.utc).isoformat()

    order = Order(
        orderId=str(uuid.uuid4()),
        userId=user_id,
        shopId=shop_id,
        items=order_items,
        totalAmount=total,
        deliveryAddress=delivery_address,
        notes=notes,
        createdAt=now,
        updatedAt=now,
    )
    db.save_order(order.to_dynamo())
    logger.info("order_placed", user_id=user_id, shop_id=shop_id,
                order_id=order.orderId, total=order.totalAmount)

    try:
        if shop.get("phone"):
            sns.notify_shop_new_order(shop["phone"], order.to_dynamo())
    except Exception:
        pass

    return ok({
        "orderId": order.orderId,
        "status": order.status.value,
        "totalAmount": order.totalAmount,
        "message": MSG_ORDER_CONFIRMED.format(order.orderId[:ORDER_ID_DISPLAY_LEN]),
    }, status_code=201)


def _get_order(event: dict, order_id: str) -> dict:
    user_id, auth_err = require_auth(event)
    if auth_err:
        return auth_err

    if not order_id:
        return error(ERR_ORDER_ID_REQUIRED, 400)

    order = db.get_order(order_id)
    if not order:
        return error(ERR_ORDER_NOT_FOUND, 404)

    # Users can only see their own orders
    if order.get("userId") != user_id:
        return error(ERR_FORBIDDEN, 403)

    return ok(order)
