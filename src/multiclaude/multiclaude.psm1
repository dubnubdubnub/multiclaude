$script:ModuleRoot = $PSScriptRoot

$Private = @(Get-ChildItem "$PSScriptRoot/Private/*.ps1" -ErrorAction SilentlyContinue)
$Public  = @(Get-ChildItem "$PSScriptRoot/Public/*.ps1" -ErrorAction SilentlyContinue)

foreach ($file in @($Private + $Public)) { . $file.FullName }

Export-ModuleMember -Function $Public.BaseName -Alias 'multiclaude'
