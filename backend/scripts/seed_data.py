"""
Seed script: clinics, pharmacies, and shops near Kota (multiple nearby pincodes).

Usage (from backend/ with venv active and deps installed):
  IS_OFFLINE=1 python3 -m scripts.seed_data   # MongoDB (local)
  python3 -m scripts.seed_data                 # DynamoDB (set AWS env)

Location: Kota, Rajasthan — nearby pincodes 324001, 324002, 324005, 324007, 324008, 324009
Reference: 25.2138° N, 75.8648° E (lat/lng with small offsets per entry)
"""
from __future__ import annotations

import os
import sys
from datetime import datetime, timezone
from uuid import uuid4

# Add backend src to path when run as script
sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

try:
    from src.services.database import db
    from src.utils.decimal_utils import to_decimal
except ModuleNotFoundError as e:
    if "pymongo" in str(e):
        print("Error: pymongo is not installed. Install backend dependencies first:\n")
        print("  cd backend")
        print("  pip install -r requirements.txt   # or: pip3 install -r requirements.txt")
        print("\nIf you use a virtual environment, activate it before running the above.")
        sys.exit(1)
    raise

# Kota region: base coordinates and nearby pincodes
KOTA_LAT = 25.2138
KOTA_LNG = 75.8648
NEARBY_PINCODES = ("324001", "324002", "324005", "324007", "324008", "324009")


def _lat(offset_lat: float = 0) -> float:
    return round(KOTA_LAT + offset_lat, 4)


def _lng(offset_lng: float = 0) -> float:
    return round(KOTA_LNG + offset_lng, 4)


def _now() -> str:
    return datetime.now(timezone.utc).isoformat()


def _shop(
    name: str,
    owner_name: str,
    phone: str,
    category: str | None,
    pincode: str,
    lat: float,
    lng: float,
    address: str,
    inventory: list | None = None,
) -> dict:
    inv = inventory or []
    return {
        "shopId": str(uuid4()),
        "ownerId": f"seed-{category or 'shop'}-{uuid4().hex[:8]}",
        "name": name,
        "ownerName": owner_name,
        "phone": phone,
        "pincode": pincode,
        "address": address,
        "lat": lat,
        "lng": lng,
        "status": "approved",
        "inventory": inv,
        "createdAt": _now(),
        "updatedAt": _now(),
        **({"category": category} if category else {}),
    }


# ─── Clinics (health/nearby) ─────────────────────────────────────────────────
CLINICS = [
    _shop("Sharma Family Clinic", "Dr. Rajesh Sharma", "9876543210", "clinic", "324008", _lat(0.002), _lng(-0.001), "Near Bus Stand, Station Road, Kota 324008"),
    _shop("Kota City Clinic", "Dr. Priya Mehta", "9876543211", "clinic", "324001", _lat(-0.003), _lng(0.002), "Mahaveer Nagar, Kota 324001"),
    _shop("Gramin Swasthya Kendra", "Dr. Suresh Gupta", "9876543212", "clinic", "324002", _lat(0.005), _lng(0.004), "Village Panchayat Road, Kota 324002"),
    _shop("Railway Road Clinic", "Dr. Amit Jain", "9876543213", "clinic", "324005", _lat(-0.002), _lng(0.003), "Railway Road, Kota 324005"),
    _shop("Civil Lines Clinic", "Dr. Kavita Sharma", "9876543214", "clinic", "324007", _lat(0.004), _lng(-0.002), "Civil Lines, Kota 324007"),
    _shop("Subhash Nagar Clinic", "Dr. Ramesh Verma", "9876543215", "clinic", "324009", _lat(-0.001), _lng(-0.003), "Subhash Nagar, Kota 324009"),
]

# ─── Pharmacies (health/nearby) ─────────────────────────────────────────────
PHARMACIES = [
    _shop("Kota Medical Store", "Vikram Singh", "9876543220", "pharmacy", "324008", _lat(-0.001), _lng(0.003), "Opposite City Hospital, Kota 324008"),
    _shop("Apna Pharmacy", "Anita Devi", "9876543221", "pharmacy", "324001", _lat(0.004), _lng(-0.002), "Main Market, Kota 324001"),
    _shop("Jan Aushadhi Kendra", "Ramesh Kumar", "9876543222", "pharmacy", "324002", _lat(-0.002), _lng(-0.003), "Near Railway Station, Kota 324002"),
    _shop("City Medical & General", "Sunita Meena", "9876543223", "pharmacy", "324005", _lat(0.001), _lng(0.001), "Gandhi Nagar, Kota 324005"),
    _shop("Swasthya Pharmacy", "Manoj Kumar", "9876543224", "pharmacy", "324007", _lat(-0.004), _lng(0.002), "Indira Colony, Kota 324007"),
    _shop("Kota Chemists", "Pooja Yadav", "9876543225", "pharmacy", "324009", _lat(0.003), _lng(-0.001), "Borkhera Road, Kota 324009"),
]

