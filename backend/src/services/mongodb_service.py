"""
MongoDB backend for local development (IS_OFFLINE).
Same interface as DynamoDBService so handlers can use either.
"""
import time
from typing import Optional

from pymongo import MongoClient, ASCENDING
from pymongo.errors import PyMongoError

from src.utils.config import config
from src.utils.logger import logger


def _collection_name(table_name: str) -> str:
    """Map DynamoDB table name to MongoDB collection (replace hyphens with underscores)."""
    return table_name.replace("-", "_")


class MongoDBService:
    """MongoDB implementation matching DynamoDBService interface for local dev."""

    def __init__(self):
        self._client = MongoClient(config.MONGODB_URI)
        self._db = self._client[f"gramsathi_{config.STAGE}"]
        self._ensure_indexes()

    def _collection(self, table_name: str):
        return self._db[_collection_name(table_name)]

    def _ensure_indexes(self) -> None:
        """Create indexes for query patterns (equivalent to DynamoDB GSIs)."""
        try:
            # conversations: query by userId
            self._collection(config.CONVERSATIONS_TABLE).create_index(
                [("userId", ASCENDING)],
                name="UserConversationsIndex",
            )
            # shops: query by pincode
            self._collection(config.SHOPS_TABLE).create_index(
                [("pincode", ASCENDING)],
                name="PincodeIndex",
            )
            # orders: query by userId and shopId
            self._collection(config.ORDERS_TABLE).create_index(
                [("userId", ASCENDING)],
                name="UserOrdersIndex",
            )
            self._collection(config.ORDERS_TABLE).create_index(
                [("shopId", ASCENDING)],
                name="ShopOrdersIndex",
            )
        except PyMongoError as e:
            logger.warning("mongodb_index_create", error=str(e))

    def _doc_from_item(self, item: dict) -> dict:
        """Prepare item for MongoDB (convert Decimal to float if needed)."""
        from decimal import Decimal

        def convert(v):
            if isinstance(v, Decimal):
                return float(v)
            if isinstance(v, dict):
                return {k: convert(x) for k, x in v.items()}
            if isinstance(v, list):
                return [convert(x) for x in v]
            return v

        return convert(item)

    def _doc_to_item(self, doc: Optional[dict]) -> Optional[dict]:
        """Convert MongoDB doc to format handlers expect (Decimal128 → float)."""
        if doc is None:
            return None
        try:
            from bson.decimal128 import Decimal128
        except ImportError:
            return doc

        def convert(v):
            if isinstance(v, (Decimal128,)):
                return float(v)
            from decimal import Decimal

            if isinstance(v, Decimal):
                return float(v)
            if isinstance(v, dict):
                return {k: convert(x) for k, x in v.items()}
            if isinstance(v, list):
                return [convert(x) for x in v]
            return v

        return convert(doc)

    # --- Domain helpers (same interface as DynamoDBService) ---

    def get_user(self, user_id: str) -> Optional[dict]:
        return self._doc_to_item(
            self._collection(config.USERS_TABLE).find_one({"userId": user_id})
        )

    def save_user(self, user: dict) -> None:
        self._collection(config.USERS_TABLE).replace_one(
            {"userId": user["userId"]}, self._doc_from_item(user), upsert=True
        )

    def get_conversation(self, conversation_id: str) -> Optional[dict]:
        return self._doc_to_item(
            self._collection(config.CONVERSATIONS_TABLE).find_one(
                {"conversationId": conversation_id}
            )
        )

    def save_conversation(self, conversation: dict) -> None:
        self._collection(config.CONVERSATIONS_TABLE).replace_one(
            {"conversationId": conversation["conversationId"]},
            self._doc_from_item(conversation),
            upsert=True,
        )

    def get_conversations_by_user(self, user_id: str) -> list:
        cursor = self._collection(config.CONVERSATIONS_TABLE).find(
            {"userId": user_id}
        ).sort("createdAt", -1)
        return [self._doc_to_item(d) for d in cursor]

    def get_shop(self, shop_id: str) -> Optional[dict]:
        return self._doc_to_item(
            self._collection(config.SHOPS_TABLE).find_one({"shopId": shop_id})
        )

    def save_shop(self, shop: dict) -> None:
        self._collection(config.SHOPS_TABLE).replace_one(
            {"shopId": shop["shopId"]}, self._doc_from_item(shop), upsert=True
        )

    def get_shops_by_pincode(self, pincode: str) -> list:
        cursor = self._collection(config.SHOPS_TABLE).find({"pincode": pincode})
        return [self._doc_to_item(d) for d in cursor]

    def save_order(self, order: dict) -> None:
        self._collection(config.ORDERS_TABLE).replace_one(
            {"orderId": order["orderId"]}, self._doc_from_item(order), upsert=True
        )

    def get_order(self, order_id: str) -> Optional[dict]:
        return self._doc_to_item(
            self._collection(config.ORDERS_TABLE).find_one({"orderId": order_id})
        )

    def get_orders_by_user(self, user_id: str) -> list:
        cursor = self._collection(config.ORDERS_TABLE).find(
            {"userId": user_id}
        ).sort("createdAt", -1)
        return [self._doc_to_item(d) for d in cursor]

    def get_orders_by_shop(self, shop_id: str) -> list:
        cursor = self._collection(config.ORDERS_TABLE).find(
            {"shopId": shop_id}
        ).sort("createdAt", -1)
        return [self._doc_to_item(d) for d in cursor]

    def get_response_cache(self, cache_key: str) -> Optional[str]:
        doc = self._collection(config.RESPONSE_CACHE_TABLE).find_one(
            {"cacheKey": cache_key}
        )
        if not doc:
            return None
        if int(doc.get("ttl", 0)) < int(time.time()):
            return None
        return doc.get("response")

    def set_response_cache(
        self, cache_key: str, response: str, language: str
    ) -> None:
        ttl = int(time.time()) + config.RESPONSE_CACHE_TTL_SECONDS
        self._collection(config.RESPONSE_CACHE_TABLE).replace_one(
            {"cacheKey": cache_key},
            {"cacheKey": cache_key, "response": response, "language": language, "ttl": ttl},
            upsert=True,
        )

    # --- Geo cache (Nominatim city → lat/lon, permanent) ---

    def get_geo_cache(self, location_key: str) -> Optional[dict]:
        return self._doc_to_item(
            self._collection(config.GEO_CACHE_TABLE).find_one({"locationKey": location_key})
        )

    def set_geo_cache(self, location_key: str, lat: float, lon: float) -> None:
        self._collection(config.GEO_CACHE_TABLE).replace_one(
            {"locationKey": location_key},
            {"locationKey": location_key, "lat": str(lat), "lon": str(lon)},
            upsert=True,
        )
