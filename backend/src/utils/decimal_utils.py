"""
DynamoDB requires Decimal instead of float.
These helpers convert recursively so models can stay as float internally.
"""
from decimal import Decimal, ROUND_HALF_UP
from typing import Any


def to_decimal(value: Any) -> Any:
    """Recursively convert float → Decimal in dicts/lists (for DynamoDB writes)."""
    if isinstance(value, float):
        # Use string conversion to avoid floating-point precision issues
        return Decimal(str(value))
    if isinstance(value, dict):
        return {k: to_decimal(v) for k, v in value.items()}
    if isinstance(value, list):
        return [to_decimal(v) for v in value]
    return value


def from_decimal(value: Any) -> Any:
    """Recursively convert Decimal → float in dicts/lists (after DynamoDB reads)."""
    if isinstance(value, Decimal):
        return float(value)
    if isinstance(value, dict):
        return {k: from_decimal(v) for k, v in value.items()}
    if isinstance(value, list):
        return [from_decimal(v) for v in value]
    return value
