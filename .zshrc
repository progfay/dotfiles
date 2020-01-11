alias vi='vim'
alias find='find `pwd` -name'
alias mdfind='mdfind -onlyin . '
alias mkdir='mkdir -p '
alias -g C='| pbcopy'
alias -g L='| less'
alias cls='clear'
alias ls='ls -Gp'
alias la='ls -Ap'
alias ll='ls -hlap'
alias o='open'
alias qr='qrencode -t ASCII'
function up () {
    if [ $# -eq 0 ] ; then
        cd ..
    else
        for ((i=0; i < $1; i++)); do cd ..; done
    fi
}

# less
export LESS='-iMR'
export LESSOPEN='|lessfilter %s'

# 標準エディタを設定する
export EDITOR=vim
export VISUAL=vim
export PAGER=less

# コマンド履歴を保存するファイルを指定する
export HISTFILE=~/.zhistory

# メモリに保存する履歴の件数を指定する
export HISTSIZE=1000

# ファイルに保存する履歴の件数を指定する
export SAVEHIST=100000

# 文字コードを設定する
export LANG=ja_JP.UTF-8

export CLICOLOR=true
export LSCOLORS='gxfxxxxxcxxxxxxxxxxxxx'
export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=36;01:cd=33;01:su=31;40;07:sg=36;40;07:tw=32;40;07:ow=33;40;07:'

export EMSDK="$HOME/emsdk"
export EM_CONFIG="$HOME/.emscripten"
export BINARYEN_ROOT="$HOME/emsdk/clang/e1.38.6_64bit/binaryen"
export EMSCRIPTEN="$HOME/emsdk/emscripten/1.38.6"
export GOPATH="/usr/local/bin"
export MANPATH="$MANPATH:/opt/local/share/man"
export FPATH="$FPATH:/usr/local/share/zsh/site-functions:/usr/share/zsh/5.3/functions"
export PATH="$PATH:$HOME/.cargo/bin:$HOME/emsdk:$HOME/emsdk/clang/e1.38.6_64bit:$HOME/emsdk/node/8.9.1_64bit/bin:$HOME/emsdk/emscripten/1.38.6:$HOME/go/bin:$HOME/.vimpkg/bin:/usr/local/bin:/opt/local/bin:/opt/local/sbin:/usr/local/bin:/usr/local/opt/fzf/bin"

# enable Ctrl + E, Ctrl + A and more
bindkey -e

# 補完候補を一覧で表示する
setopt auto_list

# 補完キー連打で候補順に自動で補完する
setopt auto_menu

# コマンド中の余分なスペースは削除して履歴に記録する
setopt hist_reduce_blanks

# 履歴と重複するコマンドを記録しない
setopt hist_save_no_dups

# ^D でシェルを終了しない
setopt ignore_eof

# 履歴をすぐに追加する（通常はシェル終了時）
setopt inc_append_history

# # 以降をコメントとして扱う
setopt interactive_comments

# ビープを無効にする
setopt no_beep
setopt no_hist_beep
setopt no_list_beep

# = 以降も補完する（例：--option=value）
setopt magic_equal_subst

# バックグラウンド処理の状態変化をすぐに通知する
setopt notify

# 8bit文字を有効にする
setopt print_eight_bit

# 終了ステータスが0以外の場合にステータスを表示する
setopt print_exit_value

# rm * の前に確認をとる
setopt rm_star_wait

# コマンド実行後は右プロンプトを消す
setopt transient_rprompt

# 補完の表示方法を変更する
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*' group-name ''
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' use-cache true
zstyle ':completion:*' verbose yes
zstyle ':completion:*:default' menu select=2
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion:*:options' description 'yes'

## Added by Zplugin's installer
if [[ ! -d $HOME/.zplugin/bin ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing Zplugin…%f"
    command mkdir -p $HOME/.zplugin
    command git clone https://github.com/zdharma/zplugin $HOME/.zplugin/bin && \
        print -P "%F{33}▓▒░ %F{34}Installation successful.%F" || \
        print -P "%F{160}▓▒░ The clone has failed.%F"
fi
source "$HOME/.zplugin/bin/zplugin.zsh"
autoload -Uz _zplugin
(( ${+_comps} )) && _comps[zplugin]=_zplugin
### End of Zplugin installer's chunk

zplugin light 'zsh-users/zsh-autosuggestions'
zplugin light "zsh-users/zsh-syntax-highlighting"
zplugin light "zsh-users/zsh-completions"
zplugin ice pick"async.zsh" src"pure.zsh"
zplugin light sindresorhus/pure
autoload -Uz compinit -u
compinit

# Setup fzf
# Auto-completion
[[ $- == *i* ]] && source "/usr/local/opt/fzf/shell/completion.zsh" 2> /dev/null
# Key bindings
source "/usr/local/opt/fzf/shell/key-bindings.zsh"
