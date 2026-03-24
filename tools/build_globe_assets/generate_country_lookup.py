#!/usr/bin/env python3
"""Generate a UV lookup grid for country-surface picking.

The output is a binary grid where each pixel stores an 8-bit palette index.
Index 0 is reserved for ocean / no-country. The palette metadata stores the
country code for each index.

This keeps runtime picking cheap:
ray -> sphere UV -> grid sample -> country code.
"""

from __future__ import annotations

import argparse
import json
import math
import urllib.request
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable

SOURCE_URL = (
    "https://raw.githubusercontent.com/vasturiano/react-globe.gl/master/"
    "example/datasets/ne_110m_admin_0_countries.geojson"
)

ISO_A2_OVERRIDES = {
    "France": "FR",
    "Norway": "NO",
    "Northern Cyprus": "CY",
    "Somaliland": "SO",
}


@dataclass(frozen=True)
class Ring:
    points: list[tuple[float, float]]
    min_x: float
    max_x: float
    min_y: float
    max_y: float


@dataclass(frozen=True)
class PolygonPart:
    exterior: Ring
    holes: list[Ring]
    area: float


@dataclass(frozen=True)
class CountryFeature:
    code: str
    parts: list[PolygonPart]
    area: float


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--width", type=int, default=1024)
    parser.add_argument("--height", type=int, default=512)
    parser.add_argument(
        "--binary-output",
        type=Path,
        required=True,
    )
    parser.add_argument(
        "--palette-output",
        type=Path,
        required=True,
    )
    args = parser.parse_args()

    geojson = _load_geojson()
    features = _build_features(geojson, args.width, args.height)
    palette = [""] + sorted({feature.code for feature in features})
    country_to_index = {code: index for index, code in enumerate(palette) if code}

    grid = bytearray(args.width * args.height)
    for feature in sorted(features, key=lambda item: item.area, reverse=True):
        index = country_to_index[feature.code]
        for part in feature.parts:
            _rasterize_part(grid, args.width, args.height, index, part)

    args.binary_output.parent.mkdir(parents=True, exist_ok=True)
    args.binary_output.write_bytes(grid)
    args.palette_output.parent.mkdir(parents=True, exist_ok=True)
    args.palette_output.write_text(
        json.dumps(
            {
                "version": 1,
                "width": args.width,
                "height": args.height,
                "countryCodes": palette,
                "sourceUrl": SOURCE_URL,
            },
            indent=2,
        )
        + "\n",
        encoding="utf-8",
    )

    print(
        f"Wrote {args.binary_output} ({len(grid)} bytes) and "
        f"{args.palette_output} ({len(palette) - 1} countries)"
    )


def _load_geojson() -> dict:
    with urllib.request.urlopen(SOURCE_URL, timeout=30) as response:
        return json.load(response)


def _build_features(
    geojson: dict,
    width: int,
    height: int,
) -> list[CountryFeature]:
    features: list[CountryFeature] = []
    for raw_feature in geojson["features"]:
        properties = raw_feature["properties"]
        code = _country_code(properties)
        if code is None:
            continue

        geometry = raw_feature["geometry"]
        geometry_type = geometry["type"]
        coordinates = geometry["coordinates"]

        polygon_sets: Iterable[list] = (
            coordinates
            if geometry_type == "MultiPolygon"
            else [coordinates]
        )
        parts = [
            _build_polygon_part(rings, width, height)
            for rings in polygon_sets
            if rings
        ]
        parts = [part for part in parts if part is not None]
        if not parts:
            continue
        area = sum(part.area for part in parts)
        features.append(
            CountryFeature(
                code=code,
                parts=parts,
                area=area,
            )
        )

    return features


def _country_code(properties: dict) -> str | None:
    code = properties.get("ISO_A2")
    if isinstance(code, str) and len(code) == 2 and code != "-99":
        return code.upper()
    admin = properties.get("ADMIN")
    if isinstance(admin, str):
        override = ISO_A2_OVERRIDES.get(admin)
        if override:
            return override
    return None


def _build_polygon_part(
    rings: list,
    width: int,
    height: int,
) -> PolygonPart | None:
    if not rings:
        return None

    exterior = _build_ring(rings[0], width, height)
    if exterior is None:
        return None
    holes = [
        built
        for ring in rings[1:]
        if (built := _build_ring(ring, width, height)) is not None
    ]
    area = abs(_polygon_area(exterior.points)) - sum(
        abs(_polygon_area(hole.points)) for hole in holes
    )
    return PolygonPart(
        exterior=exterior,
        holes=holes,
        area=max(area, 0.0),
    )


def _build_ring(
    ring: list,
    width: int,
    height: int,
) -> Ring | None:
    if len(ring) < 3:
        return None

    projected: list[tuple[float, float]] = []
    for lon, lat, *_ in ring:
        x = ((lon + 180.0) / 360.0) * width
        y = ((90.0 - lat) / 180.0) * height
        projected.append((x, y))

    xs = [point[0] for point in projected]
    if max(xs) - min(xs) > width / 2:
        adjusted = [
            (x + width if x < width / 2 else x, y)
            for x, y in projected
        ]
    else:
        adjusted = projected

    adj_x = [point[0] for point in adjusted]
    adj_y = [point[1] for point in adjusted]
    return Ring(
        points=adjusted,
        min_x=min(adj_x),
        max_x=max(adj_x),
        min_y=min(adj_y),
        max_y=max(adj_y),
    )


def _polygon_area(points: list[tuple[float, float]]) -> float:
    area = 0.0
    for index in range(len(points)):
        x1, y1 = points[index]
        x2, y2 = points[(index + 1) % len(points)]
        area += x1 * y2 - x2 * y1
    return area / 2.0


def _rasterize_part(
    grid: bytearray,
    width: int,
    height: int,
    index: int,
    part: PolygonPart,
) -> None:
    min_x = math.floor(part.exterior.min_x)
    max_x = math.ceil(part.exterior.max_x)
    min_y = max(0, math.floor(part.exterior.min_y))
    max_y = min(height - 1, math.ceil(part.exterior.max_y))

    for y in range(min_y, max_y + 1):
        py = y + 0.5
        for x in range(min_x, max_x + 1):
            px = x + 0.5
            if not _point_in_ring(px, py, part.exterior.points):
                continue
            if any(_point_in_ring(px, py, hole.points) for hole in part.holes):
                continue
            grid[y * width + (x % width)] = index


def _point_in_ring(
    x: float,
    y: float,
    ring: list[tuple[float, float]],
) -> bool:
    inside = False
    previous_index = len(ring) - 1
    for index, (x1, y1) in enumerate(ring):
        x2, y2 = ring[previous_index]
        intersects = ((y1 > y) != (y2 > y)) and (
            x < (x2 - x1) * (y - y1) / ((y2 - y1) or 1e-12) + x1
        )
        if intersects:
            inside = not inside
        previous_index = index
    return inside


if __name__ == "__main__":
    main()
