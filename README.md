# multiclaude

Launch multiple [Claude Code](https://docs.anthropic.com/en/docs/claude-code) instances in split terminal panes using git worktrees.

Spawns a coordinator, refactor, and feature Claude — each in its own worktree and terminal pane — coordinating via GitHub Issues.

## Layout

```
┌──────────────┬──────────────┐
│   Operator   │ Coordinator  │
│   (shell)    │  (claude)    │
├──────────────┼──────────────┤
│  Feature #1  │   Refactor   │
│  (claude)    │  (claude)    │
└──────────────┴──────────────┘
```

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

# Launch the default 4-pane layout
multiclaude

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
| `multiclaude` | Launch default layout |
| `multiclaude add-feature <name>` | Add a feature Claude pane |
| `multiclaude cleanup` | Remove all multiclaude worktrees |
