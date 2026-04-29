#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title textlint
# @raycast.mode silent

# Optional parameters:
# @raycast.icon ✍️

# Documentation:
# @raycast.description Fix markdown in Clipboard with textlint
# @raycast.author progfay
# @raycast.authorURL https://github.com/progfay

export __CF_USER_TEXT_ENCODING="0x$(printf '%x' "$(id -u)"):0x08000100:0x0"
. "$HOME/.vite-plus/env"
PATH="$PATH:$(npm -g prefix)/bin"

tmp_file=$(mktemp /tmp/textlint-XXXXXX.md)
trap "rm -f $tmp_file" EXIT

pbpaste > "$tmp_file"

if [ ! -s "$tmp_file" ]; then
    exit 0
fi

textlint --preset @progfay/textlint-rule-preset-ja --fix "$tmp_file" > /dev/null || true

cat "$tmp_file" | pbcopy

osascript -e 'tell application "System Events" to keystroke "v" using {command down}'

