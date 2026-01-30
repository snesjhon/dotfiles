# macOS Setup

Automated setup for a new Mac with all your development tools and settings.

## Quick Start

On a fresh Mac, run:

```bash
git clone https://github.com/yourusername/dotfiles.git ~/Developer/dotfiles
cd ~/Developer/dotfiles/os
./install.sh
```

This will:

1. Install Homebrew (if not installed)
2. Install all packages and apps from Brewfile
3. Create symlinks for all config files
4. Setup Claude Code custom skills
5. Install global npm packages
6. Optionally apply macOS system preferences

## What's Included

### Scripts

- **install.sh** - Main bootstrap script that orchestrates everything
- **symlink.sh** - Creates symlinks from dotfiles to their expected locations
- **macos.sh** - Configures macOS system preferences for development
- **Brewfile** - Lists all Homebrew packages and applications

### Packages Installed

**CLI Tools:**

- zsh with plugins (autocomplete, autosuggestions, syntax-highlighting)
- neovim, tmux, fzf, ripgrep
- starship (prompt)
- gh (GitHub CLI)
- node, nvm

**Applications:**

- Ghostty (terminal)
- Google Chrome
- iTerm2
- MonitorControl

**Fonts:**

- Symbols Only Nerd Font

## Usage

### Full Installation

Run the main installer:

```bash
./install.sh
```

### Partial Installation

Run individual scripts:

```bash
# Only install Homebrew packages
brew bundle --file=Brewfile

# Only create symlinks
./symlink.sh

# Only apply macOS settings
./macos.sh
```

## Customization

### Add New Packages

Edit `Brewfile`:

```ruby
brew "package-name"      # CLI tool
cask "app-name"          # GUI app
tap "user/repo"          # Custom tap
```

Then install:

```bash
brew bundle --file=Brewfile
```

### Update Brewfile

To regenerate Brewfile from currently installed packages:

```bash
brew bundle dump --force
```

### Modify macOS Settings

Edit `macos.sh` to add/remove system preferences. Common settings are organized by category:

- General UI/UX
- Keyboard & Input
- Trackpad
- Finder
- Dock
- Safari
- Screenshots

## After Installation

1. **Restart your terminal** for shell changes to take effect
2. **Review configurations** in nvim, tmux, zsh, etc.
3. **Clean up unused packages**:
   ```bash
   brew bundle cleanup --file=Brewfile
   ```

## Manual Steps

Some things need to be done manually:

1. **Sign in to accounts** (iCloud, App Store, GitHub, etc.)
2. **Configure app-specific settings** not in dotfiles
3. **Set up SSH keys**:
   ```bash
   ssh-keygen -t ed25519 -C "your_email@example.com"
   ```
4. **Configure Git**:
   ```bash
   git config --global user.name "Your Name"
   git config --global user.email "your_email@example.com"
   ```

## Symlinks Created

The `symlink.sh` script creates these symlinks:

| Source                        | Target                         |
| ----------------------------- | ------------------------------ |
| `../nvim/`                    | `~/.config/nvim/`              |
| `../tmux/tmux.conf`           | `~/.tmux.conf`                 |
| `../tmux/tmux-zen.sh`         | `~/.config/tmux/tmux-zen.sh`   |
| `../zsh/.zshrc`               | `~/.zshrc`                     |
| `../zsh/.zprofile`            | `~/.zprofile`                  |
| `../starship/starship.toml`   | `~/.config/starship.toml`      |
| `../ghostty/config`           | `~/.config/ghostty/config`     |
| `../obsidian/.obsidian.vimrc` | `~/.obsidian.vimrc`            |
| `../.claude/CLAUDE.md`        | `~/.claude/CLAUDE.md`          |
| `../scripts/`                 | `~/.local/bin/custom-scripts/` |

## Troubleshooting

**Homebrew not in PATH:**

```bash
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

**Symlink conflicts:**
Existing files are backed up with timestamp:

```bash
ls ~/*.backup.*
```

**Permission issues:**
Some macOS settings require admin password. Run with sudo if needed.

## Notes

- Existing files are backed up before being replaced
- The script is idempotent - safe to run multiple times
- Some settings require logout/restart to take effect
- Homebrew is installed to `/opt/homebrew` on Apple Silicon Macs
