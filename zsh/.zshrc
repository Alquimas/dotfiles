plugins=(git fancy-ctrl-z)

export ZSH="$ZDOTDIR/oh-my-zsh"

ZSH_THEME="half-life" # set by `omz`

export ZSH_COMPDUMP=${HOME}/.zcompdump-${HOST}
source $ZSH/oh-my-zsh.sh

# Histórico:
export HISTFILE=${HOME}/.zsh_history
export HISTSIZE=15000
export SAVEHIST=15000

# Editor padrão no zsh:
export FCEDIT='nvim'
export VISUAL=$FCEDIT
export EDITOR=$FCEDIT

alias :exit="exit"
alias :q="exit"
alias :clear="clear"

path+=("$HOME/.cargo/bin")
[ -f "/home/alquimas/.ghcup/env" ] && source "/home/alquimas/.ghcup/env" # ghcup-env
path+=("$HOME/zig/zig-linux-x86_64-0.12.0-dev.3336+dbb11915b")

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

. "$HOME/.asdf/asdf.sh"
# append completions to fpath
fpath+=(${ASDF_DIR}/completions $fpath)
# initialise completions with ZSH's compinit
autoload -Uz compinit && compinit

#if [ -x "$(command -v tmux)" ] && [ -n "${DISPLAY}" ] && [ -z "${TMUX}" ]; then
#    exec tmux new-session -A -s ${USER} >/dev/null 2>&1
#fi
