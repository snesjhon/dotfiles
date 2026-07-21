# macOS Setup

Automated setup for a new Mac with all your development tools and settings.

## Quick Start

On a fresh Mac, run:

```bash
git clone https://github.com/snesjhon/dotfiles.git ~/Developer/dotfiles
cd ~/Developer/dotfiles/os
./install.sh
```

This will:

1. Install Homebrew (if not installed)
2. Install all packages and apps from Brewfile
3. Create symlinks for all config files
4. Install yazi packages (flavors/plugins pinned in yazi/package.toml)
5. Install TPM (Tmux Plugin Manager)
6. Install global npm packages
7. Set zsh as the default shell

## What's Included

### Scripts

- **install.sh** - Main bootstrap script that orchestrates everything
- **symlink.sh** - Creates symlinks from dotfiles to their expected locations
- **Brewfile** - Lists all Homebrew packages and applications

### Packages Installed

**CLI Tools:**

- zsh with plugins (autocomplete, autosuggestions, syntax-highlighting)
- vim, tmux, fzf, ripgrep, bat
- starship (prompt)
- gh (GitHub CLI)
- node, nvm
- lazygit

**Applications:**

- Ghostty (terminal)
- Google Chrome
- MonitorControl
- Obsidian
- AeroSpace

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

## After Installation

1. **Restart your terminal** for shell changes to take effect
2. **Review configurations** in vim, tmux, zsh, etc.
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
5. **Clone `gitlab-vim-theme`** to `~/Developer/gitlab-vim-theme` — vim's colorscheme
   (`vim/plugins.vim`) and bat's theme (`bat-themes/`) both source from it as a
   local sibling checkout rather than vendoring the colors in this repo:
   ```bash
   git clone https://github.com/snesjhon/gitlab-vim-theme ~/Developer/gitlab-vim-theme
   ```

## Symlinks Created

The `symlink.sh` script creates these symlinks:

| Source                        | Target                                    |
| ------------------------------ | ------------------------------------------ |
| `../tmux/tmux.conf`             | `~/.tmux.conf`                             |
| `../tmux/tmux-zen.sh`           | `~/.config/tmux/tmux-zen.sh`               |
| `../zsh/zshenv`                 | `~/.zshenv`                                |
| `../zsh/zshrc`                  | `~/.zshrc`                                 |
| `../zsh/zprofile`               | `~/.zprofile`                              |
| `../starship/starship.toml`     | `~/.config/starship.toml`                  |
| `../aerospace/aerospace.toml`   | `~/.aerospace.toml`                        |
| `../obsidian/obsidian.vimrc`    | `~/Developer/snesjhon/.obsidian.vimrc`     |
| `../yazi/`                      | `~/.config/yazi`                           |
| `~/Developer/gitlab-vim-theme/bat-themes` | `~/.config/bat/themes`            |
| `../ripgrep/`                   | `~/.config/ripgrep`                        |
| `../ghostty/config.ghostty`     | `~/Library/Application Support/com.mitchellh.ghostty/config.ghostty` |
| `../vim/vimrc`                  | `~/.vimrc`                                 |
| `../vim/coc-settings.json`      | `~/.vim/coc-settings.json`                 |

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

## Notes

- Existing files are backed up before being replaced
- The script is idempotent - safe to run multiple times
- Homebrew is installed to `/opt/homebrew` on Apple Silicon Macs
