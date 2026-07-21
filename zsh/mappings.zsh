# ============================================================
# All custom keybindings, centralized here regardless of whether they're
# built-in zsh features or belong to a plugin. Settings/functions live in
# plugins/*.zsh instead -- see plugins.zsh. This file only binds keys.
#
# Sourced after plugins.zsh: fzf's completion script unconditionally rebinds
# Tab (falling back to whatever it was bound to before), so our Tab ->
# autosuggest-accept binding has to come after plugins.zsh loads fzf, not
# before, or fzf's binding wins instead.
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
