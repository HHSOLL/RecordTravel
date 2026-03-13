#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path

from PIL import Image

from _common import ASSET_MANIFEST_PATH, BORDERS_OUTPUT, COUNTRY_ID_OUTPUT, COUNTRY_PALETTE_PATH, DAY_OUTPUT, STARFIELD_OUTPUT, decode_country_id_rgb, read_json


def seam_check(image: Image.Image) -> bool:
    width, height = image.size
    failures = 0
    sample_rows = range(0, height, max(1, height // 32))
    for y in sample_rows:
        left = image.getpixel((0, y))
        right = image.getpixel((width - 1, y))
        if sum(abs(int(left[i]) - int(right[i])) for i in range(3)) > 40:
            failures += 1
    return failures <= 2


def border_alignment() -> bool:
    borders = Image.open(BORDERS_OUTPUT).convert('RGBA')
    country = Image.open(COUNTRY_ID_OUTPUT).convert('RGBA')
    width, height = borders.size
    checks = 0
    aligned = 0
    for y in range(1, height - 1, max(1, height // 128)):
        for x in range(1, width - 1, max(1, width // 128)):
            if borders.getpixel((x, y))[3] < 64:
                continue
            checks += 1
            center = country.getpixel((x, y))[:3]
            neighbors = {
                country.getpixel((x - 1, y))[:3],
                country.getpixel((x + 1, y))[:3],
                country.getpixel((x, y - 1))[:3],
                country.getpixel((x, y + 1))[:3],
            }
            if len(neighbors | {center}) > 1:
                aligned += 1
    return checks > 0 and aligned / checks >= 0.55


def centroid_lookup() -> bool:
    palette = read_json(COUNTRY_PALETTE_PATH)
    country = Image.open(COUNTRY_ID_OUTPUT).convert('RGBA')
    width, height = country.size
    required = {'US', 'BR', 'FR', 'EG', 'IN', 'KR', 'AU', 'ZA'}
    matched = set()
    for entry in palette['entries']:
        iso = entry['iso_a2']
        if iso not in required:
            continue
        lon = entry['center_lon']
        lat = entry['center_lat']
        x = round(((lon + 180.0) / 360.0) * (width - 1))
        y = round(((90.0 - lat) / 180.0) * (height - 1))
        rgb = country.getpixel((x, y))[:3]
        if decode_country_id_rgb(tuple(rgb)) == entry['id']:
            matched.add(iso)
    ocean_rgb = country.getpixel((width // 2, height // 2))[:3]
    return matched == required and decode_country_id_rgb(tuple(ocean_rgb)) == 0


def orientation_check() -> bool:
    country = Image.open(COUNTRY_ID_OUTPUT).convert('RGBA')
    width, height = country.size
    samples = {
        'australia': (134.0, -25.0),
        'south_america': (-60.0, -15.0),
        'greenland': (-42.0, 72.0),
        'africa': (20.0, 5.0),
    }
    hits = 0
    for lon, lat in samples.values():
        x = round(((lon + 180.0) / 360.0) * (width - 1))
        y = round(((90.0 - lat) / 180.0) * (height - 1))
        if decode_country_id_rgb(tuple(country.getpixel((x, y))[:3])) != 0:
            hits += 1
    return hits == len(samples)


def background_check() -> bool:
    image = Image.open(STARFIELD_OUTPUT).convert('RGB')
    total = 0
    count = 0
    for y in range(0, image.height, max(1, image.height // 128)):
        for x in range(0, image.width, max(1, image.width // 128)):
            r, g, b = image.getpixel((x, y))
            total += 0.2126 * r + 0.7152 * g + 0.0722 * b
            count += 1
    mean_luminance = total / max(1, count)
    return 6 <= mean_luminance <= 40


def main() -> None:
    results = {
        'seam_day': seam_check(Image.open(DAY_OUTPUT).convert('RGB')),
        'seam_borders': seam_check(Image.open(BORDERS_OUTPUT).convert('RGBA')),
        'border_alignment': border_alignment(),
        'centroid_lookup': centroid_lookup(),
        'orientation': orientation_check(),
        'background_exposure': background_check(),
    }
    print(json.dumps(results, indent=2))
    if not all(results.values()):
        raise SystemExit(1)


if __name__ == '__main__':
    main()
