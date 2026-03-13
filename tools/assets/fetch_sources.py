#!/usr/bin/env python3
from __future__ import annotations

import argparse
import urllib.request
from pathlib import Path

from _common import FIRST_WAVE_SOURCES, SOURCE_RECORDS_PATH, ensure_dirs, raw_source_path, sha256_file, utc_now, write_json


def download(url: str, destination: Path) -> None:
    request = urllib.request.Request(url, headers={'User-Agent': 'travel-record-assets/1.0'})
    with urllib.request.urlopen(request) as response, destination.open('wb') as handle:
        while True:
            chunk = response.read(1024 * 1024)
            if not chunk:
                break
            handle.write(chunk)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument('--refresh', action='store_true')
    args = parser.parse_args()

    ensure_dirs()
    records = []
    for spec in FIRST_WAVE_SOURCES:
        destination = raw_source_path(spec)
        if args.refresh or not destination.exists():
            download(spec.url, destination)
            retrieved_at = utc_now()
        else:
            retrieved_at = utc_now()
        records.append(
            {
                'slot': spec.slot,
                'source_family': spec.source_family,
                'raw_filename': spec.raw_filename,
                'source_url': spec.url,
                'retrieved_at': retrieved_at,
                'sha256': sha256_file(destination),
                'license_status': spec.license_status,
                'license_checked_at': '2026-03-10T09:10:00Z',
                'storage_policy': spec.storage_policy,
                'size_bytes': destination.stat().st_size,
                'target_tiers': list(spec.target_tiers),
            }
        )
    payload = {
        'schema_version': '1.0.0',
        'generated_at': utc_now(),
        'records': records,
    }
    write_json(SOURCE_RECORDS_PATH, payload)
    print(f'wrote {SOURCE_RECORDS_PATH}')


if __name__ == '__main__':
    main()
