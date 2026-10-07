#!/bin/bash
# Shows nvim session <name> (see nvim/lua/session_defs.lua) in Ghostty. If a window is already attached to a session, that window switches to <name>; otherwise a new window starts it. Usage: mux-session.sh <name>

NAME=$1
[ -z "$NAME" ] && { echo "usage: mux-session.sh <name>" >&2; exit 1; }

NVIM_BIN=/opt/homebrew/bin/nvim
DIR=${TMPDIR:-/tmp}
DIR=${DIR%/}/mux-sessions

# A server with a UI attached means a Ghostty window is showing a session.
attached=
for sock in "$DIR"/*.sock; do
  [ -S "$sock" ] || continue
  # --headless and no stdin: run from a terminal, a plain nvim client starts a TUI and its escape codes end up in the output.
  uis=$("$NVIM_BIN" --headless --server "$sock" --remote-expr 'len(nvim_list_uis())' </dev/null 2>/dev/null) || continue
  case $uis in
    '' | *[!0-9]*) continue ;;
  esac
  [ "$uis" -gt 0 ] && attached=1
done

if [ -n "$attached" ]; then
  # The switch has to run from the window's own key input, so leave the name in
  # a file and press the key mapped to mux.switch_wanted (nvim/lua/mappings/tabs.lua).
  echo "$NAME" > "$DIR/want"
  osascript <<'EOF'
tell application "Ghostty"
  activate
  send key "f12" modifiers "control,option,shift" to focused terminal of selected tab of front window
end tell
EOF
  exit 0
fi

# A cold-started Ghostty opens its own blank window. It is closed once the session window exists, so only one is left.
osascript - "$NAME" <<'EOF'
on run argv
  set wasRunning to application "Ghostty" is running
  tell application "Ghostty"
    activate
    set blank to missing value
    if not wasRunning then
      repeat 50 times
        if (count of windows) > 0 then exit repeat
        delay 0.1
      end repeat
      if (count of windows) > 0 then set blank to window 1
    end if
    set cfg to new surface configuration
    set command of cfg to "/bin/zsh -lic 'mux " & item 1 of argv & "'"
    new window with configuration cfg
    if blank is not missing value then close window blank
  end tell
end run
EOF
