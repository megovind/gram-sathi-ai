"""
Tests for nearby clinic/pharmacy features (US-L1, US-L2, US-L3).

Covers:
  - NominatimService.geocode() — HTTP + DynamoDB cache
  - OverpassService.search_nearby() — HTTP + result parsing
  - health handler /health/query nearby path:
      GPS → Overpass → DynamoDB fallback
      City text → Bedrock → Nominatim → Overpass → DynamoDB fallback
      Retail shops → DynamoDB only (no OSM)
"""

import json
import io
import pytest
import boto3
from moto import mock_aws
from unittest.mock import patch, MagicMock

from src.utils.config import config
from src.utils.auth import create_token


# ── shared fixtures ────────────────────────────────────────────────────────────

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
        client.create_table(
            TableName=config.GEO_CACHE_TABLE,
            BillingMode="PAY_PER_REQUEST",
            AttributeDefinitions=[{"AttributeName": "locationKey", "AttributeType": "S"}],
            KeySchema=[{"AttributeName": "locationKey", "KeyType": "HASH"}],
        )
        client.create_table(
            TableName=config.USERS_TABLE,
            BillingMode="PAY_PER_REQUEST",
            AttributeDefinitions=[{"AttributeName": "userId", "AttributeType": "S"}],
            KeySchema=[{"AttributeName": "userId", "KeyType": "HASH"}],
        )
        yield


def _auth_event(path, body, user_id="user-nearby-test"):
    return {
        "httpMethod": "POST",
        "path": path,
        "headers": {"Authorization": f"Bearer {create_token(user_id)}"},
        "body": json.dumps(body),
    }


def _nominatim_response(lat="28.6139", lon="77.2090"):
    """Build a fake Nominatim HTTP response body."""
    return json.dumps([{"lat": lat, "lon": lon, "display_name": "Delhi, India"}]).encode()


def _overpass_response(amenity="clinic", name="City Clinic", phone="9000000001"):
    """Build a fake Overpass API response body."""
    return json.dumps({
        "elements": [{
            "type": "node",
            "id": 123456,
            "lat": 28.615,
            "lon": 77.210,
            "tags": {
                "amenity": amenity,
                "name": name,
                "phone": phone,
                "addr:street": "MG Road",
                "addr:city": "Delhi",
            }
        }]
    }).encode()


def _mock_urlopen(response_bytes):
    """Return a context-manager mock that yields an HTTP-like response."""
    mock_resp = MagicMock()
    mock_resp.read.return_value = response_bytes
    mock_resp.__enter__ = lambda s: s
    mock_resp.__exit__ = MagicMock(return_value=False)
    return mock_resp


# ═══════════════════════════════════════════════════════════════════════════════
# NominatimService tests
# ═══════════════════════════════════════════════════════════════════════════════

class TestNominatimService:

    @mock_aws
    def test_geocode_returns_lat_lon(self, dynamo_tables):
        """Happy path — Nominatim returns coordinates."""
        from src.services.nominatim_service import NominatimService
        svc = NominatimService()

        with patch("urllib.request.urlopen", return_value=_mock_urlopen(_nominatim_response())):
            result = svc.geocode("Delhi")

        assert result is not None
        lat, lon = result
        assert abs(lat - 28.6139) < 0.001
        assert abs(lon - 77.2090) < 0.001

    @mock_aws
    def test_geocode_caches_in_dynamodb(self, dynamo_tables):
        """Second call must hit DynamoDB, not make another HTTP request."""
        from src.services.nominatim_service import NominatimService
        svc = NominatimService()

        with patch("urllib.request.urlopen", return_value=_mock_urlopen(_nominatim_response())) as mock_http:
            svc.geocode("Delhi")
            svc.geocode("delhi")   # same key (lowercased)

        # Only one HTTP call — second hit is served from cache
        assert mock_http.call_count == 1

    @mock_aws
    def test_geocode_returns_none_on_empty_response(self, dynamo_tables):
        """Nominatim returns [] → should return None gracefully."""
        from src.services.nominatim_service import NominatimService
        svc = NominatimService()

        with patch("urllib.request.urlopen", return_value=_mock_urlopen(b"[]")):
            result = svc.geocode("XYZUnknownPlace")

        assert result is None

    @mock_aws
    def test_geocode_returns_none_on_network_error(self, dynamo_tables):
        """Network failure → should return None, not raise."""
        from src.services.nominatim_service import NominatimService
        svc = NominatimService()

        with patch("urllib.request.urlopen", side_effect=OSError("timeout")):
            result = svc.geocode("Delhi")

        assert result is None

    @mock_aws
    def test_geocode_uses_cache_on_second_call(self, dynamo_tables):
        """Verify the cache read path returns the stored coordinates."""
        from src.services.nominatim_service import NominatimService
        from src.services.database import db
        db.set_geo_cache("mumbai", 19.0760, 72.8777)

        svc = NominatimService()
        with patch("urllib.request.urlopen") as mock_http:
            result = svc.geocode("Mumbai")

        mock_http.assert_not_called()
        assert result is not None
        lat, lon = result
        assert abs(lat - 19.0760) < 0.001
        assert abs(lon - 72.8777) < 0.001


