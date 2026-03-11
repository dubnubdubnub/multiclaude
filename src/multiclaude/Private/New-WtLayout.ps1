function New-WtLayout {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$RepoRoot,
        [Parameter(Mandatory)][string]$CoordinatorDir,
        [Parameter(Mandatory)][hashtable[]]$Columns
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
        '--window', 'multiclaude',
        'new-tab', '--title', 'Coordinator', '-d', "`"$coordDir`"", '--', 'claude'
    )

    # Add full-height columns left to right.
    # First column split gets (N)/(N+1) of the space so all columns end up equal width.
    # e.g. 2 columns: first split takes 2/3, second split takes 1/2 of that = 1/3 each.
    $n = $Columns.Count
    for ($i = 0; $i -lt $n; $i++) {
        $col = $Columns[$i]
        $dir = Resolve-NativePath $col.Dir
        $size = [math]::Round(($n - $i) / ($n - $i + 1), 4)

        $wtArgs += ';'
        $wtArgs += @('split-pane', '-V', '-s', "$size", '--title', $col.Title, '-d', "`"$dir`"")
        if ($col.ContainsKey('Cmd') -and $col.Cmd) {
            $wtArgs += @('--', $col.Cmd)
        }
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
