from __future__ import annotations

import hashlib
import json
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[2]
ASSETS_DIR = ROOT / 'assets'
GLOBE_SOURCE_DIR = ASSETS_DIR / 'globe' / 'source'
GLOBE_PROCESSED_DIR = ASSETS_DIR / 'globe' / 'processed' / 'web_standard'
SPACE_SOURCE_DIR = ASSETS_DIR / 'space' / 'source'
SPACE_PROCESSED_DIR = ASSETS_DIR / 'space' / 'processed' / 'web_standard'
MANIFESTS_DIR = ROOT / 'manifests'
RUNTIME_DIR = ROOT / 'apps' / 'candidate_c_low_level' / 'web' / 'runtime-assets'
RUNTIME_GLOBE_DIR = RUNTIME_DIR / 'globe' / 'v1'
RUNTIME_SPACE_DIR = RUNTIME_DIR / 'space' / 'v1'
RUNTIME_MANIFESTS_DIR = RUNTIME_DIR / 'manifests'

SCHEMA_VERSION = '1.0.0'
BUNDLE_VERSION = 'v1'
PALETTE_VERSION = 'v1'

SOURCE_RECORDS_PATH = MANIFESTS_DIR / 'source_records.generated.json'
CHECKSUMS_PATH = MANIFESTS_DIR / 'asset_checksums.generated.json'
ASSET_MANIFEST_PATH = MANIFESTS_DIR / 'asset_manifest.json'
COUNTRY_PALETTE_PATH = MANIFESTS_DIR / 'country_id_palette_v1.json'
ATMOSPHERE_PROFILE_PATH = GLOBE_PROCESSED_DIR / 'earth_atmosphere_profile_v1.json'

DAY_OUTPUT = GLOBE_PROCESSED_DIR / 'earth_day_albedo_v1_4096.webp'
BORDERS_OUTPUT = GLOBE_PROCESSED_DIR / 'earth_borders_overlay_v1_4096.png'
COUNTRY_ID_OUTPUT = GLOBE_PROCESSED_DIR / 'earth_country_id_map_v1_4096.png'
STARFIELD_OUTPUT = SPACE_PROCESSED_DIR / 'starfield_background_v1_4096.jpg'


@dataclass(frozen=True)
class SourceSpec:
    slot: str
    url: str
    raw_filename: str
    storage_policy: str
    license_status: str
    source_family: str
    target_tiers: tuple[str, ...]


FIRST_WAVE_SOURCES = (
    SourceSpec(
        slot='earth_day_albedo',
        url='https://assets.science.nasa.gov/content/dam/science/esd/eo/images/bmng/bmng-base/january/world.200401.3x5400x2700.jpg',
        raw_filename='world.200401.3x5400x2700.jpg',
        storage_policy='git',
        license_status='approved_human_review_2026-03-10',
        source_family='NASA Blue Marble Next Generation',
        target_tiers=('web_standard', 'web_high', 'mobile_medium_experimental'),
    ),
    SourceSpec(
        slot='earth_borders_overlay_boundaries',
        url='https://naciscdn.org/naturalearth/10m/cultural/ne_10m_admin_0_boundary_lines_land.zip',
        raw_filename='ne_10m_admin_0_boundary_lines_land.zip',
        storage_policy='git',
        license_status='approved_human_review_2026-03-10',
        source_family='Natural Earth boundary lines',
        target_tiers=('web_standard', 'web_high', 'mobile_medium_experimental'),
    ),
    SourceSpec(
        slot='earth_borders_overlay_coastline',
        url='https://naciscdn.org/naturalearth/10m/physical/ne_10m_coastline.zip',
        raw_filename='ne_10m_coastline.zip',
        storage_policy='git',
        license_status='approved_human_review_2026-03-10',
        source_family='Natural Earth coastline',
        target_tiers=('web_standard', 'web_high', 'mobile_medium_experimental'),
    ),
    SourceSpec(
        slot='earth_country_id_map',
        url='https://naciscdn.org/naturalearth/10m/cultural/ne_10m_admin_0_countries.zip',
        raw_filename='ne_10m_admin_0_countries.zip',
        storage_policy='git',
        license_status='approved_human_review_2026-03-10',
        source_family='Natural Earth admin-0 countries',
        target_tiers=('web_standard', 'web_high', 'mobile_medium_experimental'),
    ),
    SourceSpec(
        slot='starfield_background',
        url='https://svs.gsfc.nasa.gov/vis/a000000/a004800/a004851/starmap_2020_4k.exr',
        raw_filename='starmap_2020_4k.exr',
        storage_policy='git_lfs',
        license_status='approved_human_review_2026-03-10',
        source_family='NASA SVS Deep Star Maps 2020',
        target_tiers=('web_standard', 'web_high', 'mobile_medium_experimental'),
    ),
)


def utc_now() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace('+00:00', 'Z')


def ensure_dirs() -> None:
    for path in (
        GLOBE_SOURCE_DIR,
        GLOBE_PROCESSED_DIR,
        SPACE_SOURCE_DIR,
        SPACE_PROCESSED_DIR,
        MANIFESTS_DIR,
        RUNTIME_GLOBE_DIR,
        RUNTIME_SPACE_DIR,
        RUNTIME_MANIFESTS_DIR,
    ):
        path.mkdir(parents=True, exist_ok=True)


def raw_source_path(spec: SourceSpec) -> Path:
    if spec.slot.startswith('starfield'):
        return SPACE_SOURCE_DIR / spec.raw_filename
    return GLOBE_SOURCE_DIR / spec.raw_filename


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open('rb') as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b''):
            digest.update(chunk)
    return digest.hexdigest()


def read_json(path: Path, default: Any = None) -> Any:
    if not path.exists():
        return default
    with path.open('r', encoding='utf-8') as handle:
        return json.load(handle)


def write_json(path: Path, payload: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open('w', encoding='utf-8') as handle:
        json.dump(payload, handle, indent=2, ensure_ascii=True)
        handle.write('\n')


def encode_country_id_rgb(country_id: int) -> tuple[int, int, int]:
    if country_id < 0 or country_id > 0xFFFFFF:
        raise ValueError(f'country_id out of range: {country_id}')
    return (country_id & 0xFF, (country_id >> 8) & 0xFF, (country_id >> 16) & 0xFF)


def decode_country_id_rgb(rgb: tuple[int, int, int]) -> int:
    r, g, b = rgb
    return r + (g << 8) + (b << 16)
