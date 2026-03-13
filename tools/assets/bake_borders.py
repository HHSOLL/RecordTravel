#!/usr/bin/env python3
from __future__ import annotations

import argparse
import tempfile
import zipfile
from pathlib import Path

import shapefile
from PIL import Image, ImageDraw

from _common import BORDERS_OUTPUT, FIRST_WAVE_SOURCES, ensure_dirs, raw_source_path

SIZE = (4096, 2048)
LINE_COLOR = (255, 255, 255, 160)
COAST_COLOR = (255, 255, 255, 120)


def lonlat_to_xy(lon: float, lat: float, width: int, height: int) -> tuple[float, float]:
    x = (lon + 180.0) / 360.0 * (width - 1)
    y = (90.0 - lat) / 180.0 * (height - 1)
    return (x, y)


def draw_polyline(draw: ImageDraw.ImageDraw, points: list[tuple[float, float]], color: tuple[int, int, int, int], width: int) -> None:
    if len(points) >= 2:
        draw.line(points, fill=color, width=width, joint='curve')


def _extract_zip(path: Path, destination: Path) -> None:
    with zipfile.ZipFile(path) as archive:
        archive.extractall(destination)


def _iter_parts(shape) -> list[list[tuple[float, float]]]:
    parts = list(shape.parts) + [len(shape.points)]
    out = []
    for index in range(len(parts) - 1):
        out.append(shape.points[parts[index]:parts[index + 1]])
    return out


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument('--width', type=int, default=SIZE[0])
    parser.add_argument('--height', type=int, default=SIZE[1])
    args = parser.parse_args()
    ensure_dirs()

    boundary_zip = next(spec for spec in FIRST_WAVE_SOURCES if spec.slot == 'earth_borders_overlay_boundaries')
    coast_zip = next(spec for spec in FIRST_WAVE_SOURCES if spec.slot == 'earth_borders_overlay_coastline')

    with tempfile.TemporaryDirectory() as tmpdir:
        tmp = Path(tmpdir)
        boundary_dir = tmp / 'boundaries'
        coast_dir = tmp / 'coast'
        boundary_dir.mkdir()
        coast_dir.mkdir()
        _extract_zip(raw_source_path(boundary_zip), boundary_dir)
        _extract_zip(raw_source_path(coast_zip), coast_dir)

        boundary_reader = shapefile.Reader(str(boundary_dir / 'ne_10m_admin_0_boundary_lines_land.shp'))
        coast_reader = shapefile.Reader(str(coast_dir / 'ne_10m_coastline.shp'))

        image = Image.new('RGBA', (args.width, args.height), (0, 0, 0, 0))
        draw = ImageDraw.Draw(image)

        for shape_record in coast_reader.iterShapeRecords():
            for part in _iter_parts(shape_record.shape):
                points = [lonlat_to_xy(lon, lat, args.width, args.height) for lon, lat in part]
                draw_polyline(draw, points, COAST_COLOR, 1)

        for shape_record in boundary_reader.iterShapeRecords():
            for part in _iter_parts(shape_record.shape):
                points = [lonlat_to_xy(lon, lat, args.width, args.height) for lon, lat in part]
                draw_polyline(draw, points, LINE_COLOR, 1)

        BORDERS_OUTPUT.parent.mkdir(parents=True, exist_ok=True)
        image.save(BORDERS_OUTPUT, format='PNG', optimize=True)
        print(f'wrote {BORDERS_OUTPUT}')


if __name__ == '__main__':
    main()
