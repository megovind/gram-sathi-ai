import json
import pytest
import boto3
from moto import mock_aws
from unittest.mock import patch

from src.utils.config import config


@pytest.fixture(autouse=True)
def aws_credentials(monkeypatch):
    monkeypatch.setenv("AWS_ACCESS_KEY_ID", "testing")
    monkeypatch.setenv("AWS_SECRET_ACCESS_KEY", "testing")
    monkeypatch.setenv("AWS_SECURITY_TOKEN", "testing")
    monkeypatch.setenv("AWS_SESSION_TOKEN", "testing")
    monkeypatch.setenv("AWS_DEFAULT_REGION", "ap-south-1")


@pytest.fixture
def dynamo_table():
    with mock_aws():
        client = boto3.client("dynamodb", region_name="ap-south-1")
        client.create_table(
            TableName=config.USERS_TABLE,
            BillingMode="PAY_PER_REQUEST",
            AttributeDefinitions=[{"AttributeName": "userId", "AttributeType": "S"}],
            KeySchema=[{"AttributeName": "userId", "KeyType": "HASH"}],
        )
        yield


def _post_event(body: dict) -> dict:
    return {"httpMethod": "POST", "path": "/user", "body": json.dumps(body)}


def _get_event(user_id: str) -> dict:
    return {
        "httpMethod": "GET",
        "path": f"/user/{user_id}",
        "pathParameters": {"userId": user_id},
    }


@mock_aws
def test_create_user_returns_token(dynamo_table):
    from src.handlers.user import handler
    event = _post_event({"phone": "9876543210", "language": "hi", "name": "Ramu"})
    resp = handler(event, None)
    assert resp["statusCode"] == 201
    body = json.loads(resp["body"])
    assert body["userId"] == "ph-9876543210"
    assert body["language"] == "hi"
    assert "token" in body


@mock_aws
def test_create_user_default_language(dynamo_table):
    from src.handlers.user import handler
    event = _post_event({"phone": "9000000001"})
    resp = handler(event, None)
    body = json.loads(resp["body"])
    assert body["language"] == "hi"


@mock_aws
def test_update_existing_user_language(dynamo_table):
    from src.handlers.user import handler
    handler(_post_event({"phone": "9000000002", "language": "hi"}), None)
    resp = handler(_post_event({"phone": "9000000002", "language": "en"}), None)
    assert resp["statusCode"] == 200
    body = json.loads(resp["body"])
    assert body["language"] == "en"


@mock_aws
def test_get_user_not_found(dynamo_table):
    from src.handlers.user import handler
    resp = handler(_get_event("nonexistent"), None)
    assert resp["statusCode"] == 404


@mock_aws
def test_get_user_found(dynamo_table):
    from src.handlers.user import handler
    handler(_post_event({"phone": "9000000003", "language": "mr"}), None)
    resp = handler(_get_event("ph-9000000003"), None)
    assert resp["statusCode"] == 200
    body = json.loads(resp["body"])
    assert body["userId"] == "ph-9000000003"


@mock_aws
def test_invalid_language_rejected(dynamo_table):
    from src.handlers.user import handler
    resp = handler(_post_event({"phone": "9000000004", "language": "xx"}), None)
    assert resp["statusCode"] == 400
