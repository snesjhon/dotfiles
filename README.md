# dotfiles

![macOS](https://img.shields.io/badge/macOS-000000?style=for-the-badge&logo=apple&logoColor=white)
![Neovim](https://img.shields.io/badge/Neovim-57A143?style=for-the-badge&logo=neovim&logoColor=white)
![Tmux](https://img.shields.io/badge/Tmux-1BB91F?style=for-the-badge&logo=tmux&logoColor=white)
![Lua](https://img.shields.io/badge/Lua-2C2D72?style=for-the-badge&logo=lua&logoColor=white)
![TypeScript](https://img.shields.io/badge/TypeScript-3178C6?style=for-the-badge&logo=typescript&logoColor=white)

Personal macOS development environment. Vim keybindings everywhere, GitHub-themed light/dark, one-command bootstrap.

<p align="center">
  <img src="https://skillicons.dev/icons?i=neovim,bash,lua,ts,python,github,obsidian&theme=light" alt="Tech Stack" />
</p>

## Quick Setup

```bash
git clone https://github.com/snesjhon/dotfiles.git ~/Developer/dotfiles
cd ~/Developer/dotfiles/os
./install.sh
```

The install script handles everything: Homebrew, packages, symlinks, tmux plugins, Claude Code skills, and npm globals.

## What's Inside

```
dotfiles/
├── nvim/          AstroNvim v5 config with 20+ plugins
├── tmux/          Terminal multiplexer + session management
├── zsh/           Shell config, vim mode, custom functions
├── ghostty/       Terminal emulator (GitHub theme, ligatures)
├── hammerspoon/   macOS hotkeys & window management
├── starship/      Minimal cross-shell prompt
├── obsidian/      Vim keybindings for Obsidian
├── claude/        Custom Claude Code skills (LeetCode prep)
├── formatters/    Prettier config
└── os/            Bootstrap scripts & Brewfile
```

## Architecture

```mermaid
graph LR
    subgraph Terminal
        Ghostty --> Tmux
        Tmux --> Zsh
        Tmux --> Neovim
    end

    subgraph Shell
        Zsh --> Starship
        Zsh --> Zoxide
        Zsh --> FZF
    end

    subgraph Automation
        Hammerspoon --> Ghostty
        Hammerspoon --> Tmux
        Sesh --> Tmux
    end

    subgraph Editors
        Neovim --> AstroNvim
        Obsidian --> VimRC
    end

    style Terminal fill:#0d1117,color:#c9d1d9,stroke:#30363d
    style Shell fill:#161b22,color:#c9d1d9,stroke:#30363d
    style Automation fill:#161b22,color:#c9d1d9,stroke:#30363d
    style Editors fill:#0d1117,color:#c9d1d9,stroke:#30363d
```

## Highlights

### Neovim

AstroNvim v5 framework with Lazy.nvim. Key plugins:

| Category   | Plugin              | Purpose                              |
| ---------- | ------------------- | ------------------------------------ |
| Theme      | `github-nvim-theme` | Light/dark follows system appearance |
| Completion | `blink.cmp`         | Fast, cursor-based completion        |
| Navigation | `flash.nvim`        | Jump anywhere with `s`               |
| Markdown   | `markview.nvim`     | In-editor markdown preview           |
| Git        | `diffview.nvim`     | Side-by-side diffs                   |
| Focus      | `no-neck-pain.nvim` | Centered editing (119 cols)          |
| Fun        | `leetcode.nvim`     | Solve problems in-editor             |

### Tmux

- **Prefix:** `C-a`
- **Smart pane nav:** `C-h`/`C-l` detect vim and pass-through
- **Session management:** Sesh + FZF with GitHub-themed picker
- **Zen mode:** `prefix + z`
- **Theme:** Tokyo Night Storm via tmux-powerkit

### Hammerspoon

All hotkeys use the **Meh** modifier (`Shift+Ctrl+Alt`):

| Key               | Action                   |
| ----------------- | ------------------------ |
| `Meh+F`           | Launch Ghostty           |
| `Meh+D`           | Launch Chrome            |
| `Meh+S`           | Launch Obsidian          |
| `Meh+A`           | Launch Music             |
| `Meh+E`           | Tmux: leetcode session   |
| `Meh+R`           | Tmux: dotfiles session   |
| `Meh+N` / `Meh+.` | Window left / right half |
| `Meh+M`           | Maximize window          |

### Zsh

- Vim keybindings (`bindkey -v`)
- Starship prompt + Zoxide for fast navigation
- FZF integration with light theme
- Custom `dev` function for project navigation
- Auto-sourced functions from `zsh/functions/`

## Symlink Map

```
nvim/           → ~/.config/nvim/
tmux/tmux.conf  → ~/.tmux.conf
zsh/.zshrc      → ~/.zshrc
starship.toml   → ~/.config/starship.toml
ghostty/config  → ~/.config/ghostty/config
obsidian.vimrc  → ~/.obsidian.vimrc
```

## Brewfile Snapshot

<details>
<summary>CLI Tools</summary>

`neovim` `tmux` `fzf` `ripgrep` `tree-sitter` `gh` `node` `nvm` `python3` `sesh` `zoxide` `starship` `zsh-autocomplete` `zsh-autosuggestions` `zsh-syntax-highlighting`

</details>

<details>
<summary>GUI Apps</summary>

`ghostty` `google-chrome` `monitorcontrol` `obsidian` `hammerspoon`

</details>

<details>
<summary>Fonts</summary>

`font-symbols-only-nerd-font`

</details>

---

<p align="center">
  <img src="https://img.shields.io/badge/vim_keybindings-everywhere-57A143?style=flat-square" alt="vim everywhere" />
  <img src="https://img.shields.io/badge/theme-github_light%2Fdark-0d1117?style=flat-square" alt="github theme" />
  <img src="https://img.shields.io/badge/bootstrap-one_command-blue?style=flat-square" alt="one command" />
</p>
