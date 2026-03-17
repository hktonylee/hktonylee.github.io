#!/bin/bash

set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

DRAFTS_DIR="$TMP_DIR/_drafts"
mkdir -p "$DRAFTS_DIR"

touch -t 202401010101 "$DRAFTS_DIR/older.md"
touch -t 202402020202 "$DRAFTS_DIR/newer.md"

OUTPUT_FILE="$TMP_DIR/output.txt"

bash -lc '
  set -eo pipefail
  source <(sed '"'"'/^main "\$@"$/d'"'"' "'"$BASE_DIR"'/jekyll.sh")
  DRAFTS_DIR="'"$DRAFTS_DIR"'"
  listDrafts >"'"$OUTPUT_FILE"'"
'

grep -q 'newer.md' "$OUTPUT_FILE"
grep -q 'older.md' "$OUTPUT_FILE"

NEWER_LINE="$(grep -n 'newer.md' "$OUTPUT_FILE" | cut -d: -f1)"
OLDER_LINE="$(grep -n 'older.md' "$OUTPUT_FILE" | cut -d: -f1)"

[ "$NEWER_LINE" -lt "$OLDER_LINE" ]
