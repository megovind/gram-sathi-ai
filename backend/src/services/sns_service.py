import boto3
import json
from src.utils.config import config


class SNSService:
    def __init__(self):
        self._client = boto3.client("sns", region_name=config.AWS_REGION)

    def notify_shop_new_order(self, shop_phone: str, order: dict) -> None:
        """Send an SMS/push notification to the shop owner when a new order arrives (US-15)."""
        items_text = ", ".join(
            f"{item['name']} x{item['qty']}" for item in order.get("items", [])
        )
        message = (
            f"GramSathi: नया ऑर्डर आया है!\n"
            f"Order ID: {order.get('orderId', '')}\n"
            f"Items: {items_text}\n"
            f"Total: ₹{order.get('totalAmount', 0)}"
        )
        # In production, use a registered SNS topic per shop or AWS SNS SMS
        self._client.publish(
            PhoneNumber=f"+91{shop_phone}",
            Message=message,
            MessageAttributes={
                "AWS.SNS.SMS.SMSType": {
                    "DataType": "String",
                    "StringValue": "Transactional",
                }
            },
        )

    def notify_user_order_confirmed(self, user_phone: str, order_id: str) -> None:
        """Notify the user that their order was confirmed (US-12)."""
        message = (
            f"GramSathi: आपका ऑर्डर #{order_id} कन्फर्म हो गया। "
            f"दुकानदार जल्द ही तैयार करेगा।"
        )
        self._client.publish(
            PhoneNumber=f"+91{user_phone}",
            Message=message,
            MessageAttributes={
                "AWS.SNS.SMS.SMSType": {
                    "DataType": "String",
                    "StringValue": "Transactional",
                }
            },
        )


sns = SNSService()
