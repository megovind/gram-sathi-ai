"""
Tests for nearby clinic/pharmacy/shop features — Google Places + LangGraph architecture.

Covers:
  - GooglePlacesService routing (GPS, force_text, pincode anchor)
  - Radius auto-expansion (10 km → 20 km → 50 km)
  - LangGraph graph nodes: nearby_facilities_node, shops_node
  - No-location fallback reply
  - Named-location vs GPS routing decisions
"""

import json
import pytest
import boto3
from moto import mock_aws
from unittest.mock import patch, MagicMock, call

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
        for cfg in [
            (config.CONVERSATIONS_TABLE, "conversationId", "userId", "UserConversationsIndex"),
            (config.SHOPS_TABLE, "shopId", "pincode", "PincodeIndex"),
            (config.USERS_TABLE, "userId", None, None),
            (config.RESPONSE_CACHE_TABLE, "cacheKey", None, None),
        ]:
            table_name, pk, gsi_key, gsi_name = cfg
            attrs = [{"AttributeName": pk, "AttributeType": "S"}]
            if gsi_key:
                attrs.append({"AttributeName": gsi_key, "AttributeType": "S"})
            kwargs = dict(
                TableName=table_name,
                BillingMode="PAY_PER_REQUEST",
                AttributeDefinitions=attrs,
                KeySchema=[{"AttributeName": pk, "KeyType": "HASH"}],
            )
            if gsi_name and gsi_key:
                kwargs["GlobalSecondaryIndexes"] = [{
                    "IndexName": gsi_name,
                    "KeySchema": [{"AttributeName": gsi_key, "KeyType": "HASH"}],
                    "Projection": {"ProjectionType": "ALL"},
                }]
            client.create_table(**kwargs)
        yield


def _google_place(name="Test Clinic", phone="9000000001", address="Test St"):
    return {"name": name, "phone": phone, "address": address,
            "lat": 28.6, "lon": 77.2, "category": "Clinic", "rating": 4.2, "source": "google"}


def _auth_event(body, user_id="user-nearby-test"):
    return {
        "httpMethod": "POST",
        "path": "/health/query",
        "headers": {"Authorization": f"Bearer {create_token(user_id)}"},
        "body": json.dumps(body),
    }


# ═══════════════════════════════════════════════════════════════════════════════
# GooglePlacesService — routing logic
# ═══════════════════════════════════════════════════════════════════════════════

