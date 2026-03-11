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

    # 2. Launch terminal layout (coordinator + operator only)
    Write-Host "`nLaunching terminal layout..." -ForegroundColor White

    switch ($mux) {
        'wt'   { New-WtLayout   -RepoRoot $repoRoot -CoordinatorDir $coordDir }
        'tmux' { New-TmuxLayout -RepoRoot $repoRoot -CoordinatorDir $coordDir }
    }

    Write-Host "`n=== multiclaude: ready ===" -ForegroundColor Green
    Write-Host "  Coordinator: $coordDir"
    Write-Host "`nUse 'multiclaude add-feature <name>' to add a feature Claude."
    Write-Host "Use 'multiclaude refactor' to add a refactor/test Claude."
    Write-Host "Use 'multiclaude cleanup' to remove worktrees when done.`n"
}
