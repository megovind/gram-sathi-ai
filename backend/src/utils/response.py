import json
from typing import Any, Optional


def ok(body: Any, status_code: int = 200) -> dict:
    return {
        "statusCode": status_code,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Credentials": True,
        },
        "body": json.dumps(body, default=str),
    }


def error(message: str, status_code: int = 400, details: Optional[Any] = None) -> dict:
    body: dict = {"error": message}
    if details:
        body["details"] = details
    return {
        "statusCode": status_code,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Credentials": True,
        },
        "body": json.dumps(body, default=str),
    }


def parse_body(event: dict) -> dict:
    """Safely parse JSON body from Lambda event."""
    try:
        if isinstance(event.get("body"), str):
            return json.loads(event["body"])
        return event.get("body") or {}
    except (json.JSONDecodeError, TypeError):
        return {}
