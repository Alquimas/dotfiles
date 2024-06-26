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

path+=(${HOME}/.cargo/bin)
path+=(${HOME}/.local/bin)

#asdf
. "${HOME}/.asdf/asdf.sh"
# append completions to fpath
fpath=(${ASDF_DIR}/completions $fpath)
# initialise completions with ZSH's compinit
autoload -Uz compinit && compinit

source ~/.dotfiles/zsh/zsh-autosuggestions/zsh-autosuggestions.zsh

export STARSHIP_CONFIG=~/.dotfiles/zsh/starship.toml
eval "$(starship init zsh)"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
export FZF_DEFAULT_COMMAND='fd --type f'

fastfetch -c ~/.dotfiles/small_debian.jsonc
