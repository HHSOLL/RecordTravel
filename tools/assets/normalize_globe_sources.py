#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
from pathlib import Path

import Imath
import numpy as np
import OpenEXR
from PIL import Image

from _common import (
    ATMOSPHERE_PROFILE_PATH,
    DAY_OUTPUT,
    FIRST_WAVE_SOURCES,
    GLOBE_SOURCE_DIR,
    SPACE_SOURCE_DIR,
    STARFIELD_OUTPUT,
    ensure_dirs,
    raw_source_path,
)

DAY_SIZE = (4096, 2048)
STARFIELD_SIZE = (4096, 2048)
ATMOSPHERE_PROFILE = {
    'version': 'v1',
    'atmosphereColor': '#6FA8FF',
    'rimIntensity': 0.18,
    'falloff': 2.2,
    'outerGlowAlpha': 0.22,
    'nightBlendEnabled': False,
}


def _load_exr_rgb(path: Path) -> Image.Image:
    exr = OpenEXR.InputFile(str(path))
    data_window = exr.header()['dataWindow']
    width = data_window.max.x - data_window.min.x + 1
    height = data_window.max.y - data_window.min.y + 1
    pixel_type = Imath.PixelType(Imath.PixelType.FLOAT)
    channels = [
        np.frombuffer(exr.channel(channel, pixel_type), dtype=np.float32)
        for channel in ('R', 'G', 'B')
    ]
    rgb = np.stack([channel.reshape((height, width)) for channel in channels], axis=-1)
    rgb = np.nan_to_num(rgb, nan=0.0, posinf=0.0, neginf=0.0)
    percentile = np.percentile(rgb, 99.9)
    scale = percentile if percentile > 0 else 1.0
    rgb = np.clip(rgb / scale, 0.0, 1.0)
    rgb = np.power(rgb, 1.0 / 2.2)
    rgb_u8 = (rgb * 255.0).astype(np.uint8)
    return Image.fromarray(rgb_u8, mode='RGB')


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument('--quality-day', type=int, default=85)
    parser.add_argument('--quality-starfield', type=int, default=88)
    args = parser.parse_args()

    ensure_dirs()

    day_source = next(spec for spec in FIRST_WAVE_SOURCES if spec.slot == 'earth_day_albedo')
    day_image = Image.open(raw_source_path(day_source)).convert('RGB')
    day_image = day_image.resize(DAY_SIZE, Image.Resampling.LANCZOS)
    first_column = day_image.crop((0, 0, 1, DAY_SIZE[1]))
    day_image.paste(first_column, (DAY_SIZE[0] - 1, 0))
    DAY_OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    day_image.save(DAY_OUTPUT, format='WEBP', quality=args.quality_day, method=6)

    star_source = next(spec for spec in FIRST_WAVE_SOURCES if spec.slot == 'starfield_background')
    star_image = _load_exr_rgb(raw_source_path(star_source))
    star_image = star_image.resize(STARFIELD_SIZE, Image.Resampling.LANCZOS)
    star_array = np.asarray(star_image, dtype=np.float32) * 0.72
    star_image = Image.fromarray(np.clip(star_array, 0, 255).astype(np.uint8), mode='RGB')
    STARFIELD_OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    star_image.save(STARFIELD_OUTPUT, format='JPEG', quality=args.quality_starfield, optimize=True, progressive=True)

    ATMOSPHERE_PROFILE_PATH.parent.mkdir(parents=True, exist_ok=True)
    with ATMOSPHERE_PROFILE_PATH.open('w', encoding='utf-8') as handle:
        json.dump(ATMOSPHERE_PROFILE, handle, indent=2)
        handle.write('\n')

    print(f'wrote {DAY_OUTPUT}')
    print(f'wrote {STARFIELD_OUTPUT}')
    print(f'wrote {ATMOSPHERE_PROFILE_PATH}')


if __name__ == '__main__':
    main()