# ─── Hospitals (health/nearby) ───────────────────────────────────────────────
HOSPITALS = [
    _shop("Kota General Hospital", "Dr. Meera Nair", "9876543230", "hospital", "324008", _lat(0.001), _lng(0.001), "Civil Lines, Kota 324008"),
    _shop("Jawahar Lal Nehru Hospital", "Dr. S. K. Gupta", "9876543231", "hospital", "324005", _lat(-0.003), _lng(0.004), "Mahaveer Nagar, Kota 324005"),
]

# ─── General shops (commerce/shops) ─────────────────────────────────────────
SHOPS = [
    _shop("Ramu Kirana Store", "Ramu Lal", "9876543240", None, "324008", _lat(0.003), _lng(0.001), "Village Market, Kota 324008", inventory=[
        {"itemId": "i1", "name": "Atta", "nameHindi": "आटा", "price": 45.0, "unit": "kg", "stockQty": 50, "category": "grocery"},
        {"itemId": "i2", "name": "Rice", "nameHindi": "चावल", "price": 55.0, "unit": "kg", "stockQty": 40, "category": "grocery"},
        {"itemId": "i3", "name": "Dal", "nameHindi": "दाल", "price": 120.0, "unit": "kg", "stockQty": 25, "category": "grocery"},
    ]),
    _shop("Laxmi General Store", "Laxmi Devi", "9876543241", None, "324001", _lat(-0.004), _lng(0.002), "Main Road, Kota 324001", inventory=[
        {"itemId": "i1", "name": "Milk", "nameHindi": "दूध", "price": 60.0, "unit": "litre", "stockQty": 20, "category": "dairy"},
        {"itemId": "i2", "name": "Oil", "nameHindi": "तेल", "price": 180.0, "unit": "litre", "stockQty": 30, "category": "grocery"},
        {"itemId": "i3", "name": "Sugar", "nameHindi": "चीनी", "price": 42.0, "unit": "kg", "stockQty": 45, "category": "grocery"},
    ]),
    _shop("Gaon Bazaar", "Sohan Lal", "9876543242", None, "324002", _lat(0.002), _lng(-0.004), "Gaon Road, Kota 324002", inventory=[
        {"itemId": "i1", "name": "Soap", "nameHindi": "साबुन", "price": 30.0, "unit": "piece", "stockQty": 60, "category": "personal"},
        {"itemId": "i2", "name": "Tea", "nameHindi": "चाय", "price": 250.0, "unit": "kg", "stockQty": 15, "category": "grocery"},
    ]),
    _shop("Borkhera Kirana", "Raju Meena", "9876543243", None, "324005", _lat(0.001), _lng(0.002), "Borkhera, Kota 324005", inventory=[
        {"itemId": "i1", "name": "Biscuits", "nameHindi": "बिस्कुट", "price": 30.0, "unit": "pack", "stockQty": 40, "category": "grocery"},
        {"itemId": "i2", "name": "Salt", "nameHindi": "नमक", "price": 22.0, "unit": "kg", "stockQty": 35, "category": "grocery"},
    ]),
    _shop("Indira Colony Store", "Geeta Bai", "9876543244", None, "324007", _lat(-0.002), _lng(0.001), "Indira Colony, Kota 324007", inventory=[
        {"itemId": "i1", "name": "Wheat", "nameHindi": "गेहूं", "price": 28.0, "unit": "kg", "stockQty": 80, "category": "grocery"},
        {"itemId": "i2", "name": "Pulses", "nameHindi": "दाल", "price": 95.0, "unit": "kg", "stockQty": 30, "category": "grocery"},
    ]),
    _shop("Mahaveer Nagar Store", "Kishan Lal", "9876543245", None, "324009", _lat(0.003), _lng(-0.002), "Mahaveer Nagar, Kota 324009", inventory=[
        {"itemId": "i1", "name": "Detergent", "nameHindi": "डिटर्जेंट", "price": 85.0, "unit": "kg", "stockQty": 25, "category": "personal"},
        {"itemId": "i2", "name": "Matchbox", "nameHindi": "माचिस", "price": 2.0, "unit": "piece", "stockQty": 100, "category": "grocery"},
    ]),
]


def seed() -> None:
    all_entries = CLINICS + PHARMACIES + HOSPITALS + SHOPS

    for item in all_entries:
        payload = to_decimal(item)
        db.save_shop(payload)
        print(f"  [{item['pincode']}] {item['name']} ({item.get('category', 'shop')})")

    pincodes_str = ", ".join(NEARBY_PINCODES)
    print(f"\nDone. Inserted {len(all_entries)} entries across pincodes: {pincodes_str}")
    print(f"  Clinics: {len(CLINICS)}, Pharmacies: {len(PHARMACIES)}, Hospitals: {len(HOSPITALS)}, Shops: {len(SHOPS)}")


if __name__ == "__main__":
    print("Seeding clinics, pharmacies, and shops — Kota region (pincodes 324001–324009)...\n")
    seed()
