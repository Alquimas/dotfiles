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

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

path+=("$HOME/.cargo/bin")
path+=(${HOME}/.local/bin)
path+=(${HOME}/parsers/d_lang/compiler)
# initialise completions with ZSH's compinit
autoload -Uz compinit && compinit

source ~/.dotfiles/zsh/zsh-autosuggestions/zsh-autosuggestions.zsh

eval "$(fzf --zsh)"

export STARSHIP_CONFIG=~/.dotfiles/zsh/starship.toml
eval "$(starship init zsh)"
