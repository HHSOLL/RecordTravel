#!/usr/bin/env python3

from __future__ import annotations

import json
import math
import urllib.request
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "apps/mobile_app/assets/globe/record_country_shapes.json"
SOURCE_URL = (
    "https://raw.githubusercontent.com/datasets/geo-countries/master/data/"
    "countries.geojson"
)
SIMPLIFY_TOLERANCE = 0.35


def _perpendicular_distance(point, start, end):
    if start == end:
      return math.dist(point, start)
    x0, y0 = point
    x1, y1 = start
    x2, y2 = end
    numerator = abs((y2 - y1) * x0 - (x2 - x1) * y0 + x2 * y1 - y2 * x1)
    denominator = math.hypot(y2 - y1, x2 - x1)
    return numerator / denominator


def _rdp(points, epsilon):
    if len(points) < 3:
        return points
    max_distance = 0.0
    split_index = 0
    start = points[0]
    end = points[-1]
    for index in range(1, len(points) - 1):
        distance = _perpendicular_distance(points[index], start, end)
        if distance > max_distance:
            max_distance = distance
            split_index = index
    if max_distance > epsilon:
        left = _rdp(points[: split_index + 1], epsilon)
        right = _rdp(points[split_index:], epsilon)
        return left[:-1] + right
    return [start, end]


def _normalize_ring(ring):
    cleaned = []
    for lng, lat in ring:
        point = [round(lat, 4), round(lng, 4)]
        if not cleaned or cleaned[-1] != point:
            cleaned.append(point)
    if len(cleaned) > 3 and cleaned[0] == cleaned[-1]:
        cleaned = cleaned[:-1]
    if len(cleaned) < 3:
        return []
    simplified = _rdp(cleaned, SIMPLIFY_TOLERANCE)
    if len(simplified) < 3:
        simplified = cleaned[:]
    return simplified


def _iter_outer_rings(geometry):
    if geometry["type"] == "Polygon":
        if geometry["coordinates"]:
            yield geometry["coordinates"][0]
        return
    if geometry["type"] == "MultiPolygon":
        for polygon in geometry["coordinates"]:
            if polygon:
                yield polygon[0]


def main():
    raw = urllib.request.urlopen(SOURCE_URL, timeout=30).read()
    data = json.loads(raw)
    output = []
    for feature in data["features"]:
        props = feature.get("properties", {})
        code = props.get("ISO3166-1-Alpha-2")
        name = props.get("name")
        geometry = feature.get("geometry")
        if (
            not code
            or len(code) != 2
            or not code.isalpha()
            or not name
            or not geometry
        ):
            continue
        polygons = []
        lat_sum = 0.0
        lng_sum = 0.0
        point_count = 0
        min_lat = 90.0
        max_lat = -90.0
        min_lng = 180.0
        max_lng = -180.0
        for ring in _iter_outer_rings(geometry):
            normalized = _normalize_ring(ring)
            if len(normalized) < 3:
                continue
            polygons.append(normalized)
            for lat, lng in normalized:
                lat_sum += lat
                lng_sum += lng
                point_count += 1
                min_lat = min(min_lat, lat)
                max_lat = max(max_lat, lat)
                min_lng = min(min_lng, lng)
                max_lng = max(max_lng, lng)
        if not polygons or point_count == 0:
            continue
        output.append(
            {
                "code": code,
                "name": name,
                "centroidLat": round(lat_sum / point_count, 4),
                "centroidLng": round(lng_sum / point_count, 4),
                "minLat": round(min_lat, 4),
                "maxLat": round(max_lat, 4),
                "minLng": round(min_lng, 4),
                "maxLng": round(max_lng, 4),
                "polygons": polygons,
            }
        )
    output.sort(key=lambda item: item["code"])
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    OUTPUT.write_text(
        json.dumps({"countries": output}, ensure_ascii=True, separators=(",", ":"))
    )
    print(f"wrote {OUTPUT}")


if __name__ == "__main__":
    main()
