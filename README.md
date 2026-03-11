# multiclaude

Launch multiple [Claude Code](https://docs.anthropic.com/en/docs/claude-code) instances in split terminal panes using git worktrees.

Spawns a coordinator and feature Claude — each in its own worktree and terminal pane — coordinating via GitHub Issues. Refactor/test and additional feature Claudes can be added on demand.

## Layout

Default launch (coordinator + feature):

```
┌──────────────┬──────────────┐
│ Coordinator  │              │
│  (claude)    │  Feature #1  │
├──────────────┤  (claude)    │
│  Operator    │              │
│  (shell)     │              │
└──────────────┴──────────────┘
```

After `multiclaude refactor` and `multiclaude add-feature bom-export`:

```
┌──────────────┬──────────────┬──────────────┬──────────────┐
│ Coordinator  │              │              │              │
│  (claude)    │  Feature #1  │   Refactor   │  bom-export  │
├──────────────┤  (claude)    │   (claude)   │  (claude)    │
│  Operator    │              │              │              │
│  (shell)     │              │              │              │
└──────────────┴──────────────┴──────────────┴──────────────┘
```

Additional panes are added as full-height columns to the right.

- **Windows**: [Windows Terminal](https://github.com/microsoft/terminal) split panes
- **macOS/Linux**: tmux split panes

## Install

```powershell
Install-Module multiclaude
```

Or for development:

```powershell
git clone https://github.com/dubnubdubnub/multiclaude.git
Import-Module ./multiclaude/src/multiclaude -Force
```

## Usage

```powershell
# Navigate to any git repo
cd ~/projects/my-app

# Launch default layout (coordinator + feature)
multiclaude

# Add a refactor/test Claude
multiclaude refactor    # or: multiclaude test

# Add another feature Claude
multiclaude add-feature "bom-export"

# Clean up all worktrees when done
multiclaude cleanup
```

## Requirements

- **PowerShell** 5.1+ (Windows) or 7+ (macOS/Linux)
- **git** (for worktrees)
- **Claude Code** CLI (`claude`)
- **Windows Terminal** (Windows) or **tmux** (macOS/Linux)
- **GitHub CLI** (`gh`) — for coordination via issues/PRs

## How It Works

1. Creates git worktrees as sibling directories (e.g., `my-app-coordinator`, `my-app-refactor`)
2. Injects role-specific instructions into each worktree's `CLAUDE.md`
3. Opens a split terminal layout with Claude running in each pane

### Roles

| Role | Branch | Purpose |
|------|--------|---------|
| Coordinator | `main` | Reviews PRs, merges, creates issues |
| Refactor | `claude/refactor` | Tests, code quality, refactoring |
| Feature | `claude/feature-*` | Implements new features |

## Commands

| Command | Description |
|---------|-------------|
| `multiclaude` | Launch default layout (coordinator + feature) |
| `multiclaude refactor` | Add a refactor/test Claude pane |
| `multiclaude test` | Alias for `refactor` |
| `multiclaude add-feature <name>` | Add a feature Claude pane |
| `multiclaude cleanup` | Remove all multiclaude worktrees |
