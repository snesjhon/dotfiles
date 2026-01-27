#!/bin/bash
# Tmux Zen Mode - Center your terminal
# Usage: tmux-zen.sh [width]

CENTER_WIDTH="${1:-120}"

CURRENT_PANE=$(tmux display-message -p '#{pane_id}')
PANE_COUNT=$(tmux display-message -p '#{window_panes}')
WINDOW_WIDTH=$(tmux display-message -p '#{window_width}')

# Check if we're already in zen mode
is_zen_mode() {
    [ "$PANE_COUNT" -eq 3 ]
}

create_zen() {
    if is_zen_mode; then
        return
    fi

    if [ "$PANE_COUNT" -ne 1 ]; then
        tmux display-message "Zen mode: single pane only"
        return
    fi

    TOTAL_MARGIN=$((WINDOW_WIDTH - CENTER_WIDTH - 2))
    if [ "$TOTAL_MARGIN" -lt 10 ]; then
        tmux display-message "Zen mode: window too narrow"
        return
    fi

    SIDE_WIDTH=$((TOTAL_MARGIN / 2))

    # Create left spacer pane (before current)
    tmux split-window -hb -t "$CURRENT_PANE" -l "$SIDE_WIDTH" "cat"

    # Create right spacer pane (after current)
    tmux split-window -h -t "$CURRENT_PANE" -l "$SIDE_WIDTH" "cat"

    # Refocus on the center pane
    tmux select-pane -t "$CURRENT_PANE"
}

destroy_zen() {
    if ! is_zen_mode; then
        return
    fi

    for pane in $(tmux list-panes -F '#{pane_id}'); do
        pane_command=$(tmux display-message -p -t "$pane" '#{pane_current_command}')
        if [ "$pane_command" = "cat" ]; then
            tmux kill-pane -t "$pane"
        fi
    done
}

toggle_zen() {
    if is_zen_mode; then
        destroy_zen
    else
        create_zen
    fi
}

toggle_zen
