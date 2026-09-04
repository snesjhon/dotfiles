# ============================================================
# Plugin loading + bootstrap. Each plugin's settings live in plugins/<name>.zsh, sourced right before its load line (zsh has no separate bootstrap-then-configure phase). Keybindings live in mappings.zsh.
# ============================================================

# --- starship ---
eval "$(starship init zsh)"

# --- theme (bat/fzf light-dark, see plugins/theme.zsh) ---
source "$ZSH_CONFIG_DIR/plugins/theme.zsh"

# --- fzf ---
source "$ZSH_CONFIG_DIR/plugins/fzf.zsh"
source <(fzf --zsh)

# --- zsh-autosuggestions ---
source "$ZSH_CONFIG_DIR/plugins/zsh-autosuggestions.zsh"

# brew --prefix forks a Ruby process (~40-50ms) -- compute once, reuse for both plugins below.
BREW_PREFIX="$(brew --prefix)"
source "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

# --- zsh-syntax-highlighting ---
source "$BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
unset BREW_PREFIX
