# ~/.dotfiles/zsh/exports.zsh -- environment variables
# ----------------------------------------------------

# bat as pager for git and man
export BAT_PAGER="less -RF"
export GIT_PAGER="delta"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# Editor
export EDITOR="nvim"
export VISUAL="nvim"

# Homebrew
if [[ -f /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Go
export GOPATH="$HOME/go"
export PATH="$GOPATH/bin:$PATH"
