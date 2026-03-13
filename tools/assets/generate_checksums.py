#!/usr/bin/env python3
from __future__ import annotations

from datetime import datetime, timezone
from pathlib import Path

from _common import ATMOSPHERE_PROFILE_PATH, BORDERS_OUTPUT, CHECKSUMS_PATH, COUNTRY_ID_OUTPUT, COUNTRY_PALETTE_PATH, DAY_OUTPUT, STARFIELD_OUTPUT, ensure_dirs, sha256_file, write_json


FILES = [
    DAY_OUTPUT,
    BORDERS_OUTPUT,
    COUNTRY_ID_OUTPUT,
    COUNTRY_PALETTE_PATH,
    STARFIELD_OUTPUT,
    ATMOSPHERE_PROFILE_PATH,
]


def main() -> None:
    ensure_dirs()
    records = []
    for path in FILES:
        if not path.exists():
            raise SystemExit(f'missing generated asset: {path}')
        records.append(
            {
                'path': str(path.relative_to(Path.cwd())),
                'sha256': sha256_file(path),
                'size_bytes': path.stat().st_size,
            }
        )
    generated_at = datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace('+00:00', 'Z')
    write_json(CHECKSUMS_PATH, {'generated_at': generated_at, 'records': records})
    print(f'wrote {CHECKSUMS_PATH}')


if __name__ == '__main__':
    main()
