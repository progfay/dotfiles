#!/usr/bin/env bash
# equalize_current_tab [tab_id]: 指定tab内(省略時はUIフォーカスpaneが
# 属するtab)で、split木構造・pane自体には一切触れず、各分割線のratioだけを
# 再計算してsocket API layout.set_split_ratio で1つずつ書き換える。
#
# ratioは「同じdirection(right/down)が連続する区間内のleaf数比」で決める。
# direction が切り替わった分岐はそこで重み1の1ブロックとして扱う(中身の
# leaf数を親側の計算に持ち越さない)。これによりCmd+D→Cmd+Shift+Dのような
# 異方向split混在時は素直に「半分、その中で1:1」になり、Cmd+Dを同方向に
# 連打した場合は従来通りN等分になる。
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
    # ノード配下のleaf数を数える。ただし$axisと異なるdirectionのsplitに
    # 出会ったらそこで打ち止めにして重み1として扱う(中身を数え上げない)。
    def weight($axis):
      if .type == "pane" then 1
      elif .direction == $axis then
        (.first | weight($axis)) + (.second | weight($axis))
      else 1
      end;
    def ratios($path):
      if .type == "pane" then empty
      else
        .direction as $d
        | (.first | weight($d)) as $fc
        | (.second | weight($d)) as $sc
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
