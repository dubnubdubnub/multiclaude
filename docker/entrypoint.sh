#!/bin/bash
set -e

# ── SSH keys: copy from read-only mount and fix permissions ──
if [ -d /tmp/ssh-host ]; then
    mkdir -p /root/.ssh
    cp /tmp/ssh-host/* /root/.ssh/ 2>/dev/null || true
    chmod 700 /root/.ssh
    # Fix permissions on all private keys (no .pub extension)
    for key in /root/.ssh/*; do
        if [ -f "$key" ] && [[ "$key" != *.pub ]] && [[ "$key" != */config ]] && [[ "$key" != */known_hosts* ]]; then
            chmod 600 "$key" 2>/dev/null || true
        fi
    done
    chmod 644 /root/.ssh/config 2>/dev/null || true
    chmod 644 /root/.ssh/known_hosts 2>/dev/null || true
fi

# ── Git config: copy from read-only mount ────────────────────
if [ -f /tmp/gitconfig-host ]; then
    cp /tmp/gitconfig-host /root/.gitconfig
fi

# ── gh CLI auth ──────────────────────────────────────────────
if [ -n "$GH_TOKEN" ]; then
    echo "$GH_TOKEN" | gh auth login --with-token 2>/dev/null || true
fi

# ── Claude Code credentials (copy from read-only mount) ───────
mkdir -p /root/.claude
if [ -f /tmp/claude-credentials.json ]; then
    cp /tmp/claude-credentials.json /root/.claude/.credentials.json
fi

# ── Claude Code MCP config (copy from host if mounted) ────────
if [ -f /tmp/claude-mcp.json ]; then
    cp /tmp/claude-mcp.json /root/.claude/mcp.json
fi

# ── Claude Code settings ─────────────────────────────────────
cat > /root/.claude/settings.json <<'SETEOF'
{
  "permissions": {
    "allow": [],
    "deny": []
  },
  "effortLevel": "high",
  "autoUpdatesChannel": "latest",
  "skipDangerousModePermissionPrompt": true
}
SETEOF

exec "$@"
