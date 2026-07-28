#!/usr/bin/env bash
# broadcastモードの実体。overlay paneとしてフォーカスを持ち、
# 標準入力から読んだ入力を対象pane群へsend-textで中継し続ける。
# macOS標準の/bin/bash(3.2系)はread -n 1がロケールを認識せず生バイト単位
# でしか読めないため、先頭バイトからUTF-8のシーケンス長を判定して
# 続きのbyteを読み進め、1文字(1バイトのASCIIまたは複数バイトのUTF-8)分を
# まとめてから中継する。1byteずつ送ると不完全なUTF-8断片になり、
# 送信先での引数解釈に失敗して日本語入力が反映されない問題があった。
#
# Ctrl+C/Ctrl+\/Ctrl+Zは、Herdr側がpane processへ直接シグナルを送っている
# らしく(生バイトとしてptyに届かない)、readループでは検知できない。
# そのため INT/QUIT/TSTP をtrapし、捕まえたら対応する制御バイトを
# 自分でbroadcastする(=シグナルを検知の合図として使い、実際に転送する
# バイトはこちらで組み立てる)。
#
# 注意点その1: broadcast中は"&"でバックグラウンド化して"wait"していたが、
# trapハンドラ内のwaitとメインループのwaitが衝突しうるため、
# broadcastは常に逐次実行(バックグラウンド化しない)にしている。
# 注意点その2: シグナルでブロッキング中のreadが中断されると、read自体が
# 失敗(非0)を返すことがあり、これをそのままwhileの継続条件に使うと
# シグナルを受けるたびにループが終了してしまう(=broadcastが勝手に
# 終了する不具合の原因だった)。そのためreadの成否ではなくEOFの
# 連続回数でのみループを終了するようにしている。
#
# toggle.shから SIGTERM を受けると exit 0 で即座にプロセスを終了させ、
# それに伴いoverlay paneも自動的に閉じる。
set -uo pipefail

state_dir="${HERDR_PLUGIN_STATE_DIR:?}"
active_file="$state_dir/active"
pid_file="$state_dir/relay.pid"
targets_file="$state_dir/targets.json"

cleanup() {
  stty sane 2>/dev/null || true
  rm -f "$active_file" "$pid_file"
}
trap cleanup EXIT
trap 'exit 0' TERM

[ -f "$targets_file" ] || exit 1
targets="$(jq -r '.target_pane_ids[]' "$targets_file")"
[ -n "$targets" ] || exit 0

broadcast() {
  # IFS= readがシグナルで中断されると、そのコマンドに一時設定された
  # IFS=''がtrapハンドラ実行時にまで持ち越されることがあり、
  # ここでのunquoted展開によるword-splittingが効かなくなる
  # (=対象paneが1つの文字列に連結されてpane_not_foundになる)。
  # そのため呼び出し元の状態に関係なく明示的にIFSを戻す。
  local IFS=$' \t\n'
  local data="$1"
  local pane
  for pane in $targets; do
    herdr pane send-text "$pane" "$data" >/dev/null 2>&1
  done
}

on_int()  { broadcast $'\x03'; }  # Ctrl+C
on_quit() { broadcast $'\x1c'; }  # Ctrl+\
on_tstp() { broadcast $'\x1a'; }  # Ctrl+Z
trap on_int INT
trap on_quit QUIT
trap on_tstp TSTP

echo "$$" > "$pid_file"

stty -echo raw

# stty echoを切っているため入力文字は表示されないが、cursorそのものは出す。
# raw modeはopostも切れるため、改行はCRLFを明示する必要がある。
target_count="$(printf '%s\n' "$targets" | wc -l | tr -d ' ')"
printf '\033[?25h\033[1mBroadcast ON\033[0m -> %s panes (Cmd+Alt+I to stop)\r\n' "$target_count"

fail_count=0
while :; do
  IFS= read -r -n 1 -d '' lead
  rc=$?

  if [ "$rc" -ne 0 ]; then
    # シグナルによる中断など。連続失敗が続く場合のみ本当のEOF/切断とみなす。
    fail_count=$((fail_count + 1))
    if [ "$fail_count" -ge 50 ]; then
      break
    fi
    sleep 0.05
    continue
  fi
  fail_count=0

  # signed charとして解釈されるため負値は+256で実バイト値に戻す
  v=$(printf '%d' "'$lead")
  [ "$v" -lt 0 ] && v=$((v + 256))

  extra=0
  if [ "$v" -ge 240 ]; then
    extra=3   # 4byte seq (F0-F4)
  elif [ "$v" -ge 224 ]; then
    extra=2   # 3byte seq (E0-EF), 日本語の大半はここ
  elif [ "$v" -ge 192 ]; then
    extra=1   # 2byte seq (C2-DF)
  fi

  chunk="$lead"
  i=0
  while [ "$i" -lt "$extra" ]; do
    IFS= read -r -n 1 -d '' cont || break
    chunk="$chunk$cont"
    i=$((i + 1))
  done

  broadcast "$chunk"
done
