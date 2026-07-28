#!/usr/bin/env bash
# 現在のtab内でN番目(作成順)のpaneに、agentの起動有無に関係なくフォーカスを移す。
# herdr公式CLIには position 指定のfocusが無いため、herdr api schema で見つかる
# 生のsocket API (pane.focus + pane_id) をJSON-RPCで直接叩いている。
# 使い方: focus-pane.sh <1-9>
set -euo pipefail

n="${1:?usage: focus-pane.sh <index 1-9>}"
sock="${HERDR_SOCKET_PATH:-$HOME/.config/herdr/herdr.sock}"

current_tab_id="$(herdr pane current | jq -r '.result.pane.tab_id')"

pane_id="$(herdr pane list | jq -r --arg tab "$current_tab_id" --argjson idx "$n" '
  [.result.panes[] | select(.tab_id == $tab)]
  | sort_by(.pane_id | capture("p(?<n>[0-9]+)$").n | tonumber)
  | .[$idx - 1].pane_id // empty
')"

# 指定番号のpaneが無ければ何もしない
[ -n "$pane_id" ] || exit 0

printf '{"id":"focus-pane-%s","method":"pane.focus","params":{"pane_id":"%s"}}\n' "$n" "$pane_id" \
  | nc -U "$sock" -w 1 >/dev/null 2>&1 || true
