function New-TmuxLayout {
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
    #   1. new-session: Coordinator (pane 0)
    #   2. split-window -h from pane 0: each full-height column
    #   3. split-window -v from pane 0: Operator below Coordinator

    $sessionName = 'multiclaude'

    # Kill existing session if present
    tmux kill-session -t $sessionName 2>$null

    # Pane 0: Coordinator
    tmux new-session -d -s $sessionName -c $CoordinatorDir
    tmux send-keys -t "${sessionName}:0.0" 'claude' Enter

    # Full-height columns, each split from the previous rightmost pane.
    # Left column (Coordinator/Operator) gets 40% width; right columns split the remaining 60% equally.
    $leftFraction = 0.4
    $n = $Columns.Count
    for ($i = 0; $i -lt $n; $i++) {
        $col = $Columns[$i]
        if ($i -eq 0) {
            $pct = [math]::Round(100 * (1 - $leftFraction))
        } else {
            $pct = [math]::Round(100 * ($n - $i) / ($n - $i + 1))
        }
        $targetPane = $i  # split from the pane that was last on the right

        tmux split-window -h -p $pct -t "${sessionName}:0.${targetPane}" -c $col.Dir
        if ($col.ContainsKey('Cmd') -and $col.Cmd) {
            $newPane = $i + 1
            tmux send-keys -t "${sessionName}:0.${newPane}" $col.Cmd Enter
        }
    }

    # Operator below Coordinator (split pane 0 vertically)
    tmux split-window -v -t "${sessionName}:0.0" -c $RepoRoot

    tmux attach-session -t $sessionName
}
