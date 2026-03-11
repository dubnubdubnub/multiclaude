function Invoke-AddFeature {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$FeatureName
    )

    $repoRoot = Get-RepoRoot
    $repoName = Get-RepoName $repoRoot
    $rolesDir = Get-RolesDir
    $mux = Get-TerminalMultiplexer

    $safeName = $FeatureName -replace "[^a-zA-Z0-9_-]", "-"
    $role = "feature-$safeName"
    $branch = "claude/feature-$safeName"

    Write-Host "`n=== multiclaude: adding feature Claude '$safeName' ===" -ForegroundColor Magenta

    $featureDir = New-MultiClaudeWorktree $repoRoot $repoName $role $branch
    Install-RoleClaude $featureDir (Join-Path $rolesDir "feature.md")

    # Add as a full-height column to the right
    switch ($mux) {
        'wt' {
            $dir = Resolve-NativePath $featureDir
            $wtCmd = "wt -w multiclaude split-pane -V --title `"Feature: $safeName`" -d `"$dir`" -- claude"
            cmd /c $wtCmd
        }
        'tmux' {
            tmux split-window -h -t multiclaude -c $featureDir
            tmux send-keys -t multiclaude 'claude' Enter
        }
    }

    Write-Host "`n=== Feature '$safeName' added ===" -ForegroundColor Green
    Write-Host "  Directory: $featureDir"
    Write-Host "  Branch:    $branch`n"
}
