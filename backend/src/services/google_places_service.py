"""
Google Places API (New) service.

Replaces Overpass + Nominatim with a single service that handles both
location geocoding and facility/shop discovery in one API call.

Text Search  → used when user mentions a city  ("clinics in Kota")
Nearby Search → used when GPS coordinates are available from the app
"""
import json
import urllib.error
import urllib.request
from typing import List, Optional

from src.utils.config import config
from src.utils.logger import logger

_TEXT_SEARCH_URL = "https://places.googleapis.com/v1/places:searchText"
_NEARBY_SEARCH_URL = "https://places.googleapis.com/v1/places:searchNearby"

# Fields we request — only pay for what we need
_FIELD_MASK = (
    "places.displayName,"
    "places.formattedAddress,"
    "places.nationalPhoneNumber,"
    "places.location,"
    "places.primaryTypeDisplayName,"
    "places.rating"
)

# Google Places API (New) valid types for includedTypes in searchNearby.
# Only types from Table A are accepted — "clinic" is NOT a valid standalone
# type so we map it to "doctor" which covers clinics and general practitioners.
_INCLUDED_TYPES: dict = {
    "clinic":     ["doctor"],
    "pharmacy":   ["pharmacy"],
    "hospital":   ["hospital"],
    "facilities": ["doctor", "hospital", "pharmacy"],
    "shops":      ["grocery_store", "supermarket", "convenience_store"],
}

# Radius ladder for auto-expansion when no results are found at a tighter radius
_NEARBY_RADIUS_LADDER = [10_000, 20_000, 50_000]  # 10 km → 20 km → 50 km

# Human-readable search terms per kind (used to build pincode-anchored queries)
_KIND_SEARCH_TERM: dict = {
    "clinic":     "clinics and doctors",
    "pharmacy":   "pharmacies",
    "hospital":   "hospitals",
    "facilities": "clinics hospitals pharmacies",
    "shops":      "shops and stores",
}


class GooglePlacesService:
    def search_facilities(
        self,
        query: str,
        kind: str = "facilities",
        lat: Optional[float] = None,
        lon: Optional[float] = None,
        max_results: int = 5,
        force_text_search: bool = False,
        pincode: Optional[str] = None,
    ) -> List[dict]:
        """
        Return up to max_results places matching `kind`.

        Routing decision (in priority order):
          1. GPS + no named-location override  → Nearby Search (10 km, auto-expands to 20/50 km)
          2. force_text_search=True            → Text Search with user's raw query (city specified)
          3. No GPS, pincode available         → Text Search anchored to pincode (e.g. "clinics near 324008, India")
          4. No GPS, no pincode                → Text Search with raw query + ", India"
        """
        if not config.GOOGLE_PLACES_API_KEY:
            logger.warning("google_places_key_missing")
            return []

        if lat is not None and lon is not None and not force_text_search:
            # Case 1: precise GPS-based search
            places = self._nearby_search(lat, lon, kind, max_results)
        elif force_text_search:
            # Case 2: user named a specific city — use their query verbatim
            places = self._text_search(query, kind, max_results, pincode=None)
        else:
            # Cases 3 & 4: no GPS — anchor to pincode if we have one
            places = self._text_search(query, kind, max_results, pincode=pincode)

        return places[:max_results]

    # ── Text Search ────────────────────────────────────────────────────────────

    def _text_search(self, query: str, kind: str, max_results: int, pincode: Optional[str] = None) -> List[dict]:
        if pincode:
            # Build a precise, pincode-anchored query instead of the vague raw text.
            # e.g. "nearby clinics" + pincode "324008"  →  "clinics and doctors near 324008, India"
            kind_term = _KIND_SEARCH_TERM.get(kind, kind)
            search_query = f"{kind_term} near {pincode}, India"
        else:
            search_query = query if "india" in query.lower() else f"{query}, India"

        types = _INCLUDED_TYPES.get(kind, _INCLUDED_TYPES["facilities"])
        payload: dict = {
            "textQuery": search_query,
            "maxResultCount": min(max_results, 20),
            "languageCode": "en",
        }
        # Use the first type as a primary filter to narrow results
        if types:
            payload["includedType"] = types[0]

        logger.info("google_places_text_search", query=search_query, kind=kind)
        return self._call(_TEXT_SEARCH_URL, payload)

    # ── Nearby Search ──────────────────────────────────────────────────────────

    def _nearby_search(self, lat: float, lon: float, kind: str, max_results: int) -> List[dict]:
        types = _INCLUDED_TYPES.get(kind, _INCLUDED_TYPES["facilities"])
        for radius in _NEARBY_RADIUS_LADDER:
            payload: dict = {
                "includedTypes": types,
                "maxResultCount": min(max_results, 20),
                "locationRestriction": {
                    "circle": {
                        "center": {"latitude": lat, "longitude": lon},
                        "radius": float(radius),
                    }
                },
            }
            logger.info("google_places_nearby_search", lat=lat, lon=lon, kind=kind, radius_km=radius // 1000)
            results = self._call(_NEARBY_SEARCH_URL, payload)
            if results:
                return results
            logger.info("google_places_no_results_expanding", radius_km=radius // 1000)
        return []

    # ── HTTP ───────────────────────────────────────────────────────────────────

    def _call(self, url: str, payload: dict) -> List[dict]:
        data = json.dumps(payload).encode()
        req = urllib.request.Request(
            url,
            data=data,
            headers={
                "Content-Type": "application/json",
                "X-Goog-Api-Key": config.GOOGLE_PLACES_API_KEY,
                "X-Goog-FieldMask": _FIELD_MASK,
            },
        )
        try:
            with urllib.request.urlopen(req, timeout=10) as resp:
                body = json.loads(resp.read())
        except urllib.error.HTTPError as exc:
            try:
                err_body = exc.read().decode("utf-8", errors="replace")
            except Exception:
                err_body = ""
            logger.warning("google_places_request_failed",
                           status=exc.code, error=str(exc), body=err_body)
            return []
        except Exception as exc:
            logger.warning("google_places_request_failed", error=str(exc))
            return []

        places = body.get("places", [])
        logger.info("google_places_response", count=len(places))
        return self._parse(places)

    # ── Parser ─────────────────────────────────────────────────────────────────

    def _parse(self, places: list) -> List[dict]:
        results = []
        seen: set = set()
        for place in places:
            name = (place.get("displayName") or {}).get("text", "").strip()
            if not name or name.lower() in seen:
                continue
            seen.add(name.lower())

            location = place.get("location") or {}
            category = (
                (place.get("primaryTypeDisplayName") or {}).get("text", "")
            )
            results.append({
                "name": name,
                "address": place.get("formattedAddress", ""),
                "phone": place.get("nationalPhoneNumber", ""),
                "lat": location.get("latitude"),
                "lon": location.get("longitude"),
                "category": category,
                "rating": place.get("rating"),
                "source": "google",
            })
        return results


google_places = GooglePlacesService()
