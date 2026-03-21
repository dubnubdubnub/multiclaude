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

    # Resolve claude command (native or sandboxed)
    $claudeCmd = 'claude'
    if ($script:UseSandbox) {
        $claudeCmd = Join-Path (Join-Path $PSScriptRoot '..\..\..\..\docker') 'claude-sandboxed.cmd'
    }

    # Add as a full-height column to the right
    switch ($mux) {
        'wt' {
            $dir = Resolve-NativePath $featureDir
            # Move focus to the rightmost pane before splitting so the new column
            # appears at the far right edge, not beside the currently focused pane.
            $moveFocus = "move-focus -d right ; " * 10
            $wtCmd = "wt -w multiclaude ${moveFocus}split-pane -V --title `"Feature: $safeName`" -d `"$dir`" -- $claudeCmd"
            cmd /c $wtCmd
        }
        'tmux' {
            tmux split-window -h -t multiclaude -c $featureDir
            tmux send-keys -t multiclaude $claudeCmd Enter
        }
    }

    Write-Host "`n=== Feature '$safeName' added ===" -ForegroundColor Green
    Write-Host "  Directory: $featureDir"
    Write-Host "  Branch:    $branch`n"
}
