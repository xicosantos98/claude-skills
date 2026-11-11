#!/usr/bin/env bash
# Refresh the vendored third-party skills from their upstream repos.
#
#   scripts/sync-upstream.sh              # sync every entry in upstream.json
#   scripts/sync-upstream.sh impeccable   # sync one entry
#
# Each entry is cloned at its "ref" (branch or tag), the listed paths are copied
# over the vendored copy, and the exact commit is written back to "sha" so every
# update shows up as a reviewable diff. Requires git and jq.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MANIFEST="$ROOT/upstream.json"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

names=("$@")
if [ ${#names[@]} -eq 0 ]; then
  mapfile -t names < <(jq -r 'keys[]' "$MANIFEST")
fi

for name in "${names[@]}"; do
  repo=$(jq -r --arg n "$name" '.[$n].repo' "$MANIFEST")
  ref=$(jq -r --arg n "$name" '.[$n].ref' "$MANIFEST")
  if [ "$repo" = "null" ]; then
    echo "Unknown entry: $name" >&2
    exit 1
  fi

  echo "==> $name ($repo @ $ref)"
  git clone --quiet --depth 1 --branch "$ref" "$repo" "$WORK/$name"
  sha=$(git -C "$WORK/$name" rev-parse HEAD)

  count=$(jq -r --arg n "$name" '.[$n].copy | length' "$MANIFEST")
  for ((i = 0; i < count; i++)); do
    from=$(jq -r --arg n "$name" --argjson i "$i" '.[$n].copy[$i].from' "$MANIFEST")
    to=$(jq -r --arg n "$name" --argjson i "$i" '.[$n].copy[$i].to' "$MANIFEST")
    rm -rf "${ROOT:?}/$to"
    mkdir -p "$(dirname "$ROOT/$to")"
    cp -R "$WORK/$name/$from" "$ROOT/$to"
  done

  tmp="$(mktemp)"
  jq --arg n "$name" --arg s "$sha" '.[$n].sha = $s' "$MANIFEST" > "$tmp" && mv "$tmp" "$MANIFEST"
  echo "    pinned at $sha"
done

echo
echo "Done. Review with: git status && git diff --stat"
