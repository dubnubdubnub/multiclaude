function Invoke-Launch {
    [CmdletBinding()]
    param()

    $repoRoot = Get-RepoRoot
    $repoName = Get-RepoName $repoRoot
    $rolesDir = Get-RolesDir
    $mux = Get-TerminalMultiplexer

    Write-Host "`n=== multiclaude: launching for $repoName ===" -ForegroundColor Magenta

    # 1. Create worktrees
    Write-Host "`nCreating worktrees..." -ForegroundColor White
    $coordDir    = New-MultiClaudeWorktree $repoRoot $repoName "coordinator" "main"
    $refactorDir = New-MultiClaudeWorktree $repoRoot $repoName "refactor" "claude/refactor"
    $featureDir  = New-MultiClaudeWorktree $repoRoot $repoName "feature-1" "claude/feature-1"

    # 2. Inject role CLAUDE.md files
    Write-Host "`nInjecting role definitions..." -ForegroundColor White
    Install-RoleClaude $coordDir   (Join-Path $rolesDir "coordinator.md")
    Install-RoleClaude $refactorDir (Join-Path $rolesDir "refactor.md")
    Install-RoleClaude $featureDir  (Join-Path $rolesDir "feature.md")

    # 3. Launch terminal layout
    Write-Host "`nLaunching terminal layout..." -ForegroundColor White

    $columns = @(
        @{ Title = 'Refactor';   Dir = $refactorDir;  Cmd = 'claude' }
        @{ Title = 'Feature #1'; Dir = $featureDir;   Cmd = 'claude' }
    )

    switch ($mux) {
        'wt'   { New-WtLayout   -RepoRoot $repoRoot -CoordinatorDir $coordDir -Columns $columns }
        'tmux' { New-TmuxLayout -RepoRoot $repoRoot -CoordinatorDir $coordDir -Columns $columns }
    }

    Write-Host "`n=== multiclaude: ready ===" -ForegroundColor Green
    Write-Host "  Coordinator: $coordDir"
    Write-Host "  Refactor:    $refactorDir"
    Write-Host "  Feature #1:  $featureDir"
    Write-Host "`nUse 'multiclaude add-feature <name>' to add more feature Claudes."
    Write-Host "Use 'multiclaude cleanup' to remove worktrees when done.`n"
}
