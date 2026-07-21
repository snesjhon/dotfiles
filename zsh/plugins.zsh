# ============================================================
# Plugin loading + bootstrap. Each plugin's own settings/functions live in
# plugins/<name>.zsh, sourced right before its load line below -- settings a
# plugin reads at source time (fzf's default command, zsh-autosuggestions'
# highlight style) must be set before that plugin loads. Unlike vim's
# plugins.vim (bootstrap everything via plug#end(), then loop over settings
# files afterward) zsh has no separate load-then-configure phase, so each
# plugin here is inlined at its own load point instead of deferred to a
# trailing loop. Keybindings are centralized in mappings.zsh instead of
# living here.
# ============================================================

# --- starship ---
eval "$(starship init zsh)"

# --- theme (bat/fzf light-dark, see plugins/theme.zsh) ---
source "$ZSH_CONFIG_DIR/plugins/theme.zsh"

# --- ripgrep ---
source "$ZSH_CONFIG_DIR/plugins/ripgrep.zsh"

# --- fzf ---
source "$ZSH_CONFIG_DIR/plugins/fzf.zsh"
source <(fzf --zsh)

# --- zsh-autosuggestions ---
source "$ZSH_CONFIG_DIR/plugins/zsh-autosuggestions.zsh"
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# --- zsh-syntax-highlighting ---
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
