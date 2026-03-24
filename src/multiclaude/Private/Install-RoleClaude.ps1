function Install-RoleClaude {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$WorktreeDir,
        [Parameter(Mandatory)][string]$RoleTemplate
    )

    if (-not (Test-Path $RoleTemplate)) {
        Write-Warning "Role template not found: $RoleTemplate"
        return
    }

    $claudeMdPath = Join-Path $WorktreeDir "CLAUDE.md"
    $existingContent = ""
    if (Test-Path $claudeMdPath) {
        $existingContent = Get-Content $claudeMdPath -Raw
    }

    # Skip if role instructions are already present
    if ($existingContent -match '# Role Instructions \(auto-injected by multiclaude\)') {
        Write-Host "  Role already present in: $claudeMdPath (skipped)" -ForegroundColor DarkCyan
        return
    }

    $roleContent = Get-Content $RoleTemplate -Raw
    $separator = "`n`n---`n`n# Role Instructions (auto-injected by multiclaude)`n`n"
    $combined = $existingContent + $separator + $roleContent
    Set-Content -Path $claudeMdPath -Value $combined -Encoding UTF8

    Write-Host "  Injected role into: $claudeMdPath" -ForegroundColor Cyan
}
