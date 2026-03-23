#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RECORD_DIR="$ROOT_DIR/record"
OUT_DIR="$ROOT_DIR/apps/mobile_app/assets/web_globe"

cd "$RECORD_DIR"
npm install
npm run build:embed

rm -rf "$OUT_DIR"
mkdir -p "$OUT_DIR"
cp -R "$RECORD_DIR/dist-embed/." "$OUT_DIR/"

echo "Embedded globe bundle copied to $OUT_DIR"
