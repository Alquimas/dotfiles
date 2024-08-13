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
# golang
path+="${HOME}/.local/bin/go/bin"
path+="${HOME}/go/bin"
path+="${HOME}/Documents/idea/bin"

source ~/.dotfiles/zsh/zsh-autosuggestions/zsh-autosuggestions.zsh

export STARSHIP_CONFIG=~/.dotfiles/zsh/starship.toml
eval "$(starship init zsh)"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
export FZF_DEFAULT_COMMAND='fd --type f'


# >>> JVM installed by coursier >>>
export JAVA_HOME="/home/alquimas/.cache/coursier/arc/https/github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.24%252B8/OpenJDK11U-jdk_x64_linux_hotspot_11.0.24_8.tar.gz/jdk-11.0.24+8"
export PATH="$PATH:/home/alquimas/.cache/coursier/arc/https/github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.24%252B8/OpenJDK11U-jdk_x64_linux_hotspot_11.0.24_8.tar.gz/jdk-11.0.24+8/bin"
# <<< JVM installed by coursier <<<

# >>> coursier install directory >>>
export PATH="$PATH:/home/alquimas/.local/share/coursier/bin"
# <<< coursier install directory <<<
#
if [[ -z ${TMUX} ]]; then
    fastfetch -c ~/.dotfiles/small_debian.jsonc
fi
