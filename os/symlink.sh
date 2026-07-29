#!/bin/bash
# Links config files from the dotfiles repo to their expected locations.

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

# Tmux
if [ -f "$DOTFILES_DIR/tmux/tmux.conf" ]; then
    create_symlink "$DOTFILES_DIR/tmux/tmux.conf" "$HOME/.tmux.conf"
fi
if [ -f "$DOTFILES_DIR/tmux/tmux-zen.sh" ]; then
    create_symlink "$DOTFILES_DIR/tmux/tmux-zen.sh" "$HOME/.config/tmux/tmux-zen.sh"
fi

# Zsh
if [ -f "$DOTFILES_DIR/zsh/zshenv" ]; then
    create_symlink "$DOTFILES_DIR/zsh/zshenv" "$HOME/.zshenv"
fi
if [ -f "$DOTFILES_DIR/zsh/zshrc" ]; then
    create_symlink "$DOTFILES_DIR/zsh/zshrc" "$HOME/.zshrc"
fi
if [ -f "$DOTFILES_DIR/zsh/zprofile" ]; then
    create_symlink "$DOTFILES_DIR/zsh/zprofile" "$HOME/.zprofile"
fi

# Starship
if [ -f "$DOTFILES_DIR/starship/starship.toml" ]; then
    create_symlink "$DOTFILES_DIR/starship/starship.toml" "$HOME/.config/starship.toml"
fi

# AeroSpace
if [ -f "$DOTFILES_DIR/aerospace/aerospace.toml" ]; then
    create_symlink "$DOTFILES_DIR/aerospace/aerospace.toml" "$HOME/.aerospace.toml"
fi

# Obsidian (vim config)
if [ -f "$DOTFILES_DIR/obsidian/obsidian.vimrc" ]; then
    create_symlink "$DOTFILES_DIR/obsidian/obsidian.vimrc" "$HOME/Developer/snesjhon/.obsidian.vimrc"
fi

# Yazi
if [ -d "$DOTFILES_DIR/yazi" ]; then
    create_symlink "$DOTFILES_DIR/yazi" "$HOME/.config/yazi"
fi

# Bat theme picked via auto:system in bat/config; .tmTheme files live in the separate gitlab-vim-theme repo.
if [ -f "$DOTFILES_DIR/bat/config" ]; then
    create_symlink "$DOTFILES_DIR/bat/config" "$HOME/.config/bat/config"
fi
if [ -d "$HOME/Developer/gitlab-vim-theme/bat-themes" ]; then
    mkdir -p "$HOME/.config/bat"
    create_symlink "$HOME/Developer/gitlab-vim-theme/bat-themes" "$HOME/.config/bat/themes"
    if command -v bat &> /dev/null; then
        bat cache --build
        success "Rebuilt bat theme cache"
    fi
else
    warn "gitlab-vim-theme/bat-themes not found, skipping bat theme symlink"
fi

# Lazygit
if [ -f "$DOTFILES_DIR/lazygit/config.yml" ]; then
    create_symlink "$DOTFILES_DIR/lazygit/config.yml" "$HOME/Library/Application Support/lazygit/config.yml"
fi

# Hunk
if [ -f "$DOTFILES_DIR/hunk/config.toml" ]; then
    create_symlink "$DOTFILES_DIR/hunk/config.toml" "$HOME/.config/hunk/config.toml"
fi


# Ripgrep (shared ignore globs, read via $RIPGREP_CONFIG_PATH in zshrc)
if [ -d "$DOTFILES_DIR/ripgrep" ]; then
    create_symlink "$DOTFILES_DIR/ripgrep" "$HOME/.config/ripgrep"
fi

# Ghostty (reads from Application Support on macOS, not the XDG path)
if [ -f "$DOTFILES_DIR/ghostty/config.ghostty" ]; then
    create_symlink "$DOTFILES_DIR/ghostty/config.ghostty" "$HOME/Library/Application Support/com.mitchellh.ghostty/config.ghostty"
fi

# Vim
if [ -f "$DOTFILES_DIR/vim/vimrc" ]; then
    create_symlink "$DOTFILES_DIR/vim/vimrc" "$HOME/.vimrc"
fi
if [ -f "$DOTFILES_DIR/vim/coc-settings.json" ]; then
    create_symlink "$DOTFILES_DIR/vim/coc-settings.json" "$HOME/.vim/coc-settings.json"
fi

echo ""
success "Symlinks created successfully!"