class TestGooglePlacesRouting:

    @pytest.fixture(autouse=True)
    def fake_api_key(self, monkeypatch):
        """Ensure API key check passes so tests reach routing logic."""
        import src.services.google_places_service as gps_mod
        monkeypatch.setattr(gps_mod.config, "GOOGLE_PLACES_API_KEY", "fake-key-for-tests")

    def test_uses_nearby_search_when_gps_provided(self, monkeypatch):
        """GPS coordinates present → _nearby_search is called."""
        from src.services.google_places_service import GooglePlacesService
        svc = GooglePlacesService()

        nearby_called = {}
        monkeypatch.setattr(svc, "_nearby_search",
                            lambda lat, lon, kind, max_results: (
                                nearby_called.update({"lat": lat, "lon": lon}) or [_google_place()]
                            ))
        monkeypatch.setattr(svc, "_text_search", lambda *a, **kw: [])

        results = svc.search_facilities("nearby clinics", kind="clinic",
                                        lat=28.6, lon=77.2, max_results=5)
        assert nearby_called.get("lat") == 28.6
        assert len(results) == 1

    def test_uses_text_search_when_no_gps(self, monkeypatch):
        """No GPS → _text_search is called."""
        from src.services.google_places_service import GooglePlacesService
        svc = GooglePlacesService()

        text_called = {}
        monkeypatch.setattr(svc, "_text_search",
                            lambda query, kind, max_results, pincode=None: (
                                text_called.update({"query": query}) or [_google_place()]
                            ))
        monkeypatch.setattr(svc, "_nearby_search", lambda *a, **kw: [])

        svc.search_facilities("clinics near me", kind="clinic",
                              lat=None, lon=None, max_results=5)
        assert "query" in text_called

    def test_force_text_search_ignores_gps(self, monkeypatch):
        """force_text_search=True → text search even when GPS is available."""
        from src.services.google_places_service import GooglePlacesService
        svc = GooglePlacesService()

        text_called = {}
        monkeypatch.setattr(svc, "_text_search",
                            lambda query, kind, max_results, pincode=None: (
                                text_called.update({"called": True}) or [_google_place()]
                            ))
        monkeypatch.setattr(svc, "_nearby_search",
                            lambda *a, **kw: (_ for _ in ()).throw(AssertionError("should not call nearby search")))

        svc.search_facilities("clinics in Kota", kind="clinic",
                              lat=28.6, lon=77.2,
                              force_text_search=True, max_results=5)
        assert text_called.get("called") is True

    def test_pincode_anchor_used_when_no_gps(self, monkeypatch):
        """No GPS, pincode provided → _text_search receives the pincode."""
        from src.services.google_places_service import GooglePlacesService
        svc = GooglePlacesService()

        received_pincode = {}
        monkeypatch.setattr(svc, "_text_search",
                            lambda query, kind, max_results, pincode=None: (
                                received_pincode.update({"pincode": pincode}) or []
                            ))
        monkeypatch.setattr(svc, "_nearby_search", lambda *a, **kw: [])

        svc.search_facilities("nearby clinics", kind="clinic",
                              lat=None, lon=None, pincode="324008", max_results=5)
        assert received_pincode.get("pincode") == "324008"

    def test_pincode_anchored_query_built_correctly(self):
        """_text_search with pincode builds 'clinics and doctors near 324008, India'."""
        from src.services.google_places_service import GooglePlacesService
        svc = GooglePlacesService()

        sent_queries = []

        def fake_call(url, payload):
            sent_queries.append(payload.get("textQuery", ""))
            return []

        with patch.object(svc, "_call", side_effect=fake_call):
            svc._text_search("nearby clinics", "clinic", 5, pincode="324008")

        assert len(sent_queries) == 1
        assert "324008" in sent_queries[0]
        assert "India" in sent_queries[0]

    def test_no_gps_no_pincode_query_appends_india(self):
        """No GPS, no pincode → appends ', India' to query."""
        from src.services.google_places_service import GooglePlacesService
        svc = GooglePlacesService()

        sent_queries = []

        def fake_call(url, payload):
            sent_queries.append(payload.get("textQuery", ""))
            return []

        with patch.object(svc, "_call", side_effect=fake_call):
            svc._text_search("clinics in Kota", "clinic", 5, pincode=None)

        assert "India" in sent_queries[0]

    def test_missing_api_key_returns_empty(self, monkeypatch):
        """No API key → returns [] immediately without HTTP call."""
        from src.services.google_places_service import GooglePlacesService
        svc = GooglePlacesService()
        monkeypatch.setattr("src.services.google_places_service.config",
                            type("C", (), {"GOOGLE_PLACES_API_KEY": ""})())
        with patch.object(svc, "_call",
                          side_effect=AssertionError("should not make HTTP call")):
            results = svc.search_facilities("clinics", lat=28.6, lon=77.2)
        assert results == []


# ═══════════════════════════════════════════════════════════════════════════════
# GooglePlacesService — radius auto-expansion
# ═══════════════════════════════════════════════════════════════════════════════

