#!/bin/bash
# Bootstrap script for setting up a new Mac
# Usage: ./install.sh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

info() {
    printf "${GREEN}[INFO]${NC} %s\n" "$1"
}

warn() {
    printf "${YELLOW}[WARN]${NC} %s\n" "$1"
}

error() {
    printf "${RED}[ERROR]${NC} %s\n" "$1"
}

success() {
    printf "${GREEN}✓${NC} %s\n" "$1"
}

# Get the dotfiles directory (parent of os/)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

info "Starting dotfiles setup from: $DOTFILES_DIR"
echo ""

# ============================================
# 1. Install Homebrew
# ============================================
info "Checking for Homebrew..."
if ! command -v brew &> /dev/null; then
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH for Apple Silicon Macs
    if [[ $(uname -m) == 'arm64' ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    success "Homebrew installed"
else
    success "Homebrew already installed"
fi
echo ""

# ============================================
# 2. Install packages from Brewfile
# ============================================
info "Installing packages from Brewfile..."
if [ -f "$SCRIPT_DIR/Brewfile" ]; then
    brew bundle --file="$SCRIPT_DIR/Brewfile"
    success "Packages installed"
else
    error "Brewfile not found!"
fi
echo ""

# ============================================
# 3. Install latest Ruby via rbenv
# ============================================
info "Setting up Ruby via rbenv..."
if command -v rbenv &> /dev/null; then
    eval "$(rbenv init - zsh)"
    LATEST_RUBY=$(rbenv install -l 2>/dev/null | grep -E '^\s+[0-9]+\.[0-9]+\.[0-9]+$' | tail -1 | tr -d ' ')
    if [ -n "$LATEST_RUBY" ]; then
        if ! rbenv versions | grep -q "$LATEST_RUBY"; then
            info "Installing Ruby $LATEST_RUBY..."
            rbenv install "$LATEST_RUBY"
        fi
        rbenv global "$LATEST_RUBY"
        rbenv rehash
        gem install rubocop sorbet --no-document
        success "Ruby $LATEST_RUBY set as global, rubocop + sorbet installed"
    else
        warn "Could not determine latest Ruby version, skipping"
    fi
else
    warn "rbenv not found, skipping Ruby setup"
fi
echo ""

# ============================================
# 4. Create symlinks for dotfiles
# ============================================
info "Creating symlinks for dotfiles..."
if [ -f "$SCRIPT_DIR/symlink.sh" ]; then
    bash "$SCRIPT_DIR/symlink.sh"
else
    warn "symlink.sh not found, skipping..."
fi
echo ""

# ============================================
# 6. Install TPM (Tmux Plugin Manager)
# ============================================
info "Checking for TPM..."
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    info "Installing TPM..."
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
    success "TPM installed"
else
    success "TPM already installed"
fi
echo ""

# ============================================
# 7. Setup Claude Code
# ============================================
info "Setting up Claude Code..."
if [ -f "$DOTFILES_DIR/claude/setup.sh" ]; then
    bash "$DOTFILES_DIR/claude/setup.sh"
else
    warn "claude/setup.sh not found, skipping..."
fi
echo ""

# ============================================
# 8. Install global npm packages
# ============================================
info "Installing global npm packages..."
if command -v npm &> /dev/null; then
    npm install -g @mermaid-js/mermaid-cli
    success "Global npm packages installed"
else
    warn "npm not found, skipping global packages"
fi
echo ""

# ============================================
# 9. macOS Settings (optional)
# ============================================
if [ -f "$SCRIPT_DIR/macos.sh" ]; then
    read -p "Apply macOS settings? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        info "Applying macOS settings..."
        bash "$SCRIPT_DIR/macos.sh"
    fi
    echo ""
fi

# ============================================
# 10. Setup shell
# ============================================
info "Setting up shell..."
if ! grep -q "$(which zsh)" /etc/shells; then
    echo "$(which zsh)" | sudo tee -a /etc/shells
fi
if [ "$SHELL" != "$(which zsh)" ]; then
    chsh -s "$(which zsh)"
    success "Default shell set to zsh"
else
    success "zsh is already default shell"
fi
echo ""

# ============================================
# Done!
# ============================================
echo ""
success "Setup complete!"
echo ""
info "Next steps:"
echo "  1. Restart your terminal"
echo "  2. Review and adjust any settings"
echo "  3. Run 'brew bundle cleanup' to remove unlisted packages"
echo ""
