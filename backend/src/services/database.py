"""
Database abstraction: DynamoDB (AWS) when deployed, MongoDB when running locally.
Import `db` from here — handlers use the same interface either way.
"""
import os

_IS_OFFLINE = os.environ.get("IS_OFFLINE", "").lower() in ("true", "1")

if _IS_OFFLINE:
    from src.services.mongodb_service import MongoDBService

    db = MongoDBService()
else:
    from src.services.dynamodb_service import dynamo

    db = dynamo
