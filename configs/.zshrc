export PATH="$HOME/.local/bin:$PATH"

alias zed='~/.local/zed.app/libexec/zed-editor'
alias zed-amd='DRI_PRIME=1 ~/.local/zed.app/libexec/zed-editor'
alias firefox-amd='DRI_PRIME=1 firefox'

# History
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

setopt appendhistory
setopt sharehistory
setopt hist_ignore_dups
setopt hist_ignore_space
setopt autocd
setopt correct
setopt interactivecomments

# Completion
autoload -Uz compinit
compinit

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# Keys
bindkey -e
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line

# Plugins
source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'

# Aliases
alias ls='ls --color=auto'
alias ll='ls -lah'
alias la='ls -A'
alias cls='clear'
alias ..='cd ..'
alias ...='cd ../..'

alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph --decorate --all'

# Prompt
eval "$(starship init zsh)"

# Fix Ctrl + Arrow keys on Kitty/Zsh

bindkey -e

# Ctrl + Left / Right
bindkey '^[[1;5D' backward-word
bindkey '^[[1;5C' forward-word

# Ctrl + Up / Down
bindkey '^[[1;5A' up-line-or-history
bindkey '^[[1;5B' down-line-or-history

# Home / End
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[1~' beginning-of-line
bindkey '^[[4~' end-of-line

# Delete
bindkey '^[[3~' delete-char
eval "$(/home/pedro/.local/bin/mise activate zsh)"

refreshenv() {
  local files=(".env" ".env.local" ".env.dev" ".env.development")

  for file in "${files[@]}"; do
    if [ -f "$file" ]; then
      set -a
      source "$file"
      set +a
      echo "env loaded from $file"
      return 0
    fi
  done

  echo "no env file found"
  return 1
}
export MESA_VK_DEVICE_SELECT=1002:699f
export ZED_DEVICE_ID=699f
