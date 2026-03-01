"""
Overpass API (OpenStreetMap) service.

Finds nearby clinics, pharmacies, and hospitals using real GPS coordinates.
No local data seeding required — queries live, global OSM data.
"""
import json
import urllib.parse
import urllib.request
from typing import List

from src.utils.config import config
from src.utils.logger import logger

_OVERPASS_URL = "https://overpass-api.de/api/interpreter"
_USER_AGENT = "GramSathi/1.0 (contact@gramsathi.in)"

_AMENITY_MAP: dict = {
    "clinic":     ["clinic"],
    "pharmacy":   ["pharmacy"],
    "hospital":   ["hospital"],
    "facilities": ["clinic", "hospital", "pharmacy"],
}


def _build_query(lat: float, lon: float, amenities: List[str], radius: int) -> str:
    nodes = "\n".join(
        f'  node["amenity"="{a}"](around:{radius},{lat},{lon});'
        for a in amenities
    )
    return f"[out:json][timeout:10];\n(\n{nodes}\n);\nout;"


def _parse_elements(elements: list, max_results: int) -> List[dict]:
    results = []
    for el in elements[:max_results]:
        tags = el.get("tags", {})
        name = (
            tags.get("name")
            or tags.get("name:en")
            or tags.get("name:hi")
            or "Unknown"
        )
        addr_parts = list(filter(None, [
            tags.get("addr:housenumber", ""),
            tags.get("addr:street", ""),
            tags.get("addr:city", ""),
        ]))
        results.append({
            "name": name,
            "category": tags.get("amenity", ""),
            "phone": tags.get("phone") or tags.get("contact:phone") or "",
            "address": " ".join(addr_parts) or tags.get("addr:full", ""),
            "lat": el.get("lat"),
            "lon": el.get("lon"),
            "source": "osm",
        })
    return results


class OverpassService:
    def search_nearby(
        self,
        lat: float,
        lon: float,
        kind: str = "facilities",
        max_results: int = 5,
    ) -> List[dict]:
        """
        Returns up to max_results OSM places near (lat, lon).
        kind: 'clinic' | 'pharmacy' | 'hospital' | 'facilities' (all three)
        Returns [] on any network or parse error — caller must handle fallback.
        """
        amenities = _AMENITY_MAP.get(kind, _AMENITY_MAP["facilities"])
        query = _build_query(lat, lon, amenities, config.OVERPASS_RADIUS_METERS)
        payload = urllib.parse.urlencode({"data": query}).encode()

        req = urllib.request.Request(
            _OVERPASS_URL,
            data=payload,
            headers={
                "User-Agent": _USER_AGENT,
                "Content-Type": "application/x-www-form-urlencoded",
            },
        )
        try:
            with urllib.request.urlopen(req, timeout=12) as resp:
                result = json.loads(resp.read())
        except Exception as exc:
            logger.warning("overpass_request_failed", lat=lat, lon=lon, kind=kind, error=str(exc))
            return []

        elements = result.get("elements", [])
        logger.info("overpass_results", lat=lat, lon=lon, kind=kind, count=len(elements))
        return _parse_elements(elements, max_results)


overpass = OverpassService()
