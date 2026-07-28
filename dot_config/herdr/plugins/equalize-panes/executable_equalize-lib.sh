#!/usr/bin/env bash
# equalize_current_tab [tab_id]: 指定tab内(省略時はUIフォーカスpaneが
# 属するtab)で、split木構造・pane自体には一切触れず、各分割線のratioだけを
# 「配下のleaf(pane)数に応じた均等値」に再計算してsocket API
# layout.set_split_ratio で1つずつ書き換える。
# 呼び出し元で `set -euo pipefail` 済み・PATH解決済みであることを前提とする。
#
# close等でpaneが消えた直後は `herdr pane current`(UIフォーカスpane解決)が
# 遷移中で pane_not_found になるレースコンディションがあるため、そういう
# 呼び出し元は事前に確定させたtab_idを引数で渡すこと。
equalize_current_tab() {
  local sock current_tab_id export_res root_json ratio_updates item req

  sock="${HERDR_SOCKET_PATH:-$HOME/.config/herdr/herdr.sock}"
  current_tab_id="${1:-}"

  if [ -z "$current_tab_id" ]; then
    current_tab_id="$(herdr pane current | jq -r '.result.pane.tab_id')"
  fi
  [ -n "$current_tab_id" ] && [ "$current_tab_id" != "null" ] || return 0

  export_res="$(printf '{"id":"eq-export","method":"layout.export","params":{"tab_id":"%s"}}\n' "$current_tab_id" \
    | nc -U "$sock" -w 2)"

  # splitが無い(pane 1枚だけ)場合は何もしない
  root_json="$(printf '%s' "$export_res" | jq -c '.result.layout.root // empty')"
  [ -n "$root_json" ] || return 0

  # rootからの経路をbool配列(false=first側, true=second側)で表しつつ、
  # 各splitについて {path, ratio} を1行1JSONで列挙する。
  ratio_updates="$(printf '%s' "$root_json" | jq -c '
    def leaf_count:
      if .type == "pane" then 1
      else (.first | leaf_count) + (.second | leaf_count)
      end;
    def ratios($path):
      if .type == "pane" then empty
      else
        (.first | leaf_count) as $fc
        | (.second | leaf_count) as $sc
        | {path: $path, ratio: ($fc / ($fc + $sc))},
          (.first | ratios($path + [false])),
          (.second | ratios($path + [true]))
      end;
    ratios([])
  ')"

  [ -n "$ratio_updates" ] || return 0

  while IFS= read -r item; do
    [ -n "$item" ] || continue
    req="$(jq -nc --arg tab "$current_tab_id" --argjson item "$item" \
      '{id: "eq-ratio", method: "layout.set_split_ratio", params: {tab_id: $tab, path: $item.path, ratio: $item.ratio}}')"
    printf '%s\n' "$req" | nc -U "$sock" -w 1 >/dev/null 2>&1 || true
  done <<< "$ratio_updates"
}
