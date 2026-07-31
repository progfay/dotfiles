#!/usr/bin/env bash
# 現在のtab内でN番目(左上から読み順=y,xの空間位置順)のpaneに、
# agentの起動有無に関係なくフォーカスを移す。
# herdr公式CLIには position 指定のfocusが無いため、herdr api schema で見つかる
# 生のsocket API (pane.focus + pane_id) をJSON-RPCで直接叩いている。
#
# 注意: pane_id は不透明な識別子で "p1" のような数字だけでなく "pE" のような
# 英字サフィックスも普通に発生する (herdr skillのIDs節を参照)。そのため
# pane_id をパースして作成順を推定する実装は使わない。パースしようとする
# と capture() がマッチしない場合エラーではなく空ストリームを返すため
# sort_by が黙って壊れ、数字サフィックスを持たないpaneが常に先頭に来る、
# というバグが過去にあった (cmd+1がpane 1にfocusしない不具合の原因)。
# 使い方: focus-pane.sh <1-9>
#
# 注意: このスクリプトはキーバインド経由でherdr本体(GUIプロセス)の
# 子プロセスとして起動されるため、ログインシェルのPATH (/opt/homebrew/bin等)
# を継承しない。素のPATHには herdr バイナリが無く "herdr: command not found"
# (exit 127) で即失敗していた (jq/nc/bash は /usr/bin,/bin にあるため無関係)。
# そのためHomebrewの標準インストール先を明示的にPATHへ追加する。
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

set -euo pipefail

n="${1:?usage: focus-pane.sh <index 1-9>}"
sock="${HERDR_SOCKET_PATH:-$HOME/.config/herdr/herdr.sock}"

current_pane_id="$(herdr pane current | jq -r '.result.pane.pane_id')"

pane_id="$(herdr pane layout --pane "$current_pane_id" | jq -r --argjson idx "$n" '
  .result.layout.panes
  | sort_by(.rect.y, .rect.x)
  | .[$idx - 1].pane_id // empty
')"

# 指定番号のpaneが無ければ何もしない
[ -n "$pane_id" ] || exit 0

printf '{"id":"focus-pane-%s","method":"pane.focus","params":{"pane_id":"%s"}}\n' "$n" "$pane_id" \
  | nc -U "$sock" -w 1 >/dev/null 2>&1 || true
