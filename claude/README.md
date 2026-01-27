# Claude Code Custom Skills

This directory contains custom Claude Code skills that are symlinked globally.

## Structure

```
~/Developer/dotfiles/claude/
└── skills/
    └── leet-mental/
        └── SKILL.md
```

## How It Works

1. **Skills are stored here** (`~/Developer/dotfiles/claude/skills/`)
2. **Symlinked globally** to `~/.claude/skills/` for access from any project
3. **Version controlled** in your dotfiles for backup and sync

## Available Skills

### `/leet-mental`

Generates mental model study guides for LeetCode problems with strong analogies.

**Usage:**
```bash
/leet-mental [problem description]
```

**Features:**
- Creates study guides in `/Users/snesjhon/Developer/snesjhon/ysk/study-guides/`
- Uses real-world analogies (odometer, mountain climbing, etc.)
- Leverages mermaid charts for visualizations (trees, graphs, state machines)
- Validates all mermaid charts with `mmdc` before completion
- Builds understanding from simple to complex examples
- Includes TypeScript/JavaScript solutions with analogy-based naming
- References excellent examples like Generate Parentheses and Subarray Sum

**Validation:**
After creating a mental model, validate mermaid charts:
```bash
~/Developer/dotfiles/claude/skills/leet-mental/validate-mermaid.sh mental-model.md
```

## Adding New Skills

1. Create a new skill directory:
   ```bash
   mkdir -p ~/Developer/dotfiles/claude/skills/my-skill
   ```

2. Create a `SKILL.md` file with YAML frontmatter:
   ```markdown
   ---
   name: my-skill
   description: What your skill does
   ---

   Your skill instructions here...
   ```

3. Create the global symlink:
   ```bash
   ln -sf ~/Developer/dotfiles/claude/skills/my-skill ~/.claude/skills/my-skill
   ```

## Setup on New Machine

Run this command to recreate all symlinks:
```bash
for skill in ~/Developer/dotfiles/claude/skills/*; do
  ln -sf "$skill" ~/.claude/skills/$(basename "$skill")
done
```
