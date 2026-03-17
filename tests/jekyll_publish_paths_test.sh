#!/bin/bash

set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

LOG_FILE="$TMP_DIR/commands.log"

bash -lc '
  set -eo pipefail
  source <(sed '"'"'/^main "\$@"$/d'"'"' "'"$BASE_DIR"'/jekyll.sh")

  promptDraft() {
    echo sample-draft.md
  }

  promptPost() {
    echo 2026-03-17-sample-post.md
  }

  listPosts() {
    :
  }

  runJekyllCmd() {
    printf "%s\n" "$*" >>"'"$LOG_FILE"'"
  }

  runFeaturePublish
  runFeatureUnpublish
'

grep -qx 'publish _drafts/sample-draft.md' "$LOG_FILE"
grep -qx 'unpublish _posts/2026-03-17-sample-post.md' "$LOG_FILE"