class TestRadiusExpansion:

    def test_returns_results_at_10km(self, monkeypatch):
        """First radius (10 km) succeeds — no further calls."""
        from src.services.google_places_service import GooglePlacesService
        svc = GooglePlacesService()

        call_count = {"n": 0}

        def fake_call(url, payload):
            call_count["n"] += 1
            return [_google_place()]   # non-empty first time

        with patch.object(svc, "_call", side_effect=fake_call):
            results = svc._nearby_search(28.6, 77.2, "clinic", 5)

        assert call_count["n"] == 1
        assert len(results) == 1

    def test_expands_to_20km_when_10km_empty(self, monkeypatch):
        """10 km returns [] → retries at 20 km."""
        from src.services.google_places_service import GooglePlacesService
        svc = GooglePlacesService()

        radii_tried = []

        def fake_call(url, payload):
            radius = payload["locationRestriction"]["circle"]["radius"]
            radii_tried.append(int(radius))
            # Return results only at 20 km
            return [_google_place()] if radius >= 20_000 else []

        with patch.object(svc, "_call", side_effect=fake_call):
            results = svc._nearby_search(28.6, 77.2, "clinic", 5)

        assert 10_000 in radii_tried
        assert 20_000 in radii_tried
        assert len(results) == 1

    def test_expands_to_50km_when_20km_empty(self):
        """10 km and 20 km both empty → tries 50 km."""
        from src.services.google_places_service import GooglePlacesService
        svc = GooglePlacesService()

        radii_tried = []

        def fake_call(url, payload):
            radius = payload["locationRestriction"]["circle"]["radius"]
            radii_tried.append(int(radius))
            return [_google_place()] if radius >= 50_000 else []

        with patch.object(svc, "_call", side_effect=fake_call):
            results = svc._nearby_search(28.6, 77.2, "hospital", 5)

        assert radii_tried == [10_000, 20_000, 50_000]
        assert len(results) == 1

    def test_returns_empty_when_all_radii_empty(self):
        """All three radii return [] → final result is []."""
        from src.services.google_places_service import GooglePlacesService
        svc = GooglePlacesService()

        with patch.object(svc, "_call", return_value=[]):
            results = svc._nearby_search(28.6, 77.2, "pharmacy", 5)

        assert results == []


# ═══════════════════════════════════════════════════════════════════════════════
# LangGraph — nearby_facilities_node
# ═══════════════════════════════════════════════════════════════════════════════

class TestNearbyFacilitiesNode:

    def _state(self, **kwargs):
        base = dict(text="nearby clinics", language="en",
                    user_id="u1", pincode=None, lat=None, lon=None,
                    conversation_history=[], system_extra="", use_cache=False,
                    low_bandwidth=False, intent="nearby_facilities",
                    nearby_kind="clinic", extracted_location=None,
                    reply="", facilities=[])
        base.update(kwargs)
        return base

    def test_uses_named_location_when_extracted(self, monkeypatch):
        """extracted_location set → Google called with clean query, GPS ignored."""
        from src.agents.graph import nearby_facilities_node

        calls = []
        monkeypatch.setattr(
            "src.agents.graph.google_places.search_facilities",
            lambda query, kind, lat, lon, max_results, force_text_search=False, pincode=None: (
                calls.append({"query": query, "lat": lat, "force_text": force_text_search})
                or [_google_place("Aklera Clinic")]
            )
        )

        state = self._state(extracted_location="Aklera", lat=28.6, lon=77.2)
        result = nearby_facilities_node(state)

        assert calls[0]["force_text"] is True
        assert calls[0]["lat"] is None          # GPS ignored
        assert "Aklera" in calls[0]["query"]
        assert result["facilities"][0]["name"] == "Aklera Clinic"

    def test_uses_gps_when_no_extracted_location(self, monkeypatch):
        """No extracted_location, GPS available → GPS passed to search."""
        from src.agents.graph import nearby_facilities_node

        calls = []
        monkeypatch.setattr(
            "src.agents.graph.google_places.search_facilities",
            lambda query, kind, lat, lon, max_results, force_text_search=False, pincode=None: (
                calls.append({"lat": lat, "lon": lon, "force_text": force_text_search})
                or [_google_place()]
            )
        )

        state = self._state(lat=28.6139, lon=77.2090)
        nearby_facilities_node(state)

        assert calls[0]["lat"] == 28.6139
        assert calls[0]["force_text"] is False

    def test_uses_pincode_when_no_gps_no_location(self, monkeypatch):
        """No GPS, no named location, pincode available → pincode passed."""
        from src.agents.graph import nearby_facilities_node

        calls = []
        monkeypatch.setattr(
            "src.agents.graph.google_places.search_facilities",
            lambda query, kind, lat, lon, max_results, force_text_search=False, pincode=None: (
                calls.append({"pincode": pincode}) or []
            )
        )

        state = self._state(pincode="324008")
        nearby_facilities_node(state)

        assert calls[0]["pincode"] == "324008"

    def test_returns_no_location_reply_when_nothing_available(self):
        """No GPS, no pincode, no extracted location → friendly error message."""
        from src.agents.graph import nearby_facilities_node

        state = self._state()   # lat=None, lon=None, pincode=None, extracted_location=None
        result = nearby_facilities_node(state)

        assert result["facilities"] == []
        assert len(result["reply"]) > 10    # some non-empty guidance message


