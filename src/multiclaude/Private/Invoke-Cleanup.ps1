function Invoke-Cleanup {
    [CmdletBinding()]
    param()

    $repoRoot = Get-RepoRoot
    $repoName = Get-RepoName $repoRoot
    $parentDir = Split-Path $repoRoot -Parent

    Write-Host "`n=== multiclaude: cleaning up worktrees for $repoName ===" -ForegroundColor Magenta

    $worktrees = git -C $repoRoot worktree list --porcelain 2>&1
    $removedCount = 0

    foreach ($line in $worktrees) {
        if ($line -match "^worktree (.+)$") {
            $wtPath = $Matches[1]
            # Normalize for comparison
            $wtPathNorm = $wtPath.Replace("/", [IO.Path]::DirectorySeparatorChar).Replace("\", [IO.Path]::DirectorySeparatorChar)
            $pattern = Join-Path $parentDir "$repoName-*"

            if ($wtPathNorm -ne $repoRoot -and $wtPathNorm -like $pattern) {
                Write-Host "  Removing: $wtPath" -ForegroundColor Yellow
                git -C $repoRoot worktree remove $wtPath --force 2>&1 | Out-Null
                $removedCount++
            }
        }
    }

    if ($removedCount -eq 0) {
        Write-Host "  No multiclaude worktrees found." -ForegroundColor Gray
    }
    else {
        Write-Host "`nRemoved $removedCount worktree(s)." -ForegroundColor Green
    }

    git -C $repoRoot worktree prune 2>&1 | Out-Null
    Write-Host "=== cleanup done ===`n" -ForegroundColor Green
}
