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

    # Focus the Operator pane (bottom-left) and split right to place Refactor
    # between the left column and the existing right columns.
    switch ($mux) {
        'wt' {
            $dir = Resolve-NativePath $refactorDir
            $goLeft = "move-focus -d left ; " * 10
            $goDown = "move-focus -d down ; " * 10
            $wtCmd = "wt -w multiclaude ${goLeft}${goDown}split-pane -V --title `"Refactor`" -d `"$dir`" -- claude"
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
