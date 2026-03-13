#!/usr/bin/env python3
from __future__ import annotations

import shutil
from pathlib import Path

from _common import (
    ASSET_MANIFEST_PATH,
    ATMOSPHERE_PROFILE_PATH,
    BORDERS_OUTPUT,
    BUNDLE_VERSION,
    CHECKSUMS_PATH,
    COUNTRY_ID_OUTPUT,
    COUNTRY_PALETTE_PATH,
    DAY_OUTPUT,
    RUNTIME_DIR,
    RUNTIME_GLOBE_DIR,
    RUNTIME_MANIFESTS_DIR,
    RUNTIME_SPACE_DIR,
    SCHEMA_VERSION,
    SOURCE_RECORDS_PATH,
    STARFIELD_OUTPUT,
    ensure_dirs,
    read_json,
    utc_now,
    write_json,
)


def _checksum_for(records: list[dict], suffix: str) -> tuple[str, int]:
    for record in records:
        if record['path'].endswith(suffix):
            return record['sha256'], record['size_bytes']
    raise KeyError(suffix)


def _copy_runtime(source: Path, destination: Path) -> None:
    destination.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(source, destination)


def main() -> None:
    ensure_dirs()
    source_records_doc = read_json(SOURCE_RECORDS_PATH)
    checksum_doc = read_json(CHECKSUMS_PATH)
    if not source_records_doc or not checksum_doc:
        raise SystemExit('missing source_records.generated.json or asset_checksums.generated.json')
    checksum_records = checksum_doc['records']

    outputs = []
    output_specs = [
        ('earth_day_albedo', DAY_OUTPUT, 'webp', 4096, 2048, 'linear', True, 'srgb', 'globe/v1/earth_day_albedo_v1_4096.webp'),
        ('earth_borders_overlay', BORDERS_OUTPUT, 'png', 4096, 2048, 'linear', True, 'srgb', 'globe/v1/earth_borders_overlay_v1_4096.png'),
        ('earth_country_id_map', COUNTRY_ID_OUTPUT, 'png', 4096, 2048, 'nearest', False, 'none', 'globe/v1/earth_country_id_map_v1_4096.png'),
        ('starfield_background', STARFIELD_OUTPUT, 'jpg', 4096, 2048, 'linear', True, 'srgb', 'space/v1/starfield_background_v1_4096.jpg'),
        ('earth_atmosphere_profile', ATMOSPHERE_PROFILE_PATH, 'json', None, None, None, None, None, 'globe/v1/earth_atmosphere_profile_v1.json'),
        ('country_id_palette', COUNTRY_PALETTE_PATH, 'json', None, None, None, None, None, 'manifests/country_id_palette_v1.json'),
    ]

    for slot, path, fmt, width, height, sample_mode, mipmaps, color_space, runtime_path in output_specs:
        sha256, size_bytes = _checksum_for(checksum_records, str(path.relative_to(Path.cwd())))
        outputs.append(
            {
                'slot': slot,
                'tier': 'web_standard',
                'relative_path': str(path.relative_to(Path.cwd())),
                'runtime_path': runtime_path,
                'width': width,
                'height': height,
                'format': fmt,
                'sha256': sha256,
                'size_bytes': size_bytes,
                'sample_mode': sample_mode,
                'mipmaps': mipmaps,
                'color_space': color_space,
            }
        )

    manifest = {
        'schema_version': SCHEMA_VERSION,
        'bundle_version': BUNDLE_VERSION,
        'generated_at': utc_now(),
        'source_records': source_records_doc['records'],
        'outputs': outputs,
        'runtime': {
            'base_url': '/runtime-assets',
            'cache_policy': {
                'versioned_immutable': True,
                'cache_control': 'public, max-age=31536000, immutable',
                'requires_manifest_version_bump_on_change': True,
            },
            'bundles': {
                'web_standard': {
                    'version': BUNDLE_VERSION,
                    'slots': {
                        'earth_day_albedo': outputs[0],
                        'earth_borders_overlay': outputs[1],
                        'earth_country_id_map': {**outputs[2], 'palette_manifest': '/runtime-assets/manifests/country_id_palette_v1.json'},
                        'starfield_background': outputs[3],
                        'earth_atmosphere_profile': outputs[4],
                    },
                }
            },
        },
    }
    write_json(ASSET_MANIFEST_PATH, manifest)

    _copy_runtime(DAY_OUTPUT, RUNTIME_GLOBE_DIR / DAY_OUTPUT.name)
    _copy_runtime(BORDERS_OUTPUT, RUNTIME_GLOBE_DIR / BORDERS_OUTPUT.name)
    _copy_runtime(COUNTRY_ID_OUTPUT, RUNTIME_GLOBE_DIR / COUNTRY_ID_OUTPUT.name)
    _copy_runtime(ATMOSPHERE_PROFILE_PATH, RUNTIME_GLOBE_DIR / ATMOSPHERE_PROFILE_PATH.name)
    _copy_runtime(STARFIELD_OUTPUT, RUNTIME_SPACE_DIR / STARFIELD_OUTPUT.name)
    _copy_runtime(COUNTRY_PALETTE_PATH, RUNTIME_MANIFESTS_DIR / COUNTRY_PALETTE_PATH.name)
    _copy_runtime(ASSET_MANIFEST_PATH, RUNTIME_DIR / ASSET_MANIFEST_PATH.name)
    print(f'wrote {ASSET_MANIFEST_PATH}')
    print(f'copied runtime bundle to {RUNTIME_DIR}')


if __name__ == '__main__':
    main()
