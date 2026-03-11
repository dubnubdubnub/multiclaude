function Get-RepoRoot {
    [CmdletBinding()]
    param()

    $root = git rev-parse --show-toplevel 2>&1 | Where-Object { $_ -is [string] }
    if (-not $root) {
        throw "Not inside a git repository."
    }

    # Normalize to native path separators
    return (Resolve-Path $root).Path
}

function Get-RepoName {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$RepoRoot)

    return Split-Path $RepoRoot -Leaf
}

function Get-RolesDir {
    [CmdletBinding()]
    param()

    return Join-Path $script:ModuleRoot "roles"
}
