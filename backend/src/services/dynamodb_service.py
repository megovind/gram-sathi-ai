import time
import boto3
from boto3.dynamodb.conditions import Key
from typing import Any, Optional
from src.utils.config import config


class DynamoDBService:
    def __init__(self):
        self._resource = boto3.resource("dynamodb", region_name=config.AWS_REGION)

    def _table(self, table_name: str):
        return self._resource.Table(table_name)

    # --- Generic CRUD ---

    def put_item(self, table_name: str, item: dict) -> None:
        self._table(table_name).put_item(Item=item)

    def get_item(self, table_name: str, key: dict) -> Optional[dict]:
        response = self._table(table_name).get_item(Key=key)
        return response.get("Item")

    def update_item(
        self,
        table_name: str,
        key: dict,
        update_expression: str,
        expression_values: dict,
        expression_names: Optional[dict] = None,
    ) -> dict:
        kwargs: dict[str, Any] = {
            "Key": key,
            "UpdateExpression": update_expression,
            "ExpressionAttributeValues": expression_values,
            "ReturnValues": "ALL_NEW",
        }
        if expression_names:
            kwargs["ExpressionAttributeNames"] = expression_names
        response = self._table(table_name).update_item(**kwargs)
        return response.get("Attributes", {})

    def delete_item(self, table_name: str, key: dict) -> None:
        self._table(table_name).delete_item(Key=key)

    def query_by_index(
        self,
        table_name: str,
        index_name: str,
        key_name: str,
        key_value: str,
    ) -> list[dict]:
        response = self._table(table_name).query(
            IndexName=index_name,
            KeyConditionExpression=Key(key_name).eq(key_value),
        )
        return response.get("Items", [])

    # --- Domain helpers ---

    def get_user(self, user_id: str) -> Optional[dict]:
        return self.get_item(config.USERS_TABLE, {"userId": user_id})

    def save_user(self, user: dict) -> None:
        self.put_item(config.USERS_TABLE, user)

    def get_conversation(self, conversation_id: str) -> Optional[dict]:
        return self.get_item(config.CONVERSATIONS_TABLE, {"conversationId": conversation_id})

    def save_conversation(self, conversation: dict) -> None:
        self.put_item(config.CONVERSATIONS_TABLE, conversation)

    def get_conversations_by_user(self, user_id: str) -> list[dict]:
        return self.query_by_index(
            config.CONVERSATIONS_TABLE, "UserConversationsIndex", "userId", user_id
        )

    def get_shop(self, shop_id: str) -> Optional[dict]:
        return self.get_item(config.SHOPS_TABLE, {"shopId": shop_id})

    def save_shop(self, shop: dict) -> None:
        self.put_item(config.SHOPS_TABLE, shop)

    def get_shops_by_pincode(self, pincode: str) -> list[dict]:
        return self.query_by_index(
            config.SHOPS_TABLE, "PincodeIndex", "pincode", pincode
        )

    def save_order(self, order: dict) -> None:
        self.put_item(config.ORDERS_TABLE, order)

    def get_order(self, order_id: str) -> Optional[dict]:
        return self.get_item(config.ORDERS_TABLE, {"orderId": order_id})

    def get_orders_by_user(self, user_id: str) -> list[dict]:
        return self.query_by_index(
            config.ORDERS_TABLE, "UserOrdersIndex", "userId", user_id
        )

    def get_orders_by_shop(self, shop_id: str) -> list[dict]:
        return self.query_by_index(
            config.ORDERS_TABLE, "ShopOrdersIndex", "shopId", shop_id
        )

    # --- Response cache (health query deduplication) ---

    def get_response_cache(self, cache_key: str) -> Optional[str]:
        """Return cached AI response text if still valid, else None."""
        item = self.get_item(config.RESPONSE_CACHE_TABLE, {"cacheKey": cache_key})
        if not item:
            return None
        # DynamoDB TTL deletion is eventual — double-check client-side
        if int(item.get("ttl", 0)) < int(time.time()):
            return None
        return item.get("response")

    def set_response_cache(self, cache_key: str, response: str, language: str) -> None:
        """Cache an AI response for RESPONSE_CACHE_TTL_SECONDS seconds."""
        ttl = int(time.time()) + config.RESPONSE_CACHE_TTL_SECONDS
        self.put_item(
            config.RESPONSE_CACHE_TABLE,
            {"cacheKey": cache_key, "response": response, "language": language, "ttl": ttl},
        )


dynamo = DynamoDBService()
