"""
Structured JSON logger for AWS Lambda / CloudWatch (US-23).

Usage:
    from src.utils.logger import logger
    logger.info("chat_request", user_id="u1", language="hi")
    logger.error("bedrock_failed", error=str(e), user_id="u1")
"""
import json
import logging
import os
import time
from typing import Any

_STAGE = os.environ.get("STAGE", "dev")
_SERVICE = "gramsathi-backend"

# Use the root Lambda logger so output goes to CloudWatch
_root = logging.getLogger()
_root.setLevel(logging.INFO)


class StructuredLogger:
    def __init__(self, name: str):
        self._name = name

    def _emit(self, level: str, event: str, **fields: Any) -> None:
        record = {
            "timestamp": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
            "level": level,
            "service": _SERVICE,
            "stage": _STAGE,
            "logger": self._name,
            "event": event,
            **fields,
        }
        # Lambda captures stdout → CloudWatch Logs
        print(json.dumps(record, default=str))

    def info(self, event: str, **fields: Any) -> None:
        self._emit("INFO", event, **fields)

    def warning(self, event: str, **fields: Any) -> None:
        self._emit("WARNING", event, **fields)

    def error(self, event: str, **fields: Any) -> None:
        self._emit("ERROR", event, **fields)

    def debug(self, event: str, **fields: Any) -> None:
        if _STAGE == "dev":
            self._emit("DEBUG", event, **fields)


# Single shared instance
logger = StructuredLogger("gramsathi")