# ═══════════════════════════════════════════════════════════════════════════════
# OverpassService tests
# ═══════════════════════════════════════════════════════════════════════════════

class TestOverpassService:

    def test_search_nearby_returns_parsed_results(self):
        """Happy path — Overpass returns one node, we parse it correctly."""
        from src.services.overpass_service import OverpassService
        svc = OverpassService()

        with patch("urllib.request.urlopen", return_value=_mock_urlopen(
            _overpass_response(amenity="clinic", name="City Clinic", phone="9000000001")
        )):
            results = svc.search_nearby(28.6139, 77.2090, kind="clinic")

        assert len(results) == 1
        assert results[0]["name"] == "City Clinic"
        assert results[0]["phone"] == "9000000001"
        assert results[0]["category"] == "clinic"
        assert results[0]["source"] == "osm"

    def test_search_nearby_returns_empty_on_network_error(self):
        """Network failure → returns [], does not raise."""
        from src.services.overpass_service import OverpassService
        svc = OverpassService()

        with patch("urllib.request.urlopen", side_effect=OSError("connection refused")):
            results = svc.search_nearby(28.6139, 77.2090, kind="hospital")

        assert results == []

    def test_search_nearby_returns_empty_when_no_elements(self):
        """Overpass returns no results → returns []."""
        from src.services.overpass_service import OverpassService
        svc = OverpassService()

        empty_body = json.dumps({"elements": []}).encode()
        with patch("urllib.request.urlopen", return_value=_mock_urlopen(empty_body)):
            results = svc.search_nearby(28.6139, 77.2090, kind="pharmacy")

        assert results == []

    def test_search_nearby_respects_max_results(self):
        """Result list must be capped at max_results."""
        from src.services.overpass_service import OverpassService
        svc = OverpassService()

        many_nodes = [
            {"type": "node", "id": i, "lat": 28.6 + i * 0.001, "lon": 77.2,
             "tags": {"amenity": "clinic", "name": f"Clinic {i}"}}
            for i in range(10)
        ]
        body = json.dumps({"elements": many_nodes}).encode()
        with patch("urllib.request.urlopen", return_value=_mock_urlopen(body)):
            results = svc.search_nearby(28.6139, 77.2090, kind="clinic", max_results=3)

        assert len(results) == 3

    def test_search_nearby_fallback_name(self):
        """Node with no name tag should use 'Unknown'."""
        from src.services.overpass_service import OverpassService
        svc = OverpassService()

        body = json.dumps({"elements": [
            {"type": "node", "id": 1, "lat": 28.6, "lon": 77.2, "tags": {"amenity": "pharmacy"}}
        ]}).encode()
        with patch("urllib.request.urlopen", return_value=_mock_urlopen(body)):
            results = svc.search_nearby(28.6139, 77.2090, kind="pharmacy")

        assert results[0]["name"] == "Unknown"


# ═══════════════════════════════════════════════════════════════════════════════
# Health handler — GPS path (Overpass primary)
# ═══════════════════════════════════════════════════════════════════════════════

