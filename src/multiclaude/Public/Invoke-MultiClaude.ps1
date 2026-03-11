function Invoke-MultiClaude {
    <#
    .SYNOPSIS
        Launch multiple Claude Code instances on a git repo using split terminal
        panes and git worktrees.

    .DESCRIPTION
        Spawns a coordinator, refactor, and feature Claude in separate worktrees,
        each in its own terminal pane. On Windows, uses Windows Terminal; on
        macOS/Linux, uses tmux. Instances coordinate via GitHub Issues.

    .PARAMETER Command
        The subcommand to run: launch (default), add-feature, cleanup.

    .PARAMETER Name
        Name for the feature (used with add-feature command).

    .EXAMPLE
        Invoke-MultiClaude
        # Launch default layout (coordinator + refactor + feature)

    .EXAMPLE
        multiclaude add-feature "bom-export"
        # Add a new feature Claude pane

    .EXAMPLE
        multiclaude cleanup
        # Remove all multiclaude worktrees for this repo
    #>
    [CmdletBinding()]
    [Alias('multiclaude')]
    param(
        [Parameter(Position = 0)]
        [string]$Command = "launch",

        [Parameter(Position = 1)]
        [string]$Name = ""
    )

    Set-StrictMode -Version Latest

    switch ($Command.ToLower()) {
        "launch"       { Invoke-Launch }
        ""             { Invoke-Launch }
        "add-feature"  {
            if (-not $Name) {
                throw "Usage: multiclaude add-feature <name>"
            }
            Invoke-AddFeature -FeatureName $Name
        }
        "cleanup"      { Invoke-Cleanup }
        default {
            Write-Host "Usage:" -ForegroundColor White
            Write-Host "  multiclaude                          Launch coordinator + refactor + feature"
            Write-Host "  multiclaude add-feature <name>       Add a new feature Claude pane"
            Write-Host "  multiclaude cleanup                  Remove all multiclaude worktrees"
            throw "Unknown command: $Command"
        }
    }
}
