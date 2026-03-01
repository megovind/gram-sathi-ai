import json
import pytest
import boto3
from moto import mock_aws

from src.utils.config import config
from src.utils.auth import create_token


@pytest.fixture(autouse=True)
def aws_credentials(monkeypatch):
    monkeypatch.setenv("AWS_ACCESS_KEY_ID", "testing")
    monkeypatch.setenv("AWS_SECRET_ACCESS_KEY", "testing")
    monkeypatch.setenv("AWS_SECURITY_TOKEN", "testing")
    monkeypatch.setenv("AWS_SESSION_TOKEN", "testing")
    monkeypatch.setenv("AWS_DEFAULT_REGION", "ap-south-1")


@pytest.fixture
def dynamo_tables():
    with mock_aws():
        client = boto3.client("dynamodb", region_name="ap-south-1")
        for table_name, pk in [
            (config.SHOPS_TABLE, "shopId"),
            (config.ORDERS_TABLE, "orderId"),
        ]:
            client.create_table(
                TableName=table_name,
                BillingMode="PAY_PER_REQUEST",
                AttributeDefinitions=[{"AttributeName": pk, "AttributeType": "S"},
                                       {"AttributeName": "pincode" if pk == "shopId" else "userId", "AttributeType": "S"}],
                KeySchema=[{"AttributeName": pk, "KeyType": "HASH"}],
                GlobalSecondaryIndexes=[{
                    "IndexName": "PincodeIndex" if pk == "shopId" else "UserOrdersIndex",
                    "KeySchema": [{"AttributeName": "pincode" if pk == "shopId" else "userId", "KeyType": "HASH"}],
                    "Projection": {"ProjectionType": "ALL"},
                }],
            )
        yield


def _auth_headers(user_id="user-test"):
    return {"Authorization": f"Bearer {create_token(user_id)}"}


def _post(path, body, user_id=None):
    event = {
        "httpMethod": "POST",
        "path": path,
        "body": json.dumps(body),
    }
    if user_id:
        event["headers"] = _auth_headers(user_id)
    return event


@mock_aws
def test_discover_shops_no_auth_needed(dynamo_tables):
    from src.handlers.commerce import handler
    event = _post("/commerce/shops", {"pincode": "110001"})
    resp = handler(event, None)
    assert resp["statusCode"] == 200
    body = json.loads(resp["body"])
    assert "shops" in body


@mock_aws
def test_discover_shops_missing_pincode(dynamo_tables):
    from src.handlers.commerce import handler
    event = _post("/commerce/shops", {})
    resp = handler(event, None)
    assert resp["statusCode"] == 400


@mock_aws
def test_place_order_requires_auth(dynamo_tables):
    from src.handlers.commerce import handler
    event = _post("/commerce/order", {"shopId": "s1", "items": []})
    resp = handler(event, None)
    assert resp["statusCode"] == 401


@mock_aws
def test_place_order_shop_not_found(dynamo_tables):
    from src.handlers.commerce import handler
    event = _post(
        "/commerce/order",
        {"shopId": "nonexistent", "items": [{"itemId": "i1", "name": "Atta", "qty": 1, "price": 50}]},
        user_id="user-1",
    )
    resp = handler(event, None)
    assert resp["statusCode"] == 404


@mock_aws
def test_place_order_success(dynamo_tables, monkeypatch):
    # Seed an approved shop
    from src.services.database import db
    from src.handlers.commerce import handler

    db.save_shop({
        "shopId": "shop-001",
        "ownerId": "owner-1",
        "name": "Ramu Kirana",
        "ownerName": "Ramu",
        "phone": "9000000000",
        "pincode": "110001",
        "status": "approved",
        "inventory": [],
        "createdAt": "2024-01-01",
        "updatedAt": "2024-01-01",
    })

    # Patch SNS to avoid real call
    monkeypatch.setattr("src.handlers.commerce.sns.notify_shop_new_order", lambda *a, **kw: None)

    event = _post(
        "/commerce/order",
        {
            "shopId": "shop-001",
            "items": [{"itemId": "i1", "name": "Atta 5kg", "qty": 2, "price": 120}],
        },
        user_id="user-1",
    )
    resp = handler(event, None)
    assert resp["statusCode"] == 201
    body = json.loads(resp["body"])
    assert "orderId" in body
    assert body["totalAmount"] == 240.0
