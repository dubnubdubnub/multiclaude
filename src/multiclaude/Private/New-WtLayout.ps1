function New-WtLayout {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$RepoRoot,
        [Parameter(Mandatory)][hashtable[]]$Panes
    )

    # $Panes: array of @{ Title; Dir; Cmd } where Cmd is optional (defaults to shell)
    # Layout: first pane is the tab, subsequent panes are splits
    # Pattern: Operator (top-left) | Coordinator (top-right)
    #          Feature  (bot-left) | Refactor   (bot-right)

    $repoDir = Resolve-NativePath $RepoRoot

    $args = @(
        '--window', 'multiclaude',
        'new-tab', '--title', $Panes[0].Title, '-d', $repoDir
    )

    for ($i = 1; $i -lt $Panes.Count; $i++) {
        $pane = $Panes[$i]
        $dir = Resolve-NativePath $pane.Dir

        $args += ';'
        $args += 'split-pane'

        if ($pane.ContainsKey('Split')) {
            $args += $pane.Split  # -V or -H
        }
        else {
            $args += '-V'
        }

        if ($pane.ContainsKey('Size')) {
            $args += '-s'
            $args += $pane.Size
        }

        $args += '--title'
        $args += $pane.Title
        $args += '-d'
        $args += $dir

        if ($pane.ContainsKey('Cmd') -and $pane.Cmd) {
            $args += '--'
            $args += $pane.Cmd
        }
    }

    # wt's semicolons are tricky in PowerShell; use cmd /c as reliable fallback
    $wtCmd = "wt " + ($args -join ' ')
    cmd /c $wtCmd
}
