#!/bin/zsh
set -euo pipefail

ROOT="/Users/sol/Desktop/travelRecord"
APP_ROOT="$ROOT/apps/mobile_app"
LIGHT_SRC="$ROOT/icon_light.png"
DARK_SRC="$ROOT/icon_dark.png"
APP_ICON_DIR="$APP_ROOT/ios/Runner/Assets.xcassets/AppIcon.appiconset"
LAUNCH_DIR="$APP_ROOT/ios/Runner/Assets.xcassets/LaunchImage.imageset"

mkdir -p "$APP_ICON_DIR" "$LAUNCH_DIR"

resize_icon() {
  local source="$1"
  local destination="$2"
  local pixels="$3"
  sips -z "$pixels" "$pixels" "$source" --out "$destination" >/dev/null
}

generate_icon_set() {
  local source="$1"
  local destination_dir="$2"
  local prefix="$3"
  shift 3

  local specs=("$@")
  local spec filename pixels
  for spec in "${specs[@]}"; do
    filename="${spec%%:*}"
    pixels="${spec##*:}"
    resize_icon "$source" "$destination_dir/$prefix-$filename" "$pixels"
  done
}

ICON_SPECS=(
  "20x20@1x.png:20"
  "20x20@2x.png:40"
  "20x20@3x.png:60"
  "29x29@1x.png:29"
  "29x29@2x.png:58"
  "29x29@3x.png:87"
  "40x40@1x.png:40"
  "40x40@2x.png:80"
  "40x40@3x.png:120"
  "60x60@2x.png:120"
  "60x60@3x.png:180"
  "76x76@1x.png:76"
  "76x76@2x.png:152"
  "83.5x83.5@2x.png:167"
  "1024x1024@1x.png:1024"
)

generate_icon_set "$LIGHT_SRC" "$APP_ICON_DIR" "Icon-App" "${ICON_SPECS[@]}"

resize_icon "$LIGHT_SRC" "$LAUNCH_DIR/LaunchImage-light.png" 168
resize_icon "$LIGHT_SRC" "$LAUNCH_DIR/LaunchImage-light@2x.png" 336
resize_icon "$LIGHT_SRC" "$LAUNCH_DIR/LaunchImage-light@3x.png" 504
resize_icon "$DARK_SRC" "$LAUNCH_DIR/LaunchImage-dark.png" 168
resize_icon "$DARK_SRC" "$LAUNCH_DIR/LaunchImage-dark@2x.png" 336
resize_icon "$DARK_SRC" "$LAUNCH_DIR/LaunchImage-dark@3x.png" 504
