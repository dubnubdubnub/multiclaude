function Invoke-Launch {
    [CmdletBinding()]
    param()

    $repoRoot = Get-RepoRoot
    $repoName = Get-RepoName $repoRoot
    $rolesDir = Get-RolesDir
    $mux = Get-TerminalMultiplexer

    Write-Host "`n=== multiclaude: launching for $repoName ===" -ForegroundColor Magenta

    # 1. Coordinator runs directly from the repo root (already on main)
    $coordDir = $repoRoot
    Write-Host "`nInjecting coordinator role..." -ForegroundColor White
    Install-RoleClaude $coordDir (Join-Path $rolesDir "coordinator.md")

    # 2. Create worktrees for other roles
    Write-Host "`nCreating worktrees..." -ForegroundColor White
    $featureDir = New-MultiClaudeWorktree $repoRoot $repoName "feature-1" "claude/feature-1"

    Write-Host "`nInjecting role definitions..." -ForegroundColor White
    Install-RoleClaude $featureDir (Join-Path $rolesDir "feature.md")

    # 3. Launch terminal layout
    Write-Host "`nLaunching terminal layout..." -ForegroundColor White

    $columns = @(
        @{ Title = 'Feature #1'; Dir = $featureDir; Cmd = 'claude' }
    )

    switch ($mux) {
        'wt'   { New-WtLayout   -RepoRoot $repoRoot -CoordinatorDir $coordDir -Columns $columns }
        'tmux' { New-TmuxLayout -RepoRoot $repoRoot -CoordinatorDir $coordDir -Columns $columns }
    }

    Write-Host "`n=== multiclaude: ready ===" -ForegroundColor Green
    Write-Host "  Coordinator: $coordDir"
    Write-Host "  Feature #1:  $featureDir"
    Write-Host "`nUse 'multiclaude refactor' to add a refactor/test Claude."
    Write-Host "Use 'multiclaude add-feature <name>' to add more feature Claudes."
    Write-Host "Use 'multiclaude cleanup' to remove worktrees when done.`n"
}
