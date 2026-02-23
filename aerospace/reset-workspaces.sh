#!/bin/sh
# Reset all windows back to their designated workspaces

AEROSPACE=/opt/homebrew/bin/aerospace

$AEROSPACE list-windows --all --format '%{window-id}|%{app-bundle-id}' | while IFS='|' read -r window_id bundle_id; do
    case "$bundle_id" in
        "com.apple.Music")       workspace="1" ;;
        "md.obsidian")           workspace="2" ;;
        "com.google.Chrome")     workspace="3" ;;
        "com.mitchellh.ghostty") workspace="4" ;;
        *) workspace="" ;;
    esac
    if [ -n "$workspace" ]; then
        $AEROSPACE move-node-to-workspace --window-id "$window_id" "$workspace"
    fi
done