# ═══════════════════════════════════════════════════════════════════════════════
# LangGraph — shops_node
# ═══════════════════════════════════════════════════════════════════════════════

class TestShopsNode:

    def _state(self, **kwargs):
        base = dict(text="nearby shops", language="en",
                    user_id="u1", pincode=None, lat=None, lon=None,
                    conversation_history=[], system_extra="", use_cache=False,
                    low_bandwidth=False, intent="shops", nearby_kind="",
                    extracted_location=None, reply="", facilities=[])
        base.update(kwargs)
        return base

    def test_named_location_skips_dynamodb(self, monkeypatch):
        """extracted_location → Google text search, DynamoDB never queried."""
        from src.agents.graph import shops_node

        db_called = {"flag": False}
        google_calls = []

        monkeypatch.setattr(
            "src.agents.graph.db.get_shops_by_pincode",
            lambda p: (db_called.update({"flag": True}) or [])
        )
        monkeypatch.setattr(
            "src.agents.graph.google_places.search_facilities",
            lambda query, kind, lat, lon, max_results, force_text_search=False, pincode=None: (
                google_calls.append({"query": query, "force_text": force_text_search})
                or [_google_place("Aklera Shop")]
            )
        )

        state = self._state(extracted_location="Aklera")
        result = shops_node(state)

        assert db_called["flag"] is False
        assert google_calls[0]["force_text"] is True
        assert "Aklera" in google_calls[0]["query"]
        assert result["facilities"][0]["name"] == "Aklera Shop"

    @mock_aws
    def test_nearby_returns_dynamodb_shops_first(self, dynamo_tables, monkeypatch):
        """No named location + pincode → DynamoDB shops take priority over Google."""
        from src.agents.graph import shops_node
        from src.services.database import db

        db.save_shop({
            "shopId": "s1", "ownerId": "o1",
            "name": "Ramu Kirana", "ownerName": "Ramu",
            "phone": "9000000001", "pincode": "110001",
            "status": "approved", "inventory": [],
            "createdAt": "2024-01-01", "updatedAt": "2024-01-01",
        })

        google_called = {"flag": False}
        monkeypatch.setattr(
            "src.agents.graph.google_places.search_facilities",
            lambda *a, **kw: (google_called.update({"flag": True}) or [])
        )

        state = self._state(pincode="110001")
        result = shops_node(state)

        assert google_called["flag"] is False       # DynamoDB hit — Google not called
        assert result["facilities"][0]["name"] == "Ramu Kirana"

    @mock_aws
    def test_nearby_falls_back_to_google_when_no_dynamo_shops(self, dynamo_tables, monkeypatch):
        """DynamoDB empty for pincode → Google Places called."""
        from src.agents.graph import shops_node

        google_called = {"flag": False}
        monkeypatch.setattr(
            "src.agents.graph.google_places.search_facilities",
            lambda *a, **kw: (
                google_called.update({"flag": True}) or [_google_place("Google Shop")]
            )
        )

        state = self._state(pincode="999999")   # no shops in DB for this pincode
        result = shops_node(state)

        assert google_called["flag"] is True
        assert result["facilities"][0]["name"] == "Google Shop"

    def test_returns_no_location_reply_when_nothing_available(self):
        """No GPS, no pincode, no extracted location → guidance message."""
        from src.agents.graph import shops_node

        state = self._state()
        result = shops_node(state)

        assert result["facilities"] == []
        assert len(result["reply"]) > 10


# ═══════════════════════════════════════════════════════════════════════════════
# LangGraph — _fast_classify routing
# ═══════════════════════════════════════════════════════════════════════════════

