# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.dotfiles/zsh/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

XDG_PICTURES_DIR=${HOME}/Imagens/codeshots

export ZSH_COMPDUMP=${HOME}/.zcompdump-${HOST}

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

if [ -x "$(command -v tmux)" ] && [ -n "${DISPLAY}" ] && [ -z "${TMUX}" ]; then
    exec tmux new-session -A -s ${USER} >/dev/null 2>&1
fi

source ~/.config/zsh/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.dotfiles/zsh/.p10k.zsh.
[[ ! -f ~/.dotfiles/zsh/.p10k.zsh ]] || source ~/.dotfiles/zsh/.p10k.zsh

source ~/.dotfiles/zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
