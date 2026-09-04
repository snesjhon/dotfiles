#!/bin/bash
# Tmux Zen Mode - centers your terminal by padding a window with two empty
# spacer panes, in the spirit of nvim/lua/configs/no_neck_pain.lua.
#
# Usage: tmux-zen.sh <command> <pane-id> [width]
#
#   toggle  add/remove the margins on this pane's window
#   kill    kill-pane replacement: when the centered pane is the last real one,
#           take the whole window instead, so the margins don't survive as
#           panes you'd have to close separately
#
# Zen is opt-in and manual: `prefix g`, and nothing else. No hook applies it on
# attach or on a new window, and nothing takes it away for the duration of a
# full-screen program -- when nvim or lazygit wants the whole width, toggle it
# off. That's why this script keeps no state of its own beyond the spacer panes
# themselves: with one entry point there's no "did the user mean this?" to
# remember, so every question it asks is answered by looking at the window.
#
# Spacers are tagged with the @zen_spacer pane option rather than recognized by
# the command they run: a real pane that happens to be running `cat` would
# otherwise look like a margin, and `kill` would take the window down with it.

CMD="${1:-}"
CURRENT_PANE="${2:-}"
# Width of the centered pane, in columns. The key binding doesn't pass a width,
# so this one number governs it. The optional third argument is only there for
# a one-off override from the command line.
CENTER_WIDTH="${3:-100}"

# The pane the binding fired from has to be passed in explicitly as #{pane_id},
# which run-shell expands. It can't be discovered here: run-shell doesn't
# export TMUX_PANE (that only exists in panes tmux itself creates), and
# display-message with no target resolves to whatever session tmux last used --
# so a script that kills panes would sooner or later act on the wrong session.
if [ -z "$CMD" ] || [ -z "$CURRENT_PANE" ]; then
    echo "tmux-zen: usage: tmux-zen.sh <toggle|kill> <pane-id> [width]" >&2
    exit 1
fi

# A pane border can't be switched off in tmux -- pane-border-lines has no
# "none" -- so the only way to make the margins read as empty space rather than
# a bounded panel is to paint the border the background color. Ghostty is set
# to GitLab Light / GitLab Dark, so follow whichever is live via #{client_theme}
# (tmux 3.6+) instead of hardcoding one of the two.
ZEN_BORDER_LIGHT="#fafaff"
ZEN_BORDER_DARK="#28262b"
ZEN_BORDER="fg=#{?#{==:#{client_theme},dark},${ZEN_BORDER_DARK},${ZEN_BORDER_LIGHT}}"

# --- queries, all against an explicit target ---

fmt() {
    tmux display-message -p -t "$1" "#{$2}"
}

spacers() {
    tmux list-panes -t "$1" -F '#{?#{==:#{@zen_spacer},1},#{pane_id},}' | grep -v '^$'
}

spacer_count() {
    spacers "$1" | grep -c .
}

is_zen() {
    [ "$(spacer_count "$1")" -gt 0 ]
}

is_spacer() {
    [ "$(fmt "$1" '@zen_spacer')" = "1" ]
}

# --- create / destroy ---

# create_zen <window-id> <pane-id>
create_zen() {
    local win="$1" pane="$2"

    if is_zen "$win"; then
        return
    fi

    local panes width
    read -r panes width <<<"$(tmux display-message -p -t "$win" '#{window_panes} #{window_width}')"

    if [ "$panes" -ne 1 ]; then
        tmux display-message "Zen mode: single pane only"
        return
    fi

    local total_margin
    total_margin=$((width - CENTER_WIDTH - 2))
    if [ "$total_margin" -lt 10 ]; then
        tmux display-message "Zen mode: window too narrow"
        return
    fi

    local side
    side=$((total_margin / 2))

    # One invocation, so the window goes straight from bare to centered. The
    # server drains its whole command queue before the client repaints, so this
    # is a single visible transition; issuing these as seven separate `tmux`
    # calls means seven, with the half-built layout on screen in between.
    # Points worth knowing:
    #
    #  * the border restyle comes first. Last would mean both splits are drawn
    #    in the global style -- two grey box-drawing lines that appear and then
    #    get repainted away. Window scope, so it beats the global style and
    #    survives powerkit re-theming.
    #  * `set -p` with no -t tags the pane `split-window` just created: the new
    #    pane becomes current, and later commands in the same queue resolve
    #    their default target against it. That's the only way to tag the
    #    spacers without the round trip `-P -F '#{pane_id}'` would cost.
    #  * the trailing `set -up` on the center pane is the safety net for that
    #    implicit targeting: if a split ever failed, its `set -p` would land on
    #    the center pane and `kill` would then treat the real pane as a margin.
    #    Clearing it unconditionally costs nothing and makes that unreachable.
    #  * select-pane is targeted, so it sets the window's active pane without
    #    dragging the client to a different window.
    tmux \
        set -w -t "$win" pane-border-style "$ZEN_BORDER" ';' \
        set -w -t "$win" pane-active-border-style "$ZEN_BORDER" ';' \
        split-window -hb -t "$pane" -l "$side" "cat" ';' \
        set -p @zen_spacer 1 ';' \
        split-window -h -t "$pane" -l "$side" "cat" ';' \
        set -p @zen_spacer 1 ';' \
        select-pane -t "$pane" ';' \
        set -upq -t "$pane" @zen_spacer
}

# destroy_zen <window-id>
#
# Also one invocation: killing the margins one at a time and then restoring the
# border style is three repaints, and the middle one is a lopsided window.
# Order matters within the chain too -- the panes go before the style does, so
# a mid-queue repaint can't catch the spacers wearing visible borders.
#
# -u on the styles drops the window-local override and falls back to the global
# one, rather than baking in whatever powerkit happened to be using.
destroy_zen() {
    local win="$1" pane
    local -a cmd=()

    for pane in $(spacers "$win"); do
        cmd+=(kill-pane -t "$pane" ';')
    done

    cmd+=(set -uwq -t "$win" pane-border-style ';')
    cmd+=(set -uwq -t "$win" pane-active-border-style)

    tmux "${cmd[@]}"
}

# --- commands ---

toggle_zen() {
    local win="$1" pane="$2"

    if is_zen "$win"; then
        destroy_zen "$win"
    else
        create_zen "$win" "$pane"
    fi
}

kill_zen_aware() {
    local win="$1" pane="$2"

    if ! is_zen "$win"; then
        tmux kill-pane -t "$pane"
        return
    fi

    # Only the margins would be left over: close the window as a whole. With
    # detach-on-destroy off this behaves like the old kill-pane did on a last
    # pane -- the window goes, the session switches rather than exiting.
    if [ "$(($(fmt "$win" 'window_panes') - $(spacer_count "$win")))" -le 1 ]; then
        tmux kill-window -t "$win"
        return
    fi

    # Real panes remain. Killing a margin would leave zen lopsided, so drop
    # zen entirely instead; otherwise kill the active pane as normal.
    if is_spacer "$pane"; then
        destroy_zen "$win"
    else
        tmux kill-pane -t "$pane"
    fi
}

WINDOW_ID=$(fmt "$CURRENT_PANE" 'window_id')
if [ -z "$WINDOW_ID" ]; then
    echo "tmux-zen: cannot resolve pane $CURRENT_PANE" >&2
    exit 1
fi

case "$CMD" in
    toggle) toggle_zen "$WINDOW_ID" "$CURRENT_PANE" ;;
    kill) kill_zen_aware "$WINDOW_ID" "$CURRENT_PANE" ;;
    *) tmux display-message "tmux-zen: unknown command '$CMD'" ;;
esac