class TestHealthHandlerGPSPath:

    @mock_aws
    def test_nearby_with_gps_uses_overpass(self, dynamo_tables, monkeypatch):
        """When app sends lat/lon, Overpass is called and OSM results are returned."""
        from src.handlers.health import handler
        monkeypatch.setattr(
            "src.handlers.health.overpass.search_nearby",
            lambda lat, lon, kind, max_results: [{
                "name": "OSM Clinic", "phone": "9001", "address": "Delhi", "source": "osm",
                "category": "clinic", "lat": lat, "lon": lon,
            }]
        )
        monkeypatch.setattr("src.handlers.health.polly.synthesize", lambda *a, **kw: None)

        event = _auth_event("/health/query", {
            "text": "nearby clinic",
            "language": "en",
            "latitude": 28.6139,
            "longitude": 77.2090,
        })
        resp = handler(event, None)
        body = json.loads(resp["body"])

        assert resp["statusCode"] == 200
        assert "OSM Clinic" in body["text"]

    @mock_aws
    def test_nearby_gps_overpass_empty_falls_back_to_dynamo(self, dynamo_tables, monkeypatch):
        """Overpass returns [] with GPS → handler falls back to DynamoDB shops."""
        from src.handlers.health import handler
        from src.services.database import db

        db.save_shop({
            "shopId": "clinic-dynamo-01",
            "ownerId": "o1",
            "name": "DynamoDB Clinic",
            "ownerName": "Dr DB",
            "phone": "9002",
            "pincode": "324008",   # DEFAULT_NEARBY_PINCODE
            "category": "clinic",
            "status": "approved",
            "inventory": [],
            "createdAt": "2024-01-01",
            "updatedAt": "2024-01-01",
        })

        # Overpass returns nothing
        monkeypatch.setattr(
            "src.handlers.health.overpass.search_nearby", lambda *a, **kw: []
        )
        monkeypatch.setattr("src.handlers.health.polly.synthesize", lambda *a, **kw: None)

        event = _auth_event("/health/query", {
            "text": "nearby clinic",
            "language": "en",
            "latitude": 28.6139,
            "longitude": 77.2090,
        })
        resp = handler(event, None)
        body = json.loads(resp["body"])

        assert resp["statusCode"] == 200
        assert "DynamoDB Clinic" in body["text"]

    @mock_aws
    def test_nearby_invalid_gps_ignored_gracefully(self, dynamo_tables, monkeypatch):
        """Malformed lat/lon in body must not crash the handler."""
        from src.handlers.health import handler
        monkeypatch.setattr(
            "src.handlers.health.overpass.search_nearby", lambda *a, **kw: []
        )
        monkeypatch.setattr("src.handlers.health.polly.synthesize", lambda *a, **kw: None)

        event = _auth_event("/health/query", {
            "text": "nearby clinic",
            "language": "en",
            "latitude": "not-a-number",
            "longitude": "bad",
        })
        resp = handler(event, None)
        # Should not crash — falls through to DynamoDB path
        assert resp["statusCode"] == 200


# ═══════════════════════════════════════════════════════════════════════════════
# Health handler — City extraction path (Bedrock → Nominatim → Overpass)
# ═══════════════════════════════════════════════════════════════════════════════

