function New-WtLayout {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$RepoRoot,
        [Parameter(Mandatory)][string]$CoordinatorDir,
        [Parameter()][hashtable[]]$Columns = @()
    )

    # Layout:
    # ┌──────────────┬──────────────┬──────────────┐
    # │ Coordinator  │              │              │
    # │  (claude)    │   Refactor   │  Feature #1  │
    # ├──────────────┤   (claude)   │  (claude)    │
    # │  Operator    │              │              │
    # │  (shell)     │              │              │
    # └──────────────┴──────────────┴──────────────┘
    #
    # Build order:
    #   1. new-tab: Coordinator
    #   2. split-pane -V: each full-height column (Refactor, Feature, ...)
    #   3. move-focus back to Coordinator
    #   4. split-pane -H: Operator below Coordinator

    $coordDir = Resolve-NativePath $CoordinatorDir
    $repoDir  = Resolve-NativePath $RepoRoot

    $wtArgs = @(
        '--window', 'multiclaude', '--maximized',
        'new-tab', '--title', 'Coordinator', '-d', "`"$coordDir`"", '--', 'claude'
    )

    # Add full-height columns left to right.
    # Left column (Coordinator/Operator) gets 40% width; right columns split the remaining 60% equally.
    $leftFraction = 0.4
    $n = $Columns.Count
    for ($i = 0; $i -lt $n; $i++) {
        $col = $Columns[$i]
        $dir = Resolve-NativePath $col.Dir
        if ($i -eq 0) {
            $size = [math]::Round(1 - $leftFraction, 4)
        } else {
            $size = [math]::Round(($n - $i) / ($n - $i + 1), 4)
        }

        $wtArgs += ';'
        $wtArgs += @('split-pane', '-V', '-s', "$size", '--title', "`"$($col.Title)`"", '-d', "`"$dir`"")
        if ($col.ContainsKey('Cmd') -and $col.Cmd) {
            $wtArgs += @('--', $col.Cmd)
        }

        # wt keeps focus on the original pane after split-pane in chained commands.
        # Move focus right so the next split happens from the newly created column.
        $wtArgs += @(';', 'move-focus', '-d', 'right')
    }

    # Move focus back to Coordinator (leftmost pane)
    for ($i = 0; $i -lt $n; $i++) {
        $wtArgs += @(';', 'move-focus', '-d', 'left')
    }

    # Split Coordinator horizontally to create Operator below
    $wtArgs += @(';', 'split-pane', '-H', '--title', 'Operator', '-d', "`"$repoDir`"")

    $wtCmd = "wt " + ($wtArgs -join ' ')
    cmd /c $wtCmd
}
