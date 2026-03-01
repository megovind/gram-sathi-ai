"""
User handler (US-01, US-20)

POST /user          – create or update user profile (onboarding)
GET  /user/{userId} – get user profile
"""
import uuid
from datetime import datetime, timezone

from src.models.user import Language, User, UserRole
from src.services.database import db
from src.utils.auth import create_token
from src.utils.constants import (
    DEFAULT_LANGUAGE,
    ERR_ROUTE_NOT_FOUND,
    ERR_UNSUPPORTED_LANGUAGE,
    ERR_USER_NOT_FOUND,
    USER_ID_PHONE_PREFIX,
)
from src.utils.response import error, ok, parse_body


def handler(event: dict, context) -> dict:
    method = event.get("httpMethod", "GET")
    params = event.get("pathParameters") or {}
    user_id = params.get("userId", "")

    if method == "POST":
        return _create_or_update(event)
    if method == "GET" and user_id:
        return _get_user(user_id)

    return error(ERR_ROUTE_NOT_FOUND, 404)


def _create_or_update(event: dict) -> dict:
    """
    Create a new user or update language/name preference.
    Returns the user object + a signed JWT for subsequent requests.
    """
    body = parse_body(event)
    phone: str = body.get("phone", "")
    language: str = body.get("language", DEFAULT_LANGUAGE)
    name: str = body.get("name", "")
    role: str = body.get("role", UserRole.CITIZEN.value)

    if language not in Language._value2member_map_:
        return error(ERR_UNSUPPORTED_LANGUAGE.format(language), 400)

    # Check if user with this phone already exists
    existing = None
    if phone:
        # Scan by phone is expensive — in production add a GSI on phone
        # For now create deterministic userId from phone
        user_id = f"{USER_ID_PHONE_PREFIX}{phone}"
        existing = db.get_user(user_id)

    if existing:
        # Update language/name preference
        existing["preferredLanguage"] = language
        if name:
            existing["name"] = name
        existing["updatedAt"] = datetime.now(timezone.utc).isoformat()
        db.save_user(existing)
        user = User.from_dynamo(existing)
    else:
        user_id = f"{USER_ID_PHONE_PREFIX}{phone}" if phone else str(uuid.uuid4())
        user = User(
            userId=user_id,
            phone=phone or None,
            name=name or None,
            preferredLanguage=Language(language),
            role=UserRole(role),
        )
        db.save_user(user.to_dynamo())

    token = create_token(user.userId)

    return ok(
        {
            "userId": user.userId,
            "language": user.preferredLanguage.value,
            "name": user.name,
            "token": token,
        },
        status_code=201 if not existing else 200,
    )


def _get_user(user_id: str) -> dict:
    user_data = db.get_user(user_id)
    if not user_data:
        return error(ERR_USER_NOT_FOUND, 404)
    return ok(user_data)
