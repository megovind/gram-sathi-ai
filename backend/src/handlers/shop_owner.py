"""
Shop owner handler (US-13, US-14, US-15, US-16)

POST /shop                         – register a new shop (auth required)
GET  /shop/{shopId}                – get shop profile (public)
POST /shop/{shopId}/inventory      – upload / update inventory (auth + owner only)
GET  /shop/{shopId}/orders         – list incoming orders (auth + owner only)
GET  /shop/{shopId}/analytics      – basic daily analytics (auth + owner only)
"""
import uuid
from datetime import datetime, date, timezone

from src.models.shop import InventoryItem, Shop, ShopStatus
from src.services.database import db
from src.utils.auth import require_auth
from src.utils.constants import (
    DEFAULT_INVENTORY_UNIT,
    ERR_FORBIDDEN,
    ERR_FORBIDDEN_NOT_YOUR_SHOP,
    ERR_INVALID_ITEM_DATA,
    ERR_ITEM_PRICE_NEGATIVE,
    ERR_ITEMS_LIST_REQUIRED,
    ERR_MISSING_FIELDS,
    ERR_ROUTE_NOT_FOUND,
    ERR_SHOP_ID_REQUIRED,
    ERR_SHOP_NOT_FOUND,
    ERR_STOCK_QTY_NEGATIVE,
    MSG_SHOP_REGISTERED,
    ORDER_STATUS_PENDING,
    PRIVATE_SHOP_FIELDS,
)
from src.utils.response import error, ok, parse_body


def handler(event: dict, context) -> dict:
    method = event.get("httpMethod", "GET")
    path = event.get("path", "")
    params = event.get("pathParameters") or {}
    shop_id = params.get("shopId", "")

    if method == "POST" and path.endswith("/shop"):
        return _register_shop(event)
    if method == "GET" and shop_id and not path.endswith(("/orders", "/analytics", "/inventory")):
        return _get_shop(shop_id)  # public
    if method == "POST" and path.endswith("/inventory"):
        return _update_inventory(event, shop_id)
    if method == "GET" and path.endswith("/orders"):
        return _get_orders(event, shop_id)
    if method == "GET" and path.endswith("/analytics"):
        return _get_analytics(event, shop_id)

    return error(ERR_ROUTE_NOT_FOUND, 404)


def _register_shop(event: dict) -> dict:
    """Register a new shop (US-13). ownerId comes from JWT."""
    user_id, auth_err = require_auth(event)
    if auth_err:
        return auth_err

    body = parse_body(event)
    required = ["name", "ownerName", "phone", "pincode"]
    missing = [f for f in required if not body.get(f)]
    if missing:
        return error(ERR_MISSING_FIELDS.format(', '.join(missing)), 400)

    shop = Shop(
        shopId=str(uuid.uuid4()),
        ownerId=user_id,  # from JWT — not from body
        name=body["name"],
        ownerName=body["ownerName"],
        phone=body["phone"],
        pincode=body["pincode"],
        address=body.get("address"),
        lat=body.get("lat"),
        lng=body.get("lng"),
        status=ShopStatus.PENDING,
    )
    db.save_shop(shop.to_dynamo())

    return ok({
        "shopId": shop.shopId,
        "status": shop.status.value,
        "message": MSG_SHOP_REGISTERED,
    }, status_code=201)


def _get_shop(shop_id: str) -> dict:
    """Public endpoint — anyone can view an approved shop."""
    shop = db.get_shop(shop_id)
    if not shop:
        return error(ERR_SHOP_NOT_FOUND, 404)
    public_shop = {k: v for k, v in shop.items() if k not in PRIVATE_SHOP_FIELDS}
    return ok(public_shop)


def _update_inventory(event: dict, shop_id: str) -> dict:
    """Upload / merge inventory items (US-14). Only the shop owner can update."""
    user_id, auth_err = require_auth(event)
    if auth_err:
        return auth_err

    if not shop_id:
        return error(ERR_SHOP_ID_REQUIRED, 400)

    shop_data = db.get_shop(shop_id)
    if not shop_data:
        return error(ERR_SHOP_NOT_FOUND, 404)

    if shop_data.get("ownerId") != user_id:
        return error(ERR_FORBIDDEN_NOT_YOUR_SHOP, 403)

    body = parse_body(event)
    items_raw: list = body.get("items", [])
    replace: bool = body.get("replace", False)

    if not items_raw:
        return error(ERR_ITEMS_LIST_REQUIRED, 400)

    try:
        new_items = [
            InventoryItem(
                itemId=i.get("itemId", str(uuid.uuid4())),
                name=i["name"],
                nameHindi=i.get("nameHindi"),
                price=float(i["price"]),
                unit=i.get("unit", DEFAULT_INVENTORY_UNIT),
                stockQty=int(i.get("stockQty", 0)),
                category=i.get("category"),
            )
            for i in items_raw
        ]
    except (KeyError, ValueError) as exc:
        return error(ERR_INVALID_ITEM_DATA.format(str(exc)), 400)

    if any(item.price < 0 for item in new_items):
        return error(ERR_ITEM_PRICE_NEGATIVE, 400)
    if any(item.stockQty < 0 for item in new_items):
        return error(ERR_STOCK_QTY_NEGATIVE, 400)

    shop = Shop.from_dynamo(shop_data)
    if replace:
        shop.inventory = new_items
    else:
        existing_map = {item.itemId: item for item in shop.inventory}
        for item in new_items:
            existing_map[item.itemId] = item
        shop.inventory = list(existing_map.values())

    shop.updatedAt = datetime.now(timezone.utc).isoformat()
    db.save_shop(shop.to_dynamo())

    return ok({"shopId": shop_id, "itemCount": len(shop.inventory)})


def _get_orders(event: dict, shop_id: str) -> dict:
    """Return all orders for this shop. Only the owner can view (US-15)."""
    user_id, auth_err = require_auth(event)
    if auth_err:
        return auth_err

    if not shop_id:
        return error(ERR_SHOP_ID_REQUIRED, 400)

    shop_data = db.get_shop(shop_id)
    if not shop_data:
        return error(ERR_SHOP_NOT_FOUND, 404)
    if shop_data.get("ownerId") != user_id:
        return error(ERR_FORBIDDEN, 403)

    orders = db.get_orders_by_shop(shop_id)
    return ok({"shopId": shop_id, "orders": orders})


def _get_analytics(event: dict, shop_id: str) -> dict:
    """Daily analytics — owner only (US-16)."""
    user_id, auth_err = require_auth(event)
    if auth_err:
        return auth_err

    if not shop_id:
        return error(ERR_SHOP_ID_REQUIRED, 400)

    shop_data = db.get_shop(shop_id)
    if not shop_data:
        return error(ERR_SHOP_NOT_FOUND, 404)
    if shop_data.get("ownerId") != user_id:
        return error(ERR_FORBIDDEN, 403)

    orders = db.get_orders_by_shop(shop_id)
    today = date.today().isoformat()
    today_orders = [o for o in orders if o.get("createdAt", "").startswith(today)]
    total_revenue = sum(o.get("totalAmount", 0) for o in today_orders)
    pending_count = sum(1 for o in orders if o.get("status") == ORDER_STATUS_PENDING)

    return ok({
        "shopId": shop_id,
        "today": {
            "orderCount": len(today_orders),
            "revenue": round(total_revenue, 2),
        },
        "allTime": {
            "orderCount": len(orders),
            "pendingOrders": pending_count,
        },
    })
