#!/usr/bin/env bash
# 現在のtab内の全paneのsplit ratioを均等値に再計算する(単体実行用)。
# ロジック本体は equalize-lib.sh の equalize_current_tab を参照。
set -euo pipefail

# プラグインはHerdrサーバーの子プロセスとして実行され、対話シェルの
# 設定(zshrc等)を経由しないためPATHが最小限になる。herdr/jq/ncを
# 確実に解決できるよう既知のインストール先を明示的に追加しておく。
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/bin:/bin:$PATH"

dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=equalize-lib.sh
source "$dir/equalize-lib.sh"

equalize_current_tab