class TestHealthHandlerCityPath:

    @mock_aws
    def test_city_in_query_uses_nominatim_then_overpass(self, dynamo_tables, monkeypatch):
        """No GPS + Bedrock extracts city → Nominatim → Overpass returns results."""
        from src.handlers.health import handler

        # Bedrock extracts "Delhi" from the query
        monkeypatch.setattr(
            "src.handlers.health.bedrock.extract_nearby_location", lambda text: "Delhi"
        )
        # Nominatim geocodes Delhi
        monkeypatch.setattr(
            "src.handlers.health.nominatim.geocode", lambda city: (28.6139, 77.2090)
        )
        # Overpass returns one OSM result
        monkeypatch.setattr(
            "src.handlers.health.overpass.search_nearby",
            lambda lat, lon, kind, max_results: [{
                "name": "Delhi Hospital", "phone": "9003", "address": "New Delhi",
                "category": "hospital", "source": "osm", "lat": lat, "lon": lon,
            }]
        )
        monkeypatch.setattr("src.handlers.health.polly.synthesize", lambda *a, **kw: None)

        event = _auth_event("/health/query", {
            "text": "Mujhe Delhi mein hospital chahiye",
            "language": "hi",
        })
        resp = handler(event, None)
        body = json.loads(resp["body"])

        assert resp["statusCode"] == 200
        assert "Delhi Hospital" in body["text"]

    @mock_aws
    def test_city_not_found_by_nominatim_falls_back_to_dynamo(self, dynamo_tables, monkeypatch):
        """Nominatim returns None (unknown place) → DynamoDB fallback used."""
        from src.handlers.health import handler
        from src.services.database import db

        db.save_shop({
            "shopId": "pharmacy-dynamo-01",
            "ownerId": "o2",
            "name": "Pincode Pharmacy",
            "ownerName": "Owner",
            "phone": "9004",
            "pincode": "324008",
            "category": "pharmacy",
            "status": "approved",
            "inventory": [],
            "createdAt": "2024-01-01",
            "updatedAt": "2024-01-01",
        })

        monkeypatch.setattr(
            "src.handlers.health.bedrock.extract_nearby_location", lambda text: "ZZZUnknown"
        )
        monkeypatch.setattr(
            "src.handlers.health.nominatim.geocode", lambda city: None
        )
        monkeypatch.setattr("src.handlers.health.polly.synthesize", lambda *a, **kw: None)

        event = _auth_event("/health/query", {
            "text": "pharmacy in ZZZUnknown",
            "language": "en",
        })
        resp = handler(event, None)
        body = json.loads(resp["body"])

        assert resp["statusCode"] == 200
        assert "Pincode Pharmacy" in body["text"]

    @mock_aws
    def test_no_city_no_gps_falls_back_to_dynamo(self, dynamo_tables, monkeypatch):
        """No GPS and Bedrock returns None → pure DynamoDB fallback."""
        from src.handlers.health import handler
        from src.services.database import db

        db.save_shop({
            "shopId": "hosp-dynamo-01",
            "ownerId": "o3",
            "name": "Local Hospital",
            "ownerName": "Owner",
            "phone": "9005",
            "pincode": "324008",
            "category": "hospital",
            "status": "approved",
            "inventory": [],
            "createdAt": "2024-01-01",
            "updatedAt": "2024-01-01",
        })

        monkeypatch.setattr(
            "src.handlers.health.bedrock.extract_nearby_location", lambda text: None
        )
        monkeypatch.setattr("src.handlers.health.polly.synthesize", lambda *a, **kw: None)

        event = _auth_event("/health/query", {
            "text": "nearby hospital",
            "language": "en",
        })
        resp = handler(event, None)
        body = json.loads(resp["body"])

        assert resp["statusCode"] == 200
        assert "Local Hospital" in body["text"]

    @mock_aws
    def test_bedrock_location_extraction_error_falls_back_gracefully(self, dynamo_tables, monkeypatch):
        """Even if Bedrock throws, the handler should not crash."""
        from src.handlers.health import handler

        monkeypatch.setattr(
            "src.handlers.health.bedrock.extract_nearby_location",
            lambda text: (_ for _ in ()).throw(RuntimeError("bedrock down"))
        )
        monkeypatch.setattr("src.handlers.health.polly.synthesize", lambda *a, **kw: None)

        event = _auth_event("/health/query", {
            "text": "nearby clinic",
            "language": "en",
        })
        resp = handler(event, None)
        # Should not 500 — falls through to DynamoDB fallback
        assert resp["statusCode"] == 200


# ═══════════════════════════════════════════════════════════════════════════════
# Health handler — Retail shops still use DynamoDB only
# ═══════════════════════════════════════════════════════════════════════════════

class TestHealthHandlerRetailPath:

    @mock_aws
    def test_retail_shop_query_uses_dynamo_not_overpass(self, dynamo_tables, monkeypatch):
        """'nearby shop' should query DynamoDB only — Overpass must not be called."""
        from src.handlers.health import handler
        from src.services.database import db

        db.save_shop({
            "shopId": "kirana-01",
            "ownerId": "o4",
            "name": "Raju Kirana",
            "ownerName": "Raju",
            "phone": "9006",
            "pincode": "324008",
            "category": "grocery",
            "status": "approved",
            "inventory": [],
            "createdAt": "2024-01-01",
            "updatedAt": "2024-01-01",
        })

        overpass_called = {"flag": False}

        def _overpass_spy(*a, **kw):
            overpass_called["flag"] = True
            return []

        monkeypatch.setattr("src.handlers.health.overpass.search_nearby", _overpass_spy)
        monkeypatch.setattr("src.handlers.health.polly.synthesize", lambda *a, **kw: None)

        event = _auth_event("/health/query", {
            "text": "nearby shop",
            "language": "en",
            "latitude": 28.6139,
            "longitude": 77.2090,
        })
        resp = handler(event, None)
        body = json.loads(resp["body"])

        assert resp["statusCode"] == 200
        assert overpass_called["flag"] is False
        assert "Raju Kirana" in body["text"]


