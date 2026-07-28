#!/usr/bin/env bash
# Cmd+D相当。現在のpaneを右方向にsplitして新paneにフォーカスを移した後、
# 現在tab内のsplit ratioを自動的に均等化する。
set -euo pipefail

export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/bin:/bin:$PATH"

dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=equalize-lib.sh
source "$dir/equalize-lib.sh"

split_res="$(herdr pane split --current --direction right --focus)"
tab_id="$(printf '%s' "$split_res" | jq -r '.result.pane.tab_id')"

equalize_current_tab "$tab_id"
