function Get-TerminalMultiplexer {
    [CmdletBinding()]
    param()

    $isWin = ($PSVersionTable.PSVersion.Major -le 5) -or $IsWindows

    if ($isWin) {
        if (Get-Command wt.exe -ErrorAction SilentlyContinue) {
            return 'wt'
        }
        throw "Windows Terminal (wt.exe) not found. Install it from the Microsoft Store or https://github.com/microsoft/terminal"
    }
    else {
        if (Get-Command tmux -ErrorAction SilentlyContinue) {
            return 'tmux'
        }
        throw "tmux not found. Install it with your package manager (e.g., 'brew install tmux' or 'apt install tmux')."
    }
}

function Resolve-NativePath {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$Path)

    $isWin = ($PSVersionTable.PSVersion.Major -le 5) -or $IsWindows
    if ($isWin) {
        return $Path.Replace("/", "\")
    }
    return $Path
}
