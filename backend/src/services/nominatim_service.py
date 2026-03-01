"""
Nominatim (OpenStreetMap) geocoding service.

Converts a city / area name → (lat, lon).
Results are cached permanently in DynamoDB — city coordinates are stable,
so there is no reason to re-fetch them.
"""
import json
import urllib.parse
import urllib.request
from typing import Optional, Tuple

from src.services.database import db
from src.utils.logger import logger

_NOMINATIM_URL = "https://nominatim.openstreetmap.org/search"
# OSM requires a meaningful User-Agent (https://operations.osmfoundation.org/policies/nominatim/)
_USER_AGENT = "GramSathi/1.0 (contact@gramsathi.in)"


class NominatimService:
    def geocode(self, location: str) -> Optional[Tuple[float, float]]:
        """
        Returns (lat, lon) for the given location, or None if not resolvable.
        Hits DynamoDB cache first; falls back to live Nominatim only on a miss.
        """
        key = location.lower().strip()

        cached = db.get_geo_cache(key)
        if cached:
            return float(cached["lat"]), float(cached["lon"])

        params = urllib.parse.urlencode({
            "q": f"{location},India",
            "format": "json",
            "limit": "1",
        })
        req = urllib.request.Request(
            f"{_NOMINATIM_URL}?{params}",
            headers={"User-Agent": _USER_AGENT},
        )
        try:
            with urllib.request.urlopen(req, timeout=5) as resp:
                data = json.loads(resp.read())
        except Exception as exc:
            logger.warning("nominatim_request_failed", location=location, error=str(exc))
            return None

        if not data:
            logger.info("nominatim_no_result", location=location)
            return None

        lat = float(data[0]["lat"])
        lon = float(data[0]["lon"])

        db.set_geo_cache(key, lat, lon)
        logger.info("nominatim_geocoded", location=location, lat=lat, lon=lon)
        return lat, lon


nominatim = NominatimService()
