#!/usr/bin/env bash
# Sesh session picker with github-nvim-theme colors that respect system appearance

if defaults read -g AppleInterfaceStyle &>/dev/null; then
  # Dark mode — github_dark_default palette
  bg="#0d1117"
  border_fg="#30363d"
  fzf_colors="--color=bg:$bg,fg:#c9d1d9,query:#c9d1d9,bg+:#161b22,fg+:#f0f6fc,hl:#58a6ff,hl+:#79c0ff,info:#8b949e,border:$border_fg,label:#58a6ff,preview-label:#58a6ff,pointer:#58a6ff,prompt:#58a6ff,spinner:#58a6ff,header:#8b949e,gutter:$bg,marker:#3fb950"
else
  # Light mode — github_light_default palette
  bg="#ffffff"
  border_fg="#d0d7de"
  fzf_colors="--color=bg:$bg,fg:#24292f,query:#24292f,bg+:#f6f8fa,fg+:#24292f,hl:#0969da,hl+:#0550ae,info:#57606a,border:$border_fg,label:#0969da,preview-label:#0969da,pointer:#0969da,prompt:#0969da,spinner:#0969da,header:#57606a,gutter:$bg,marker:#1a7f37"
fi

# Set tmux popup background to match before fzf renders
tmux set -g popup-style "bg=$bg"
tmux set -g popup-border-style "fg=$border_fg,bg=$bg"

sesh connect "$(
  sesh list --icons | fzf-tmux -p 80%,70% \
    --no-sort --ansi --layout reverse --border-label ' sesh ' --prompt '⚡ ' \
    $fzf_colors \
    --header ' ^a all ^t tmux ^g configs ^x zoxide ^d tmux kill ^f find' \
    --bind 'tab:down,btab:up' \
    --bind 'ctrl-a:change-prompt(⚡  )+reload(sesh list --icons)' \
    --bind 'ctrl-t:change-prompt(🪟  )+reload(sesh list -t --icons)' \
    --bind 'ctrl-g:change-prompt(⚙️  )+reload(sesh list -c --icons)' \
    --bind 'ctrl-x:change-prompt(📁  )+reload(sesh list -z --icons)' \
    --bind 'ctrl-f:change-prompt(🔎  )+reload(fd -H -d 2 -t d -E .Trash . ~)' \
    --bind 'ctrl-d:execute(tmux kill-session -t {2..})+change-prompt(⚡  )+reload(sesh list --icons)' \
    --preview-window 'right:55%' \
    --preview 'sesh preview {}'
)"
