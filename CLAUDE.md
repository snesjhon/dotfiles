# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository containing configuration files for a development environment setup on macOS (Darwin). The configurations are modular and separated by tool.

## Repository Structure

- **nvim/**: Neovim configuration based on AstroNvim v5
  - Uses lazy.nvim plugin manager
  - Plugin configurations in `lua/plugins/`
  - Community packs imported in `lua/community.lua`
  - Custom polish code in `lua/polish.lua` (currently disabled)

- **tmux/**: Tmux terminal multiplexer configuration
  - Uses TPM (Tmux Plugin Manager)
  - Tokyo Night theme with custom configurations
  - Session persistence via tmux-resurrect and tmux-continuum

- **zsh/**: Zsh shell configuration
  - Based on josean-dev's dotfiles structure
  - Integration with fzf, starship, and homebrew plugins

- **starship/**: Starship prompt configuration
  - Minimal setup with most language modules disabled

## Key Configuration Details

### Neovim (AstroNvim v5)

**Architecture:**

- Built on AstroNvim framework (version ^5)
- Bootstrap loader in `init.lua` handles lazy.nvim installation
- `lazy_setup.lua` configures the plugin manager and imports three main sources:
  - AstroNvim core plugins
  - Community packs (`community.lua`)
  - Custom plugins (`plugins/` directory)

**Plugin Configuration Files:**

- `plugins/mappings.lua`: Custom key mappings (buffer navigation, LSP actions, git integrations)
- `plugins/astrocore.lua`: Core configuration overrides
- `plugins/astroui.lua`: UI customizations
- `plugins/astrolsp.lua`: LSP server configurations
- `plugins/snacks.lua`: Snacks.nvim configurations (explorer, pickers, etc.)
- `plugins/github-nvim-theme.lua`: Theme configuration
- `plugins/user.lua`: Additional user plugins

**Important Notes:**

- `init.lua` should generally not be edited (contains bootstrap logic)
- `polish.lua` is currently disabled (early return statement)
- Uses Stylua for Lua formatting (config in `.stylua.toml`)
- Lazy plugin lockfile: `lazy-lock.json`

### Tmux

**Key Bindings:**

- Prefix: `C-a` (not `C-b`)
- Reload config: `prefix + r`
- Split vertical: `prefix + |`
- Split horizontal: `prefix + \`
- Navigate panes: `prefix + h/l` (vim-style)
- Navigate windows: `prefix + J/K`
- Close pane: `prefix + q`
- Copy mode: `C-\` (smart toggle that works with nvim)
- Vi-mode selection: `v` to select, `y` to yank

**Special Configuration:**

- Local config file `.tmux.local.conf` is gitignored (for private/personal settings)
- FZF integration: `C-r` passes through to shell for fzf history
- Session persistence enabled (auto-saves every 15 minutes, auto-restores on startup)
- Nvim session strategy configured for resurrect

**Plugins:**

- TPM (Tmux Plugin Manager)
- tmux-tokyo-night (theme)
- tmux-resurrect (session persistence)
- tmux-continuum (automatic session saving)

### Zsh

**Key Features:**

- Vi mode enabled (`bindkey -v`)
- Starship prompt integration
- FZF with tmux integration (`--tmux` flag)
- History configuration with deduplication

**Plugins (via Homebrew):**

- zsh-autosuggestions
- zsh-syntax-highlighting
- zsh-autocomplete

**Custom Bindings:**

- `^ ` (Ctrl+Space): Menu complete
- `Tab`: Accept autosuggestion
- `Ctrl+R`: FZF history search (tmux-integrated)
- `Up/Down`: History beginning search

**Important Paths:**

- Editor: nvim (set as EDITOR and VISUAL)
- Local binaries: `$HOME/.local/bin` in PATH
- Homebrew: `/opt/homebrew/bin`

### Starship

Minimal configuration with most language-specific modules disabled (git_status, nodejs, python, ruby, rust, buf, gcloud, nix_shell) to keep prompt clean.

## Development Workflow

### Making Changes to Neovim Configuration

1. Edit plugin configs in `nvim/lua/plugins/`
2. Lazy.nvim will auto-detect changes on next nvim launch
3. Run `:Lazy sync` in Neovim to update plugins
4. Check `lazy-lock.json` changes before committing

### Making Changes to Tmux Configuration

1. Edit `tmux/tmux.conf`
2. For immediate testing, reload in tmux: `prefix + r`
3. Private/machine-specific settings should go in `~/.tmux.local.conf` (gitignored)
4. Plugin updates: `prefix + I` (install) or `prefix + U` (update)

### Making Changes to Zsh Configuration

1. Edit `zsh/.zshrc`
2. Reload shell or run: `source ~/.zshrc`
3. History settings affect `~/.zhistory`

## Common Commands

Since this is a dotfiles repository, there are no build/test commands. Changes are tested by:

1. Symlinking or copying configs to home directory
2. Reloading the respective tool (vim, tmux, or shell)
3. Verifying functionality manually

## Notes

- Repository is actively maintained (recent commits show ongoing updates to tmux and zsh configs)
- Configurations are for macOS (Darwin) with Homebrew
- Three files currently have unstaged changes: `nvim/lazy-lock.json`, `tmux/tmux.conf`, `.zshrc`
