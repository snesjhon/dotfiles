#!/bin/bash

# Setup Claude Code custom skills
# This script creates symlinks from dotfiles to ~/.claude/skills/

set -e

echo "Setting up Claude Code custom skills..."

# Create skills directory if it doesn't exist
mkdir -p ~/.claude/skills

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="$SCRIPT_DIR/skills"

# Check if skills directory exists
if [ ! -d "$SKILLS_DIR" ]; then
  echo "Error: Skills directory not found at $SKILLS_DIR"
  exit 1
fi

# Create symlinks for all skills
for skill_path in "$SKILLS_DIR"/*; do
  if [ -d "$skill_path" ]; then
    skill_name=$(basename "$skill_path")
    target="$HOME/.claude/skills/$skill_name"

    # Remove existing symlink or directory
    if [ -L "$target" ] || [ -e "$target" ]; then
      echo "Removing existing: $target"
      rm -rf "$target"
    fi

    # Create symlink
    ln -sf "$skill_path" "$target"
    echo "✓ Linked: $skill_name"
  fi
done

echo ""
echo "✓ Setup complete! Available skills:"
ls -1 ~/.claude/skills/
echo ""

echo "You can now use these skills from any project:"
echo "  /leet-mental [problem description]"
