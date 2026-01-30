#!/bin/bash
# Create symlinks for dotfiles
# This script links config files from the dotfiles repo to their expected locations

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info() {
    printf "${GREEN}[INFO]${NC} %s\n" "$1"
}

warn() {
    printf "${YELLOW}[WARN]${NC} %s\n" "$1"
}

success() {
    printf "${GREEN}✓${NC} %s\n" "$1"
}

# Get the dotfiles directory (parent of os/)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Function to create symlink with backup
create_symlink() {
    local source="$1"
    local target="$2"
    local target_dir=$(dirname "$target")

    # Create parent directory if it doesn't exist
    mkdir -p "$target_dir"

    # Backup existing file/directory if it exists and is not a symlink
    if [ -e "$target" ] && [ ! -L "$target" ]; then
        warn "Backing up existing: $target"
        mv "$target" "${target}.backup.$(date +%Y%m%d_%H%M%S)"
    fi

    # Remove existing symlink if it exists
    if [ -L "$target" ]; then
        rm "$target"
    fi

    # Create symlink
    ln -sf "$source" "$target"
    success "Linked: $target -> $source"
}

info "Creating symlinks from $DOTFILES_DIR"
echo ""

# Neovim
if [ -d "$DOTFILES_DIR/nvim" ]; then
    create_symlink "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"
fi

# Tmux
if [ -f "$DOTFILES_DIR/tmux/tmux.conf" ]; then
    create_symlink "$DOTFILES_DIR/tmux/tmux.conf" "$HOME/.tmux.conf"
fi
if [ -f "$DOTFILES_DIR/tmux/tmux-zen.sh" ]; then
    create_symlink "$DOTFILES_DIR/tmux/tmux-zen.sh" "$HOME/.config/tmux/tmux-zen.sh"
fi

# Zsh
if [ -f "$DOTFILES_DIR/zsh/.zshrc" ]; then
    create_symlink "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
fi
if [ -f "$DOTFILES_DIR/zsh/.zprofile" ]; then
    create_symlink "$DOTFILES_DIR/zsh/.zprofile" "$HOME/.zprofile"
fi

# Starship
if [ -f "$DOTFILES_DIR/starship/starship.toml" ]; then
    create_symlink "$DOTFILES_DIR/starship/starship.toml" "$HOME/.config/starship.toml"
fi

# Ghostty
if [ -f "$DOTFILES_DIR/ghostty/config" ]; then
    create_symlink "$DOTFILES_DIR/ghostty/config" "$HOME/.config/ghostty/config"
fi

# Obsidian (vim config)
if [ -f "$DOTFILES_DIR/obsidian/.obsidian.vimrc" ]; then
    create_symlink "$DOTFILES_DIR/obsidian/.obsidian.vimrc" "$HOME/.obsidian.vimrc"
fi

# Claude Code global settings (if you want to symlink them)
if [ -f "$DOTFILES_DIR/.claude/CLAUDE.md" ]; then
    create_symlink "$DOTFILES_DIR/.claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
fi

# Scripts (optional - make them available in PATH)
if [ -d "$DOTFILES_DIR/scripts" ]; then
    create_symlink "$DOTFILES_DIR/scripts" "$HOME/.local/bin/custom-scripts"
    info "Add ~/.local/bin/custom-scripts to your PATH if not already included"
fi

echo ""
success "Symlinks created successfully!"
