FROM node:24-bookworm

ENV DEBIAN_FRONTEND=noninteractive

# ── System packages ──────────────────────────────────────────
RUN apt-get update && apt-get install -y --no-install-recommends \
        python3 python3-pip python3-venv \
        git openssh-client jq curl sudo \
    && rm -rf /var/lib/apt/lists/*

# ── gh CLI ───────────────────────────────────────────────────
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
        | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
        > /etc/apt/sources.list.d/github-cli.list \
    && apt-get update && apt-get install -y gh \
    && rm -rf /var/lib/apt/lists/*

# ── Python dev tools (global, it's a disposable container) ───
RUN pip3 install --break-system-packages \
        pytest ruff paramiko mcp

# ── Claude Code CLI ──────────────────────────────────────────
RUN npm install -g @anthropic-ai/claude-code

# ── Workspace ────────────────────────────────────────────────
WORKDIR /workspace

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["bash"]
