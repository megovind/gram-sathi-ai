"""
Lightweight JWT auth utility (US-20).
Uses HS256 with a secret stored in AWS environment variable.
"""
import base64
import hashlib
import hmac
import json
import os
import time
from typing import Optional

_SECRET: str = os.environ.get("JWT_SECRET", "")
_STAGE: str = os.environ.get("STAGE", "dev")

# In production the secret MUST be set explicitly — fail fast if it isn't
if not _SECRET:
    if _STAGE == "prod":
        raise RuntimeError("JWT_SECRET environment variable is not set. Refusing to start.")
    # Dev/test fallback — never used in prod
    _SECRET = "gramsathi-dev-only-secret-not-for-prod"

_MIN_SECRET_LENGTH = 32
if len(_SECRET) < _MIN_SECRET_LENGTH and _STAGE == "prod":
    raise RuntimeError(f"JWT_SECRET must be at least {_MIN_SECRET_LENGTH} characters in production.")

_EXPIRY_SECONDS = 60 * 60 * 24 * 7  # 7 days (was 30 — reduced to limit token lifetime)


def _b64url_encode(data: bytes) -> str:
    return base64.urlsafe_b64encode(data).rstrip(b"=").decode()


def _b64url_decode(s: str) -> bytes:
    padding = 4 - len(s) % 4
    return base64.urlsafe_b64decode(s + "=" * padding)


def create_token(user_id: str) -> str:
    header = _b64url_encode(json.dumps({"alg": "HS256", "typ": "JWT"}).encode())
    payload = _b64url_encode(
        json.dumps(
            {
                "sub": user_id,
                "iat": int(time.time()),
                "exp": int(time.time()) + _EXPIRY_SECONDS,
            }
        ).encode()
    )
    signing_input = f"{header}.{payload}"
    sig = hmac.new(
        _SECRET.encode(), signing_input.encode(), hashlib.sha256
    ).digest()
    return f"{signing_input}.{_b64url_encode(sig)}"


def verify_token(token: str) -> Optional[str]:
    """Returns userId (sub) if valid, None otherwise."""
    try:
        parts = token.split(".")
        if len(parts) != 3:
            return None
        header_b64, payload_b64, sig_b64 = parts

        # Verify algorithm header to prevent alg:none attacks
        header = json.loads(_b64url_decode(header_b64))
        if header.get("alg") != "HS256":
            return None

        signing_input = f"{header_b64}.{payload_b64}"
        expected_sig = hmac.new(
            _SECRET.encode(), signing_input.encode(), hashlib.sha256
        ).digest()
        actual_sig = _b64url_decode(sig_b64)
        if not hmac.compare_digest(expected_sig, actual_sig):
            return None

        payload = json.loads(_b64url_decode(payload_b64))
        if payload.get("exp", 0) < time.time():
            return None
        return payload.get("sub")
    except Exception:
        return None


def get_user_id_from_event(event: dict) -> Optional[str]:
    """Extract and verify Bearer token from Lambda event headers."""
    headers = event.get("headers") or {}
    auth_header = headers.get("Authorization") or headers.get("authorization") or ""
    if auth_header.startswith("Bearer "):
        return verify_token(auth_header[7:])
    return None


def require_auth(event: dict):
    """
    Call at the top of any protected handler.
    Returns (user_id, None) on success or (None, error_response) on failure.
    """
    from src.utils.response import error as make_error
    user_id = get_user_id_from_event(event)
    if not user_id:
        return None, make_error("Unauthorized", 401)
    return user_id, None
