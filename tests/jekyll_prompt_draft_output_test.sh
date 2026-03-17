#!/bin/bash

set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

mkdir -p "$TMP_DIR/_drafts"
touch -t 202401010101 "$TMP_DIR/_drafts/first.md"
touch -t 202402020202 "$TMP_DIR/_drafts/second.md"
touch -t 202403030303 "$TMP_DIR/_drafts/third.md"

OUTPUT_FILE="$TMP_DIR/output.txt"

bash -lc '
  set -eo pipefail
  source <(sed '"'"'/^main "\$@"$/d'"'"' "'"$BASE_DIR"'/jekyll.sh")
  DRAFTS_DIR="'"$TMP_DIR"'/_drafts"
  listDrafts > /dev/null

  promptText() {
    echo 2
  }

  promptYesNo() {
    return 0
  }

  promptDraft "Publish draft" "Are you sure want to publish?" >"'"$OUTPUT_FILE"'"
'

[ "$(cat "$OUTPUT_FILE")" = "second.md" ]
