#!/usr/bin/env bash
# Build one zip per skill in dist/ for upload to the Claude app (Settings -> Capabilities -> Skills).
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p dist
for dir in skills/*/; do
  name="$(basename "$dir")"
  rm -f "dist/$name.zip"
  (cd skills && zip -qr "../dist/$name.zip" "$name")
  echo "built dist/$name.zip"
done
