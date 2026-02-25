import json
import pytest
from src.utils.response import ok, error, parse_body


def test_ok_response():
    resp = ok({"key": "value"})
    assert resp["statusCode"] == 200
    body = json.loads(resp["body"])
    assert body["key"] == "value"


def test_ok_custom_status():
    resp = ok({"id": "123"}, status_code=201)
    assert resp["statusCode"] == 201


def test_error_response():
    resp = error("Something went wrong", 400)
    assert resp["statusCode"] == 400
    body = json.loads(resp["body"])
    assert body["error"] == "Something went wrong"


def test_error_with_details():
    resp = error("Validation failed", 422, details={"field": "userId"})
    body = json.loads(resp["body"])
    assert body["details"]["field"] == "userId"


def test_parse_body_json_string():
    event = {"body": '{"userId": "u1", "text": "hello"}'}
    result = parse_body(event)
    assert result["userId"] == "u1"


def test_parse_body_dict():
    event = {"body": {"userId": "u2"}}
    result = parse_body(event)
    assert result["userId"] == "u2"


def test_parse_body_empty():
    result = parse_body({})
    assert result == {}


def test_parse_body_invalid_json():
    event = {"body": "not-json"}
    result = parse_body(event)
    assert result == {}
