@{
    RootModule        = 'multiclaude.psm1'
    ModuleVersion     = '0.1.0'
    GUID              = 'ebed38f2-246f-423a-af44-25cb307c2cc6'
    Author            = 'dubnubdubnub'
    CompanyName       = 'dubnubdubnub'
    Copyright         = '(c) dubnubdubnub. All rights reserved.'
    Description       = 'Launch multiple Claude Code instances in split terminal panes using git worktrees.'
    PowerShellVersion = '5.1'
    FunctionsToExport = @('Invoke-MultiClaude')
    AliasesToExport   = @('multiclaude')
    PrivateData       = @{
        PSData = @{
            Tags       = @('claude', 'claude-code', 'git', 'worktree', 'terminal', 'tmux', 'windows-terminal')
            ProjectUri = 'https://github.com/dubnubdubnub/multiclaude'
        }
    }
}
