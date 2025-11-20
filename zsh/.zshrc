# Based on josean's dotfiles: https://github.com/josean-dev/dev-environment-files/blob/main/.zshrc
export EDITOR=nvim
export VISUAL=nvim

HISTFILE=$HOME/.zhistory
SAVEHIST=1000
HISTSIZE=999
setopt share_history 
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_verify
setopt NO_BEEP
setopt IGNORE_EOF

# HOMEBREW
[[ -x /opt/homebrew/bin/brew ]] && eval $(/opt/homebrew/bin/brew shellenv)

# VIM 
bindkey -v
bindkey "^H" backward-delete-char
bindkey "^?" backward-delete-char

# STARSHIP
eval "$(starship init zsh)"

# FZF
export FZF_DEFAULT_OPTS='--height 40% --tmux'
export FZF_CTRL_R_OPTS="--height 40% --tmux --reverse"
source <(fzf --zsh)

# ZSH PLUGINS 
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $(brew --prefix)/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh

bindkey '^ ' menu-complete
bindkey '^I' autosuggest-accept 

bindkey -M menuselect '^M' .accept-line
bindkey '^[[A' history-beginning-search-backward
bindkey '^[[B' history-beginning-search-forward
export PATH="$HOME/.local/bin:$PATH"
