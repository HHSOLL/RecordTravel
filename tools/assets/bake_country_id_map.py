#!/usr/bin/env python3
from __future__ import annotations

import argparse
import tempfile
import zipfile
from pathlib import Path

import shapefile
from PIL import Image, ImageDraw

from _common import COUNTRY_ID_OUTPUT, COUNTRY_PALETTE_PATH, FIRST_WAVE_SOURCES, PALETTE_VERSION, SCHEMA_VERSION, encode_country_id_rgb, ensure_dirs, raw_source_path, utc_now, write_json

SIZE = (4096, 2048)


def lonlat_to_xy(lon: float, lat: float, width: int, height: int) -> tuple[float, float]:
    x = (lon + 180.0) / 360.0 * (width - 1)
    y = (90.0 - lat) / 180.0 * (height - 1)
    return (x, y)


def _extract_zip(path: Path, destination: Path) -> None:
    with zipfile.ZipFile(path) as archive:
        archive.extractall(destination)


def _iter_parts(shape) -> list[list[tuple[float, float]]]:
    parts = list(shape.parts) + [len(shape.points)]
    out = []
    for index in range(len(parts) - 1):
        out.append(shape.points[parts[index]:parts[index + 1]])
    return out


def _record_code(record: dict) -> tuple[str, str, str]:
    iso_a2 = record.get('ISO_A2_EH') or record.get('ISO_A2') or record.get('WB_A2') or record.get('POSTAL') or '--'
    iso_a3 = record.get('ADM0_A3') or record.get('ISO_A3_EH') or record.get('ISO_A3') or record.get('WB_A3') or 'UNK'
    name = record.get('NAME_EN') or record.get('NAME_LONG') or record.get('NAME') or record.get('ADMIN') or iso_a3
    iso_a2 = 'XX' if iso_a2 in ('-99', '', None) else str(iso_a2)
    iso_a3 = 'UNK' if iso_a3 in ('-99', '', None) else str(iso_a3)
    return (iso_a2, iso_a3, str(name))


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument('--width', type=int, default=SIZE[0])
    parser.add_argument('--height', type=int, default=SIZE[1])
    args = parser.parse_args()
    ensure_dirs()

    countries_zip = next(spec for spec in FIRST_WAVE_SOURCES if spec.slot == 'earth_country_id_map')

    with tempfile.TemporaryDirectory() as tmpdir:
        tmp = Path(tmpdir)
        _extract_zip(raw_source_path(countries_zip), tmp)
        reader = shapefile.Reader(str(tmp / 'ne_10m_admin_0_countries.shp'))

        image = Image.new('RGBA', (args.width, args.height), (0, 0, 0, 255))
        draw = ImageDraw.Draw(image)
        grouped = {}
        for shape_record in reader.iterShapeRecords():
            record = shape_record.record.as_dict()
            iso_a2, iso_a3, name = _record_code(record)
            key = (iso_a2, iso_a3, name)
            entry = grouped.setdefault(
                key,
                {
                    'iso_a2': iso_a2,
                    'iso_a3': iso_a3,
                    'display_name': name,
                    'bbox': [180.0, 90.0, -180.0, -90.0],
                    'parts': [],
                },
            )
            shape = shape_record.shape
            bbox = shape.bbox
            entry['bbox'][0] = min(entry['bbox'][0], float(bbox[0]))
            entry['bbox'][1] = min(entry['bbox'][1], float(bbox[1]))
            entry['bbox'][2] = max(entry['bbox'][2], float(bbox[2]))
            entry['bbox'][3] = max(entry['bbox'][3], float(bbox[3]))
            for part in _iter_parts(shape):
                if len(part) >= 3:
                    entry['parts'].append(part)

        entries = []
        country_id = 1
        for _, entry in sorted(grouped.items(), key=lambda item: (item[0][1], item[0][0], item[0][2])):
            rgb = encode_country_id_rgb(country_id)
            fill = (rgb[0], rgb[1], rgb[2], 255)
            for part in entry['parts']:
                polygon = [lonlat_to_xy(lon, lat, args.width, args.height) for lon, lat in part]
                draw.polygon(polygon, fill=fill)
            bbox = entry['bbox']
            center_lon = (bbox[0] + bbox[2]) / 2.0
            center_lat = (bbox[1] + bbox[3]) / 2.0
            sample_x = round(((center_lon + 180.0) / 360.0) * (args.width - 1))
            sample_y = round(((90.0 - center_lat) / 180.0) * (args.height - 1))
            target_rgb = (rgb[0], rgb[1], rgb[2])
            current_rgb = image.getpixel((max(0, min(args.width - 1, sample_x)), max(0, min(args.height - 1, sample_y))))[:3]
            if current_rgb != target_rgb:
                best = None
                lon_span = max(1.0, bbox[2] - bbox[0])
                lat_span = max(1.0, bbox[3] - bbox[1])
                for grid_y in range(0, 21):
                    for grid_x in range(0, 21):
                        lon = bbox[0] + (lon_span * grid_x / 20.0)
                        lat = bbox[1] + (lat_span * grid_y / 20.0)
                        x = round(((lon + 180.0) / 360.0) * (args.width - 1))
                        y = round(((90.0 - lat) / 180.0) * (args.height - 1))
                        pixel = image.getpixel((max(0, min(args.width - 1, x)), max(0, min(args.height - 1, y))))[:3]
                        if pixel == target_rgb:
                            distance = abs(lon - center_lon) + abs(lat - center_lat)
                            if best is None or distance < best[0]:
                                best = (distance, lat, lon)
                if best is not None:
                    center_lat = best[1]
                    center_lon = best[2]
            entries.append(
                {
                    'id': country_id,
                    'rgb': [rgb[0], rgb[1], rgb[2]],
                    'iso_a2': entry['iso_a2'],
                    'iso_a3': entry['iso_a3'],
                    'display_name': entry['display_name'],
                    'center_lat': round(center_lat, 6),
                    'center_lon': round(center_lon, 6),
                    'bbox': [round(value, 6) for value in bbox],
                }
            )
            country_id += 1

        COUNTRY_ID_OUTPUT.parent.mkdir(parents=True, exist_ok=True)
        image.save(COUNTRY_ID_OUTPUT, format='PNG', optimize=True)
        write_json(
            COUNTRY_PALETTE_PATH,
            {
                'schema_version': SCHEMA_VERSION,
                'version': PALETTE_VERSION,
                'generated_at': utc_now(),
                'null_entry': {
                    'id': 0,
                    'rgb': [0, 0, 0],
                    'semantic': 'OCEAN_NULL',
                    'display_name': 'Ocean / No Hit',
                    'iso_a2': None,
                    'iso_a3': None,
                },
                'entries': entries,
            },
        )
        print(f'wrote {COUNTRY_ID_OUTPUT}')
        print(f'wrote {COUNTRY_PALETTE_PATH}')


if __name__ == '__main__':
    main()
