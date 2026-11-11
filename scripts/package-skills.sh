#!/usr/bin/env bash
# Zip every skill folder into dist/<skill>.zip for a manual upload to
# claude.ai (Customize > Skills > + > Upload a skill).
#
# You only need this if you don't want to add the repo as a plugin marketplace
# in claude.ai. Large skills can hit claude.ai's upload size limit; the script
# prints each zip's size so you can spot that.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DIST="$ROOT/dist"
rm -rf "$DIST"
mkdir -p "$DIST"

for skill in "$ROOT"/plugins/*/skills/*/; do
  [ -f "$skill/SKILL.md" ] || continue
  name="$(basename "$skill")"
  (cd "$(dirname "$skill")" && zip -qr "$DIST/$name.zip" "$name" -x '*.DS_Store' -x '*/node_modules/*')
  printf '%-30s %s\n' "$name.zip" "$(du -h "$DIST/$name.zip" | cut -f1)"
done
