import json
import pytest
import boto3
from moto import mock_aws
from unittest.mock import patch

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
            TableName=config.CONVERSATIONS_TABLE,
            BillingMode="PAY_PER_REQUEST",
            AttributeDefinitions=[
                {"AttributeName": "conversationId", "AttributeType": "S"},
                {"AttributeName": "userId", "AttributeType": "S"},
            ],
            KeySchema=[{"AttributeName": "conversationId", "KeyType": "HASH"}],
            GlobalSecondaryIndexes=[{
                "IndexName": "UserConversationsIndex",
                "KeySchema": [{"AttributeName": "userId", "KeyType": "HASH"}],
                "Projection": {"ProjectionType": "ALL"},
            }],
        )
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
            TableName=config.RESPONSE_CACHE_TABLE,
            BillingMode="PAY_PER_REQUEST",
            AttributeDefinitions=[{"AttributeName": "cacheKey", "AttributeType": "S"}],
            KeySchema=[{"AttributeName": "cacheKey", "KeyType": "HASH"}],
        )
        yield


def _auth_event(path, body, user_id="user-health-test"):
    return {
        "httpMethod": "POST",
        "path": path,
        "headers": {"Authorization": f"Bearer {create_token(user_id)}"},
        "body": json.dumps(body),
    }


def _public_event(path, body):
    return {"httpMethod": "POST", "path": path, "body": json.dumps(body)}


# ── /health/query ──────────────────────────────────────────────────────────────

@mock_aws
def test_health_query_requires_auth(dynamo_tables):
    from src.handlers.health import handler
    event = {"httpMethod": "POST", "path": "/health/query", "body": json.dumps({"text": "fever"})}
    resp = handler(event, None)
    assert resp["statusCode"] == 401


@mock_aws
def test_health_query_missing_text(dynamo_tables):
    from src.handlers.health import handler
    event = _auth_event("/health/query", {})
    resp = handler(event, None)
    assert resp["statusCode"] == 400


@mock_aws
def test_health_query_normal_response(dynamo_tables, monkeypatch):
    from src.handlers.health import handler
    # Mock module-level fast detector (non-emergency text)
    monkeypatch.setattr("src.handlers.health.detect_red_flags_fast", lambda _: False)
    monkeypatch.setattr("src.handlers.health.bedrock.chat", lambda *a, **kw: "पानी पिएं और आराम करें।")
    monkeypatch.setattr("src.handlers.health.polly.synthesize", lambda *a, **kw: "https://audio.url/reply.mp3")

    event = _auth_event("/health/query", {"text": "मुझे बुखार है", "language": "hi"})
    resp = handler(event, None)
    assert resp["statusCode"] == 200
    body = json.loads(resp["body"])
    assert body["isEmergency"] is False
    assert "conversationId" in body
    assert body["audioUrl"] == "https://audio.url/reply.mp3"


@mock_aws
def test_health_query_emergency_path(dynamo_tables, monkeypatch):
    from src.handlers.health import handler
    monkeypatch.setattr("src.handlers.health.polly.synthesize", lambda *a, **kw: None)

    # These keywords trigger detect_red_flags_fast naturally — no mock needed
    event = _auth_event("/health/query", {"text": "सीने में दर्द है, सांस नहीं आ रही", "language": "hi"})
    resp = handler(event, None)
    assert resp["statusCode"] == 200
    body = json.loads(resp["body"])
    assert body["isEmergency"] is True
    assert "108" in body["text"]


@mock_aws
def test_health_conversation_continues(dynamo_tables, monkeypatch):
    """Second query with same conversationId should load prior context."""
    from src.handlers.health import handler
    monkeypatch.setattr("src.handlers.health.detect_red_flags_fast", lambda _: False)
    monkeypatch.setattr("src.handlers.health.bedrock.chat", lambda *a, **kw: "ठीक है।")
    monkeypatch.setattr("src.handlers.health.polly.synthesize", lambda *a, **kw: None)

    event1 = _auth_event("/health/query", {"text": "बुखार है", "language": "hi"})
    resp1 = handler(event1, None)
    conv_id = json.loads(resp1["body"])["conversationId"]

    event2 = _auth_event("/health/query", {"text": "कितने दिन से?", "language": "hi", "conversationId": conv_id})
    resp2 = handler(event2, None)
    assert resp2["statusCode"] == 200
    assert json.loads(resp2["body"])["conversationId"] == conv_id


# ── /health/nearby ─────────────────────────────────────────────────────────────

@mock_aws
def test_nearby_missing_pincode(dynamo_tables):
    from src.handlers.health import handler
    event = _public_event("/health/nearby", {})
    resp = handler(event, None)
    assert resp["statusCode"] == 400


@mock_aws
def test_nearby_returns_facilities(dynamo_tables):
    from src.handlers.health import handler
    from src.services.dynamodb_service import dynamo

    dynamo.save_shop({
        "shopId": "clinic-001",
        "ownerId": "o1",
        "name": "Sharma Clinic",
        "ownerName": "Dr Sharma",
        "phone": "9000000001",
        "pincode": "110001",
        "category": "clinic",
        "status": "approved",
        "inventory": [],
        "createdAt": "2024-01-01",
        "updatedAt": "2024-01-01",
    })

    event = _public_event("/health/nearby", {"pincode": "110001"})
    resp = handler(event, None)
    body = json.loads(resp["body"])
    assert len(body["facilities"]) == 1
    assert body["facilities"][0]["name"] == "Sharma Clinic"
