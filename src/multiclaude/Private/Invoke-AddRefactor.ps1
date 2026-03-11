function Invoke-AddRefactor {
    [CmdletBinding()]
    param()

    $repoRoot = Get-RepoRoot
    $repoName = Get-RepoName $repoRoot
    $rolesDir = Get-RolesDir
    $mux = Get-TerminalMultiplexer

    Write-Host "`n=== multiclaude: adding refactor/test Claude ===" -ForegroundColor Magenta

    $refactorDir = New-MultiClaudeWorktree $repoRoot $repoName "refactor" "claude/refactor"
    Install-RoleClaude $refactorDir (Join-Path $rolesDir "refactor.md")

    # Add as a full-height column to the right
    switch ($mux) {
        'wt' {
            $dir = Resolve-NativePath $refactorDir
            $moveFocus = "move-focus -d right ; " * 10
            $wtCmd = "wt -w multiclaude ${moveFocus}split-pane -V --title `"Refactor`" -d `"$dir`" -- claude"
            cmd /c $wtCmd
        }
        'tmux' {
            tmux split-window -h -t multiclaude -c $refactorDir
            tmux send-keys -t multiclaude 'claude' Enter
        }
    }

    Write-Host "`n=== Refactor/test Claude added ===" -ForegroundColor Green
    Write-Host "  Directory: $refactorDir"
    Write-Host "  Branch:    claude/refactor`n"
}
