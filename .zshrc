alias find='find "`pwd`" -name'
alias mdfind='mdfind -onlyin . '
alias mkdir='mkdir -p '
alias -g C='| pbcopy'
alias cls='clear'
alias ls='ls -Gp'
alias la='ls -Ap'
alias ll='ls -hlap'
alias o='open'
function up () {
    if [ $# -eq 0 ] ; then
        cd ..
    else
        for ((i=0; i < $1; i++)); do cd ..; done
    fi
}

# Set default editor
export EDITOR=vim
export VISUAL=vim
export PAGER=less
export LESS='-iMR'
export LESSOPEN='|lessfilter %s'

# Set command history file
export HISTFILE=~/.zhistory

# Set size of history
export HISTSIZE=1000
export SAVEHIST=100000

# Set char code
export LANG=ja_JP.UTF-8

export CLICOLOR=true
export LSCOLORS='gxfxxxxxcxxxxxxxxxxxxx'
export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=36;01:cd=33;01:su=31;40;07:sg=36;40;07:tw=32;40;07:ow=33;40;07:'

export GOPATH="/usr/local/bin"
export MANPATH="$MANPATH:/opt/local/share/man"
export FPATH="$FPATH:/usr/local/share/zsh/site-functions:/usr/share/zsh/5.3/functions"
export PATH="$PATH:$HOME/.cargo/bin:$HOME/go/bin:$HOME/.vimpkg/bin:/usr/local/bin:/opt/local/bin:/opt/local/sbin:/usr/local/bin:/usr/local/opt/fzf/bin"

# enable Ctrl + E, Ctrl + A and more
bindkey -e

# Display list of completions
setopt auto_list

# Go next completion on press completion key
setopt auto_menu

# Save command to history without extra spaces
setopt hist_reduce_blanks

# Not save duplicated commands with history
setopt hist_save_no_dups

# Not exit with ^D
setopt ignore_eof

# Save history immediately (by default, on exit shell)
setopt inc_append_history

# Treat as comment behind #
setopt interactive_comments

# Disable beep
setopt no_beep
setopt no_hist_beep
setopt no_list_beep

# complete behind of =
# (e.g.: --option=value)
setopt magic_equal_subst

# Notify changing state of background process
setopt notify

# Enable 8bit chars
setopt print_eight_bit

# Display status when exit status is not 0
setopt print_exit_value

# Confirm before "rm *"
setopt rm_star_wait

# Hide right prompt after execute command
setopt transient_rprompt

# Set options of completions
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

# Setup sindresorhus/pure
zplugin ice pick"async.zsh" src"pure.zsh"
zplugin light sindresorhus/pure
autoload -Uz compinit -u; compinit

# Setup fzf
# Auto-completion
[[ $- == *i* ]] && source "/usr/local/opt/fzf/shell/completion.zsh" 2> /dev/null
# Key bindings
source "/usr/local/opt/fzf/shell/key-bindings.zsh"

# pyenv
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi
