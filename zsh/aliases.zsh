# ~/.dotfiles/zsh/aliases.zsh -- shell aliases
# ----------------------------------------------

# eza (modern ls)
alias ls='eza --icons'
alias ll='eza -la --icons --git'
alias lt='eza --tree --level=2 --icons'
alias lta='eza --tree --level=2 -a --icons'

# bat (modern cat)
alias cat='bat -p'

# git shortcuts
alias g='git'
alias gs='git status -sb'
alias gd='git diff'
alias gl='git log --oneline --graph --decorate -20'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gpl='git pull'
alias gco='git checkout'
alias gsw='git switch'
alias gst='git stash'

# fzf helpers
alias cdf='cd "$(fd --type d --hidden --follow --exclude .git | fzf)"'
alias vf='nvim "$(fzf)"'
alias ta='tmux attach -t "$(tmux ls -F "#{session_name}" 2>/dev/null | fzf)" 2>/dev/null || tmux new-session'

# ports
alias p3000='lsof -i :3000'
alias k3000='kill -9 $(lsof -ti :3000) 2>/dev/null && echo "killed" || echo "nothing on 3000"'

# cockpit and jump
alias c='cockpit'
alias jj='j'

# misc
alias reload='exec zsh'
alias path='echo $PATH | tr ":" "\n"'
alias brewup='brew update && brew upgrade && brew cleanup'
