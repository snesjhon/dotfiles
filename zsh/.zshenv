# .zshenv - sourced for all zsh invocations (login, interactive, scripts)
# This ensures PATH is set correctly even in tmux and other non-interactive contexts

# HOMEBREW
[[ -x /opt/homebrew/bin/brew ]] && eval $(/opt/homebrew/bin/brew shellenv)
