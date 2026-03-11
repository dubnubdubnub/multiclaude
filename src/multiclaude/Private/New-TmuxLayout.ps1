function New-TmuxLayout {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$RepoRoot,
        [Parameter(Mandatory)][hashtable[]]$Panes
    )

    $sessionName = 'multiclaude'

    # Kill existing session if present
    tmux kill-session -t $sessionName 2>$null

    # First pane: Operator (top-left) — just a shell in the repo root
    tmux new-session -d -s $sessionName -c $RepoRoot

    # Coordinator (top-right): split horizontally from pane 0
    if ($Panes.Count -gt 1) {
        $coordDir = $Panes[1].Dir
        tmux split-window -h -t "${sessionName}:0.0" -c $coordDir
        if ($Panes[1].ContainsKey('Cmd') -and $Panes[1].Cmd) {
            tmux send-keys -t "${sessionName}:0.1" $Panes[1].Cmd Enter
        }
    }

    # Refactor (bottom-right): split vertically from coordinator pane
    if ($Panes.Count -gt 2) {
        $refactorDir = $Panes[2].Dir
        tmux split-window -v -t "${sessionName}:0.1" -c $refactorDir
        if ($Panes[2].ContainsKey('Cmd') -and $Panes[2].Cmd) {
            tmux send-keys -t "${sessionName}:0.2" $Panes[2].Cmd Enter
        }
    }

    # Feature (bottom-left): split vertically from operator pane
    if ($Panes.Count -gt 3) {
        $featureDir = $Panes[3].Dir
        tmux split-window -v -t "${sessionName}:0.0" -c $featureDir
        if ($Panes[3].ContainsKey('Cmd') -and $Panes[3].Cmd) {
            tmux send-keys -t "${sessionName}:0.3" $Panes[3].Cmd Enter
        }
    }

    # Any additional panes beyond 4
    for ($i = 4; $i -lt $Panes.Count; $i++) {
        $pane = $Panes[$i]
        # Split from the last pane
        tmux split-window -v -t $sessionName -c $pane.Dir
        if ($pane.ContainsKey('Cmd') -and $pane.Cmd) {
            tmux send-keys -t $sessionName $pane.Cmd Enter
        }
    }

    tmux attach-session -t $sessionName
}
