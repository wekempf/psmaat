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

begin {
}

process {
    if (-not (Get-Command 'Invoke-Build' -ErrorAction SilentlyContinue)) {
        Write-Verbose 'InvokeBuild not imported, looking in ''.tools''...'
        $tools = Join-Path $PsScriptRoot '.tools'
        $invokeBuild = Get-ChildItem -Path $tools -Include InvokeBuild.psd1 -Recurse -ErrorAction SilentlyContinue |
            Select-Object -First 1
        if (-not $invokeBuild) {
            Write-Verbose 'InvokeBuild not found in ''.tools'', downloading module...'
            New-Item -Path $tools -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null
            Save-Module -Name InvokeBuild -Path $tools
            $invokeBuild = Get-ChildItem -Path $tools -Include InvokeBuild.psd1 -Recurse -ErrorAction SilentlyContinue |
                Select-Object -First 1
        }
        Import-Module $invokeBuild
    }
    Push-Location $PsScriptRoot
    try {
        Invoke-Build @PSBoundParameters
    }
    finally {
        Pop-Location
    }
}

end {
}
