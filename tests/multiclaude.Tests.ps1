BeforeAll {
    $modulePath = Join-Path (Join-Path (Join-Path $PSScriptRoot '..') 'src') 'multiclaude'
    Import-Module $modulePath -Force
}

Describe 'Module loading' {
    It 'exports Invoke-MultiClaude function' {
        $cmd = Get-Command Invoke-MultiClaude -ErrorAction SilentlyContinue
        $cmd | Should -Not -BeNullOrEmpty
        $cmd.CommandType | Should -Be 'Function'
    }

    It 'exports multiclaude alias' {
        $alias = Get-Alias multiclaude -ErrorAction SilentlyContinue
        $alias | Should -Not -BeNullOrEmpty
        $alias.ReferencedCommand.Name | Should -Be 'Invoke-MultiClaude'
    }

    It 'has a valid module manifest' {
        $manifestPath = Join-Path (Join-Path (Join-Path $PSScriptRoot '..') 'src') 'multiclaude' | Join-Path -ChildPath 'multiclaude.psd1'
        $manifest = Test-ModuleManifest $manifestPath -ErrorAction Stop
        $manifest.Name | Should -Be 'multiclaude'
        $manifest.Version | Should -Not -BeNullOrEmpty
    }
}

Describe 'Invoke-MultiClaude' {
    It 'has Command and Name parameters' {
        $params = (Get-Command Invoke-MultiClaude).Parameters
        $params.ContainsKey('Command') | Should -BeTrue
        $params.ContainsKey('Name') | Should -BeTrue
    }

    It 'throws on unknown command' {
        { Invoke-MultiClaude -Command 'bogus' } | Should -Throw '*Unknown command*'
    }

    It 'throws on add-feature without name' {
        { Invoke-MultiClaude -Command 'add-feature' } | Should -Throw '*Usage*'
    }
}

Describe 'Get-TerminalMultiplexer' {
    It 'returns wt or tmux' {
        # This is an internal function, access via module scope
        $mux = & (Get-Module multiclaude) { Get-TerminalMultiplexer }
        $mux | Should -BeIn @('wt', 'tmux')
    }
}

Describe 'Get-RepoRoot' {
    It 'returns a path when inside a git repo' {
        Push-Location (Join-Path $PSScriptRoot '..')
        try {
            $root = & (Get-Module multiclaude) { Get-RepoRoot }
            $root | Should -Not -BeNullOrEmpty
            Test-Path $root | Should -BeTrue
        }
        finally {
            Pop-Location
        }
    }

    It 'throws when not in a git repo' {
        $tempDir = Join-Path ([IO.Path]::GetTempPath()) "multiclaude-test-$(Get-Random)"
        New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
        Push-Location $tempDir
        try {
            { & (Get-Module multiclaude) { Get-RepoRoot } } | Should -Throw '*Not inside a git repository*'
        }
        finally {
            Pop-Location
            Remove-Item $tempDir -Recurse -Force
        }
    }
}

Describe 'Roles directory' {
    It 'contains coordinator, feature, and refactor role files' {
        $rolesDir = & (Get-Module multiclaude) { Get-RolesDir }
        Test-Path (Join-Path $rolesDir 'coordinator.md') | Should -BeTrue
        Test-Path (Join-Path $rolesDir 'feature.md') | Should -BeTrue
        Test-Path (Join-Path $rolesDir 'refactor.md') | Should -BeTrue
    }
}
