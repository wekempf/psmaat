[CmdletBinding()]
param (
    [Parameter(Position = 0, Mandatory = $False)]
    [ValidateSet('Clean', 'Analyze', 'Build', 'Test', 'Install')]
    $Task,

    [Parameter(Position = 1, Mandatory = $False)]
    [string]$OutputDir,

    [Parameter(Mandatory = $False)]
    [string]$ModuleDir
)

. .bootstrap.ps1
Use-Module InvokeBuild
Use-Module PSScriptAnalyzer
Use-Module Pester

try {
    Invoke-Build @PSBoundParameters
}
finally {
    Pop-Location
}