class TestFastClassify:

    def _classify(self, text):
        from src.agents.graph import _fast_classify
        return _fast_classify(text)

    def test_nearby_clinic_routes_to_facilities(self):
        intent, kind = self._classify("nearby clinic")
        assert intent == "nearby_facilities"
        assert kind == "clinic"

    def test_hospitals_near_me(self):
        intent, kind = self._classify("hospitals near me")
        assert intent == "nearby_facilities"
        assert kind == "hospital"

    def test_pharmacy_query(self):
        intent, kind = self._classify("any pharmacy around")
        assert intent == "nearby_facilities"
        assert kind == "pharmacy"

    def test_shops_query(self):
        intent, _ = self._classify("nearby shops")
        assert intent == "shops"

    def test_kirana_query(self):
        intent, _ = self._classify("kirana store near me")
        assert intent == "shops"

    def test_health_advice_is_ambiguous(self):
        intent, _ = self._classify("I have a fever")
        assert intent == ""     # falls through to LLM

    def test_hindi_clinic_query(self):
        intent, kind = self._classify("नजदीक क्लीनिक बताओ")
        assert intent == "nearby_facilities"

    def test_hindi_shop_query(self):
        intent, _ = self._classify("पास में दुकान")
        assert intent == "shops"

    def test_ambiguous_clinic_alone_falls_through(self):
        """'clinics' alone (no location word) → ambiguous → falls to LLM."""
        intent, _ = self._classify("clinics")
        assert intent == ""


# ═══════════════════════════════════════════════════════════════════════════════
# LangGraph — _llm_extract_location
# ═══════════════════════════════════════════════════════════════════════════════

class TestLLMExtractLocation:

    def test_extracts_city_name(self, monkeypatch):
        from src.agents.graph import _llm_extract_location
        monkeypatch.setattr("src.agents.graph.bedrock.chat", lambda *a, **kw: "Aklera")
        assert _llm_extract_location("shops in Aklera") == "Aklera"

    def test_returns_none_when_llm_says_none(self, monkeypatch):
        from src.agents.graph import _llm_extract_location
        monkeypatch.setattr("src.agents.graph.bedrock.chat", lambda *a, **kw: "NONE")
        assert _llm_extract_location("nearby clinics") is None

    def test_strips_punctuation_from_response(self, monkeypatch):
        from src.agents.graph import _llm_extract_location
        monkeypatch.setattr("src.agents.graph.bedrock.chat", lambda *a, **kw: '"Jaipur."')
        assert _llm_extract_location("shops in Jaipur") == "Jaipur"

    def test_returns_none_on_empty_response(self, monkeypatch):
        from src.agents.graph import _llm_extract_location
        monkeypatch.setattr("src.agents.graph.bedrock.chat", lambda *a, **kw: "")
        assert _llm_extract_location("nearby shops") is None

    def test_returns_none_when_bedrock_throws(self, monkeypatch):
        from src.agents.graph import _llm_extract_location
        monkeypatch.setattr("src.agents.graph.bedrock.chat",
                            lambda *a, **kw: (_ for _ in ()).throw(RuntimeError("bedrock down")))
        assert _llm_extract_location("clinics in Delhi") is None   # no crash

    def test_none_returned_gracefully_in_classify_node(self, monkeypatch):
        """classify_node sets extracted_location=None when LLM returns NONE."""
        from src.agents.graph import classify_node
        monkeypatch.setattr("src.agents.graph.bedrock.chat", lambda *a, **kw: "NONE")

        state = dict(text="nearby clinics", language="en", user_id="u1",
                     pincode=None, lat=None, lon=None, conversation_history=[],
                     system_extra="", use_cache=False, low_bandwidth=False,
                     intent="", nearby_kind="", extracted_location=None,
                     reply="", facilities=[])
        result = classify_node(state)
        assert result["extracted_location"] is None
        assert result["intent"] == "nearby_facilities"


# ═══════════════════════════════════════════════════════════════════════════════
# No-location reply — all 8 languages
# ═══════════════════════════════════════════════════════════════════════════════

class TestNoLocationReply:

    @pytest.mark.parametrize("lang", ["hi", "en", "mr", "ta", "te", "kn", "bn", "gu"])
    def test_reply_non_empty_for_all_languages(self, lang):
        from src.agents.graph import _no_location_reply
        msg = _no_location_reply(lang)
        assert isinstance(msg, str) and len(msg) > 10

    def test_unknown_language_falls_back_to_english(self):
        from src.agents.graph import _no_location_reply
        msg = _no_location_reply("xx")
        en_msg = _no_location_reply("en")
        assert msg == en_msg
