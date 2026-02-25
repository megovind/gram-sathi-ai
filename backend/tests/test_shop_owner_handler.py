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
        client.create_table(
            TableName=config.SHOPS_TABLE,
            BillingMode="PAY_PER_REQUEST",
            AttributeDefinitions=[
                {"AttributeName": "shopId", "AttributeType": "S"},
                {"AttributeName": "pincode", "AttributeType": "S"},
            ],
            KeySchema=[{"AttributeName": "shopId", "KeyType": "HASH"}],
            GlobalSecondaryIndexes=[{
                "IndexName": "PincodeIndex",
                "KeySchema": [{"AttributeName": "pincode", "KeyType": "HASH"}],
                "Projection": {"ProjectionType": "ALL"},
            }],
        )
        client.create_table(
            TableName=config.ORDERS_TABLE,
            BillingMode="PAY_PER_REQUEST",
            AttributeDefinitions=[
                {"AttributeName": "orderId", "AttributeType": "S"},
                {"AttributeName": "shopId", "AttributeType": "S"},
            ],
            KeySchema=[{"AttributeName": "orderId", "KeyType": "HASH"}],
            GlobalSecondaryIndexes=[{
                "IndexName": "ShopOrdersIndex",
                "KeySchema": [{"AttributeName": "shopId", "KeyType": "HASH"}],
                "Projection": {"ProjectionType": "ALL"},
            }],
        )
        yield


def _event(method, path, body=None, user_id=None, path_params=None):
    e = {"httpMethod": method, "path": path, "pathParameters": path_params or {}}
    if body is not None:
        e["body"] = json.dumps(body)
    if user_id:
        e["headers"] = {"Authorization": f"Bearer {create_token(user_id)}"}
    return e


# ── Registration ───────────────────────────────────────────────────────────────

@mock_aws
def test_register_shop_requires_auth(dynamo_tables):
    from src.handlers.shop_owner import handler
    event = _event("POST", "/shop", {"name": "Ramu", "ownerName": "Ramu", "phone": "9000000001", "pincode": "110001"})
    resp = handler(event, None)
    assert resp["statusCode"] == 401


@mock_aws
def test_register_shop_success(dynamo_tables):
    from src.handlers.shop_owner import handler
    event = _event("POST", "/shop",
                   {"name": "Ramu Kirana", "ownerName": "Ramu Lal", "phone": "9000000001", "pincode": "110001"},
                   user_id="owner-1")
    resp = handler(event, None)
    assert resp["statusCode"] == 201
    body = json.loads(resp["body"])
    assert "shopId" in body
    assert body["status"] == "pending"


@mock_aws
def test_register_shop_missing_fields(dynamo_tables):
    from src.handlers.shop_owner import handler
    event = _event("POST", "/shop", {"name": "incomplete"}, user_id="owner-1")
    resp = handler(event, None)
    assert resp["statusCode"] == 400


# ── Get shop (public) ──────────────────────────────────────────────────────────

@mock_aws
def test_get_shop_not_found(dynamo_tables):
    from src.handlers.shop_owner import handler
    event = _event("GET", "/shop/nonexistent", path_params={"shopId": "nonexistent"})
    resp = handler(event, None)
    assert resp["statusCode"] == 404


@mock_aws
def test_get_shop_found(dynamo_tables):
    from src.handlers.shop_owner import handler
    reg = _event("POST", "/shop",
                 {"name": "Test Shop", "ownerName": "Owner", "phone": "9000000002", "pincode": "110002"},
                 user_id="owner-2")
    shop_id = json.loads(handler(reg, None)["body"])["shopId"]

    event = _event("GET", f"/shop/{shop_id}", path_params={"shopId": shop_id})
    resp = handler(event, None)
    assert resp["statusCode"] == 200
    assert json.loads(resp["body"])["name"] == "Test Shop"


# ── Inventory ──────────────────────────────────────────────────────────────────

@mock_aws
def test_update_inventory_owner_only(dynamo_tables):
    from src.handlers.shop_owner import handler
    reg = _event("POST", "/shop",
                 {"name": "Shop A", "ownerName": "A", "phone": "9000000003", "pincode": "110003"},
                 user_id="owner-3")
    shop_id = json.loads(handler(reg, None)["body"])["shopId"]

    # Another user tries to update inventory
    event = _event("POST", f"/shop/{shop_id}/inventory",
                   {"items": [{"name": "Rice", "price": 50}]},
                   user_id="attacker-99",
                   path_params={"shopId": shop_id})
    resp = handler(event, None)
    assert resp["statusCode"] == 403


@mock_aws
def test_update_inventory_success(dynamo_tables):
    from src.handlers.shop_owner import handler
    reg = _event("POST", "/shop",
                 {"name": "Shop B", "ownerName": "B", "phone": "9000000004", "pincode": "110004"},
                 user_id="owner-4")
    shop_id = json.loads(handler(reg, None)["body"])["shopId"]

    items = [
        {"name": "Atta", "nameHindi": "आटा", "price": 45, "unit": "kg", "stockQty": 100},
        {"name": "Salt", "nameHindi": "नमक", "price": 20, "unit": "kg", "stockQty": 50},
    ]
    event = _event("POST", f"/shop/{shop_id}/inventory",
                   {"items": items},
                   user_id="owner-4",
                   path_params={"shopId": shop_id})
    resp = handler(event, None)
    assert resp["statusCode"] == 200
    assert json.loads(resp["body"])["itemCount"] == 2


# ── Analytics ──────────────────────────────────────────────────────────────────

@mock_aws
def test_analytics_requires_auth(dynamo_tables):
    from src.handlers.shop_owner import handler
    event = _event("GET", "/shop/shop-x/analytics", path_params={"shopId": "shop-x"})
    resp = handler(event, None)
    assert resp["statusCode"] == 401


@mock_aws
def test_analytics_returns_zeros_for_new_shop(dynamo_tables):
    from src.handlers.shop_owner import handler
    reg = _event("POST", "/shop",
                 {"name": "Shop C", "ownerName": "C", "phone": "9000000005", "pincode": "110005"},
                 user_id="owner-5")
    shop_id = json.loads(handler(reg, None)["body"])["shopId"]

    event = _event("GET", f"/shop/{shop_id}/analytics",
                   user_id="owner-5",
                   path_params={"shopId": shop_id})
    resp = handler(event, None)
    assert resp["statusCode"] == 200
    body = json.loads(resp["body"])
    assert body["today"]["orderCount"] == 0
    assert body["allTime"]["orderCount"] == 0
