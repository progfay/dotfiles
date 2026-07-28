#!/usr/bin/env bash
# Cmd+W相当。現在のpaneを閉じた後、残ったpane群のsplit ratioを自動的に均等化する。
#
# close後に`herdr pane current`(UIフォーカスpane解決)を呼ぶとフォーカス遷移中で
# pane_not_foundになるレースコンディションがあるため、close前にpane_id/tab_idを
# 確定させておき、equalize側にはtab_idをそのまま渡す。
set -euo pipefail

export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/bin:/bin:$PATH"

dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=equalize-lib.sh
source "$dir/equalize-lib.sh"

current_json="$(herdr pane current)"
current_pane_id="$(printf '%s' "$current_json" | jq -r '.result.pane.pane_id')"
current_tab_id="$(printf '%s' "$current_json" | jq -r '.result.pane.tab_id')"
[ -n "$current_pane_id" ] && [ "$current_pane_id" != "null" ] || exit 0

herdr pane close "$current_pane_id" >/dev/null

equalize_current_tab "$current_tab_id"