# ═══════════════════════════════════════════════════════════════════════════════
# BedrockService.extract_nearby_location unit tests
# ═══════════════════════════════════════════════════════════════════════════════

class TestBedrockExtractLocation:

    def test_extracts_city_name(self, monkeypatch):
        """Bedrock returns clean JSON with a city name."""
        from src.services.bedrock_service import BedrockService
        svc = BedrockService.__new__(BedrockService)
        monkeypatch.setattr(svc, "chat", lambda *a, **kw: '{"location": "Mumbai"}')
        assert svc.extract_nearby_location("Mumbai mein clinic chahiye") == "Mumbai"

    def test_returns_none_when_location_null(self, monkeypatch):
        """Bedrock returns null location → None."""
        from src.services.bedrock_service import BedrockService
        svc = BedrockService.__new__(BedrockService)
        monkeypatch.setattr(svc, "chat", lambda *a, **kw: '{"location": null}')
        assert svc.extract_nearby_location("nearby clinic") is None

    def test_returns_none_on_malformed_json(self, monkeypatch):
        """Bedrock returns garbage → None, does not raise."""
        from src.services.bedrock_service import BedrockService
        svc = BedrockService.__new__(BedrockService)
        monkeypatch.setattr(svc, "chat", lambda *a, **kw: "sure! Delhi is the city.")
        assert svc.extract_nearby_location("Delhi clinic") is None

    def test_returns_none_on_chat_exception(self, monkeypatch):
        """If bedrock.chat throws, extract_nearby_location returns None."""
        from src.services.bedrock_service import BedrockService
        svc = BedrockService.__new__(BedrockService)
        monkeypatch.setattr(svc, "chat", lambda *a, **kw: (_ for _ in ()).throw(RuntimeError("error")))
        assert svc.extract_nearby_location("Delhi clinic") is None

    def test_strips_whitespace_from_city(self, monkeypatch):
        """City with extra whitespace is stripped."""
        from src.services.bedrock_service import BedrockService
        svc = BedrockService.__new__(BedrockService)
        monkeypatch.setattr(svc, "chat", lambda *a, **kw: '{"location": "  Pune  "}')
        assert svc.extract_nearby_location("Pune mein hospital") == "Pune"


# ═══════════════════════════════════════════════════════════════════════════════
# DynamoDB geo cache unit tests
# ═══════════════════════════════════════════════════════════════════════════════

class TestGeoCacheDynamo:

    @mock_aws
    def test_set_and_get_geo_cache(self, dynamo_tables):
        """set_geo_cache then get_geo_cache returns correct lat/lon."""
        from src.services.database import db
        db.set_geo_cache("bangalore", 12.9716, 77.5946)
        cached = db.get_geo_cache("bangalore")
        assert cached is not None
        assert abs(float(cached["lat"]) - 12.9716) < 0.001
        assert abs(float(cached["lon"]) - 77.5946) < 0.001

    @mock_aws
    def test_get_geo_cache_miss_returns_none(self, dynamo_tables):
        """Cache miss returns None."""
        from src.services.database import db
        assert db.get_geo_cache("nonexistent-city-xyz") is None

    @mock_aws
    def test_geo_cache_overwrite(self, dynamo_tables):
        """Writing the same key twice updates the value."""
        from src.services.database import db
        db.set_geo_cache("pune", 18.5204, 73.8567)
        db.set_geo_cache("pune", 18.9999, 73.9999)   # overwrite
        cached = db.get_geo_cache("pune")
        assert abs(float(cached["lat"]) - 18.9999) < 0.001
