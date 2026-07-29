# ============================================================
# All custom keybindings, centralized here regardless of built-in/plugin origin (settings/functions live in plugins/*.zsh). Sourced after plugins.zsh so our Tab binding isn't overridden by fzf's own rebind.
# ============================================================

# --- vi mode (built-in, no plugin) ---
bindkey -v
export KEYTIMEOUT=1
bindkey "^H" backward-delete-char
bindkey "^?" backward-delete-char

# --- completion (built-in) ---
bindkey '^ ' menu-complete

# --- zsh-autosuggestions (see plugins/zsh-autosuggestions.zsh) ---
bindkey '^I' autosuggest-accept

# --- history search (built-in) ---
bindkey '^[[A' history-beginning-search-backward
bindkey '^[[B' history-beginning-search-forward
