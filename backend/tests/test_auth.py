import time
import pytest
from src.utils.auth import create_token, verify_token, get_user_id_from_event, require_auth


def test_create_and_verify_token():
    token = create_token("user-123")
    assert verify_token(token) == "user-123"


def test_invalid_token_returns_none():
    assert verify_token("not.a.valid.token") is None
    assert verify_token("") is None
    assert verify_token("a.b.c") is None


def test_tampered_token_rejected():
    token = create_token("user-123")
    parts = token.split(".")
    # Flip a char in the signature
    tampered_sig = parts[2][:-1] + ("A" if parts[2][-1] != "A" else "B")
    tampered = f"{parts[0]}.{parts[1]}.{tampered_sig}"
    assert verify_token(tampered) is None


def test_get_user_id_from_event():
    token = create_token("user-abc")
    event = {"headers": {"Authorization": f"Bearer {token}"}}
    assert get_user_id_from_event(event) == "user-abc"


def test_get_user_id_missing_header():
    assert get_user_id_from_event({}) is None
    assert get_user_id_from_event({"headers": {}}) is None


def test_require_auth_success():
    token = create_token("user-xyz")
    event = {"headers": {"Authorization": f"Bearer {token}"}}
    user_id, err = require_auth(event)
    assert user_id == "user-xyz"
    assert err is None


def test_require_auth_no_token():
    user_id, err = require_auth({})
    assert user_id is None
    assert err is not None
    assert err["statusCode"] == 401
