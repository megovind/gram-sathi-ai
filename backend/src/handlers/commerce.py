"""
Commerce handler (US-10, US-11, US-12)

POST /commerce/shops        – discover nearby local shops (public)
POST /commerce/order        – place an order (auth required)
GET  /commerce/order/{id}   – get order status (auth required)
"""
import uuid
from datetime import datetime, timezone

from src.models.order import Order, OrderItem, OrderStatus
from src.services.dynamodb_service import dynamo
from src.services.sns_service import sns
from src.utils.auth import require_auth
from src.utils.config import config
from src.utils.logger import logger
from src.utils.response import error, ok, parse_body


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

    return error("Route not found", 404)


def _discover_shops(event: dict) -> dict:
    """Public — no auth needed to browse shops (US-10)."""
    body = parse_body(event)
    pincode: str = body.get("pincode", "")
    category: str = body.get("category", "")

    if not pincode:
        return error("pincode is required", 400)

    shops = dynamo.get_shops_by_pincode(pincode)
    shops = [s for s in shops if s.get("status") == "approved"]
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
        return error("shopId and items are required", 400)
    if len(items_raw) > config.MAX_ORDER_ITEMS:
        return error(f"Too many items (max {config.MAX_ORDER_ITEMS})", 400)

    shop = dynamo.get_shop(shop_id)
    if not shop:
        return error("Shop not found", 404)

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
        return error(f"Invalid item data: {str(exc)}", 400)

    total = sum(item.qty * item.price for item in order_items)
    now = datetime.now(timezone.utc).isoformat()

    order = Order(
        orderId=str(uuid.uuid4()),
        userId=user_id,
        shopId=shop_id,
        items=order_items,
        totalAmount=round(total, 2),
        deliveryAddress=delivery_address,
        notes=notes,
        createdAt=now,
        updatedAt=now,
    )
    dynamo.save_order(order.to_dynamo())
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
        "message": f"ऑर्डर #{order.orderId[:8]} कन्फर्म हो गया।",
    }, status_code=201)


def _get_order(event: dict, order_id: str) -> dict:
    user_id, auth_err = require_auth(event)
    if auth_err:
        return auth_err

    if not order_id:
        return error("orderId is required", 400)

    order = dynamo.get_order(order_id)
    if not order:
        return error("Order not found", 404)

    # Users can only see their own orders
    if order.get("userId") != user_id:
        return error("Forbidden", 403)

    return ok(order)
