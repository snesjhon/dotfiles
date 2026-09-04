#!/bin/bash
# Toggles a floating scratch terminal (tmux popup). Backed by a persistent session, so cwd
# and running jobs survive between opens -- closing just detaches, it doesn't kill the shell.
# Usage: tmux-popup.sh

POPUP_SESSION="popup"

# Same resolution as zsh/plugins/theme.zsh, reimplemented here rather than shared:
# tmux-powerkit's own render cycle overwrites the global popup-style/popup-border-style
# options with its solarized theme, so this passes color explicitly per call instead of
# trusting that global state.
resolve_theme() {
  if [ "$(defaults read -g AppleInterfaceStyle 2>/dev/null)" = "Dark" ]; then
    echo dark
  else
    echo light
  fi
}

if [ "$(tmux display-message -p '#{session_name}')" = "$POPUP_SESSION" ]; then
  tmux detach-client
else
  PANE_PATH=$(tmux display-message -p '#{pane_current_path}')
  if [ "$(resolve_theme)" = dark ]; then
    POPUP_STYLE="bg=#28262B,fg=#FFFFFF"
    BORDER_STYLE="fg=#5D5277"
  else
    POPUP_STYLE="bg=#FAFAFF,fg=#303030"
    BORDER_STYLE="fg=#E2DEF8"
  fi
  tmux display-popup -E -b rounded -s "$POPUP_STYLE" -S "$BORDER_STYLE" -w 80% -h 80% \
    "tmux new-session -A -s $POPUP_SESSION -c '$PANE_PATH'"
fi
