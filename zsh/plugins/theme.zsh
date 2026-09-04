# macOS's own light/dark appearance is the single source of truth. nvim's <leader>ut
# toggle is in-memory only, so there's nothing to reconcile against here.
_resolve_theme() {
  if [[ "$(defaults read -g AppleInterfaceStyle 2>/dev/null)" == "Dark" ]]; then
    echo dark
  else
    echo light
  fi
}

# fzf's own UI colors (no auto:system equivalent like bat), re-resolved by fzf-pickers.zsh on every invocation so an already-open shell doesn't go stale when macOS's appearance changes.
_fzf_theme_opts() {
  if [[ "$(_resolve_theme)" == dark ]]; then
    echo "--color=bg:#28262B,fg:#FFFFFF,hl:#7FB6ED,fg+:#FFFFFF,bg+:#312F35,hl+:#7FB6ED,info:#8B7AA0,prompt:#F57F6C,pointer:#F57F6C,marker:#52B87A,spinner:#52B87A,header:#8B7AA0,border:#5D5277,gutter:#28262B --layout=reverse --info=inline-right --border=rounded"
  else
    echo "--color=bg:#FAFAFF,fg:#303030,hl:#006CD8,fg+:#303030,bg+:#EFEFFC,hl+:#006CD8,info:#7878A8,prompt:#A31700,pointer:#A31700,marker:#0A7F3D,spinner:#0A7F3D,header:#7878A8,border:#E2DEF8,gutter:#FAFAFF --layout=reverse --info=inline-right --border=rounded"
  fi
}

export FZF_DEFAULT_OPTS="$(_fzf_theme_opts)"

if [[ "$(_resolve_theme)" == dark ]]; then
  _popup_style="bg=#28262B,fg=#FFFFFF"
  _popup_border_style="fg=#5D5277"
else
  _popup_style="bg=#FAFAFF,fg=#303030"
  _popup_border_style="fg=#E2DEF8"
fi

# Overrides just these two options so tmux-powerkit's hardcoded dark popup doesn't flash before fzf repaints it with FZF_DEFAULT_OPTS.
if [[ -n "$TMUX" ]]; then
  tmux set -g popup-style "$_popup_style" 2>/dev/null
  tmux set -g popup-border-style "$_popup_border_style" 2>/dev/null
fi
unset _popup_style _popup_border_style
