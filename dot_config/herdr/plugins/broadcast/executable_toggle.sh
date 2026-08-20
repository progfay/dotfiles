#!/usr/bin/env bash
# cmd+alt+i で呼ばれるtoggleアクション。
# 未起動なら現在tab内の全pane(開始前にいたpaneも含む)を対象にbroadcastを開始し、
# 起動中ならrelayプロセスにSIGTERMを送ってから明示的にpaneを閉じる。
# targetのスナップショットはrelay pane作成"前"に取るため、
# relay pane自身が targets に混ざる心配はない。
set -euo pipefail

state_dir="${HERDR_PLUGIN_STATE_DIR:?HERDR_PLUGIN_STATE_DIR not set}"
active_file="$state_dir/active"
pid_file="$state_dir/relay.pid"
relay_pane_file="$state_dir/relay_pane_id"
targets_file="$state_dir/targets.json"

if [ -f "$active_file" ]; then
  if [ -f "$pid_file" ]; then
    kill -TERM "$(cat "$pid_file")" 2>/dev/null || true
  fi
  if [ -f "$relay_pane_file" ]; then
    "$HERDR_BIN_PATH" plugin pane close "$(cat "$relay_pane_file")" >/dev/null 2>&1 || true
  fi
  rm -f "$active_file" "$pid_file" "$relay_pane_file"
  exit 0
fi

current_tab_id="$("$HERDR_BIN_PATH" pane current | jq -r '.result.pane.tab_id')"
current_pane_id="$("$HERDR_BIN_PATH" pane current | jq -r '.result.pane.pane_id')"

target_pane_ids="$("$HERDR_BIN_PATH" pane list | jq -c --arg tab "$current_tab_id" '
  [.result.panes[] | select(.tab_id == $tab) | .pane_id]
')"

# 対象paneが無ければ何もしない
[ "$(printf '%s' "$target_pane_ids" | jq 'length')" -gt 0 ] || exit 0

jq -n --argjson targets "$target_pane_ids" '{target_pane_ids: $targets}' > "$targets_file"

open_result="$("$HERDR_BIN_PATH" plugin pane open --plugin local.broadcast --entrypoint relay \
  --placement split --direction down --target-pane "$current_pane_id" --focus)"
relay_pane_id="$(printf '%s' "$open_result" | jq -r '.result.plugin_pane.pane.pane_id')"

# 他のpaneを隠さないよう、relay paneを最小サイズまで縮める
"$HERDR_BIN_PATH" pane resize --pane "$relay_pane_id" --direction down --amount 1.0 >/dev/null 2>&1 || true

printf '%s' "$relay_pane_id" > "$relay_pane_file"
touch "$active_file"
