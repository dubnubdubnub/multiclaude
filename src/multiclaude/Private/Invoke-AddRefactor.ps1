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

    # Insert as a full-height column between the left column and the first right column.
    # Strategy: focus the leftmost full-height pane (Feature), split it to create Refactor
    # to its right, then move-pane left to swap Refactor into the middle position.
    switch ($mux) {
        'wt' {
            $dir = Resolve-NativePath $refactorDir
            $goLeft = "move-focus -d left ; " * 10
            $wtCmd = "wt -w multiclaude " +
                "${goLeft}" +                                          # land on Operator/Coordinator
                "move-focus -d right ; " +                             # move to first full-height column
                "split-pane -V --title `"Refactor`" -d `"$dir`" -- claude ; " + # Refactor to its right
                "move-focus -d right ; " +                             # focus the new Refactor pane
                "move-pane -d left"                                    # swap Refactor left into the middle
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
