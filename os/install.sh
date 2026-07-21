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
# 3. Create symlinks for dotfiles
# ============================================
info "Creating symlinks for dotfiles..."
if [ -f "$SCRIPT_DIR/symlink.sh" ]; then
    bash "$SCRIPT_DIR/symlink.sh"
else
    warn "symlink.sh not found, skipping..."
fi
echo ""

# ============================================
# 4. Install yazi packages (flavors/plugins pinned in yazi/package.toml)
# ============================================
info "Installing yazi packages..."
if command -v ya &> /dev/null; then
    (cd "$HOME/.config/yazi" && ya pkg install)
    success "Yazi packages installed"
else
    warn "yazi not found, skipping package install"
fi
echo ""

# ============================================
# 5. Install TPM (Tmux Plugin Manager)
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
# 6. Install global npm packages
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
# 7. Setup shell
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
