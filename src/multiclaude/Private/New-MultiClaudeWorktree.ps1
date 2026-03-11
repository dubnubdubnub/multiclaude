function New-MultiClaudeWorktree {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$RepoRoot,
        [Parameter(Mandatory)][string]$RepoName,
        [Parameter(Mandatory)][string]$Role,
        [Parameter(Mandatory)][string]$Branch
    )

    $worktreeDir = Join-Path (Split-Path $RepoRoot -Parent) "$RepoName-$Role"

    if (Test-Path $worktreeDir) {
        Write-Host "  Worktree already exists: $worktreeDir" -ForegroundColor Yellow
        return $worktreeDir
    }

    $branchExists = git -C $RepoRoot branch --list $Branch 2>&1 | Out-String

    if ($Branch -eq "main") {
        # Coordinator tracks main -- allow since main is already checked out
        git -C $RepoRoot worktree add --force $worktreeDir $Branch 2>&1 | Out-Null
    }
    elseif ($branchExists.Trim()) {
        git -C $RepoRoot worktree add $worktreeDir $Branch 2>&1 | Out-Null
    }
    else {
        git -C $RepoRoot worktree add -b $Branch $worktreeDir 2>&1 | Out-Null
    }

    if (-not (Test-Path $worktreeDir)) {
        throw "Failed to create worktree at $worktreeDir"
    }

    Write-Host "  Created worktree: $worktreeDir ($Branch)" -ForegroundColor Green
    return $worktreeDir
}
