param(
    [Parameter(Mandatory = $False)]
    [string]$OutputDir = (Join-Path $BuildRoot 'output'),

    [Parameter(Mandatory = $False)]
    [string]$ModuleDir
)

$moduleName = 'maat'
$tools = Join-Path $BuildRoot '.tools'
$buildNumber = 0
$gitRepo = ((git remote -v | Select-String origin | select-object -first 1) -split '\s')[1]
$percentCompliance = 80

task Clean {
    requires OutputDir

    if (Test-Path -Path $OutputDir) {
        Remove-Item "$OutputDir/*" -Recurse -Force
    }
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

task Analyze {
    requires OutputDir

    $saParams = @{
        Path    = $moduleName
        Recurse = $true
    }
    $saResults = Invoke-ScriptAnalyzer @saParams
    $saResults | ConvertTo-Json | Set-Content (Join-Path $OutputDir 'ScriptAnalysisResults.json')
}

task Build Clean, Analyze, {
    requires OutputDir

    Write-Verbose $OutputDir
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
    Copy-Item -Path $moduleName -Destination $OutputDir -Recurse -Force | Out-Null
}

# task _RunTests InstallDependencies, {
#     $pesterParams = @{
#         Script       = @{ Path = (Join-Path $BuildRoot tests); Parameters = @{ OutputDir = $OutputDir } }
#         Outputfile   = (Join-Path $OutputDir 'TestResults.xml')
#         OutputFormat = 'NUnitXml'
#         Strict       = $true
#         PassThru     = $true
#         EnableExit   = $false
#         CodeCoverage = (Get-ChildItem -Path "$OutputDir/$moduleName/*.ps1" -Recurse).FullName
#     }
#     $pesterResults = Invoke-Pester @pesterParams
#     $pesterResults | ConvertTo-Json -Depth 5 | Set-Content (Join-Path $OutputDir 'PesterResults.json')

    # $psTestReportParams = @{
    #     BuildNumber        = $buildNumber
    #     GitRepo            = $gitRepo
    #     GetRepoUrl         = $gitRepo
    #     CiUrl              = $gitRepo
    #     ShowHitCommands    = $true
    #     Compliance         = ($PercentCompliance / 100)
    #     ScriptAnalyzerFile = (Join-Path $OutputDir 'ScriptAnalysisResults.json')
    #     PesterFile         = (Join-Path $OutputDir 'PesterResults.json')
    #     OutputDir          = $OutputDir
    # }
    # . '$tools/PSTestReport/Invoke-PSTestReport.ps1' @psTestReportParams
# }

# task _ConfirmTestsPassed {
#     [xml]$xml = Get-Content (Join-Path $OutputDir 'TestResults.xml')
#     $numberFails = $xml."test-results".failures
#     assert($numberFails -eq 0)('Failed "{0}" unit tests.' -f $numberFails)

#     $json = Get-Content (Join-Path $outputDir 'PesterResults.json') | ConvertFrom-Json
#     $overallCoverage = [Math]::Floor(($json.CodeCoverage.NumberOfCommandsExecuted / $json.CodeCoverage.NumberOfCommandsAnalyzed) * 100)
#     assert($overallCoverage -gt $PercentCompliance)('A Code Coverage of "{0}" does not meet the build requirement of "{1}".' -f $overallCoverage,$PercentCompliance)
# }

#task Test Build, _RunTests, _ConfirmTestsPassed

task Install Build, {
    requires OutputDir

    if (-not $ModuleDir) {
        if ($PSVersionTable.PSEdition -eq 'Core') {
            $ModuleDir = '~/Documents/PowerShell/Modules'
        } else {
            $ModuleDir = '~/Documents/WindowsPowerShell/Modules'
        }
        if (-not (Test-Path $ModuleDir -PathType Container)) {
            New-Item $ModuleDir -ItemType Directory -Force -ErrorAction SilentlyContinue
        }
    }

    $destination = Join-Path $ModuleDir $moduleName
    if (Test-Path $destination) {
        Remove-Item $destination -Recurse -Force
    }
    $source = Join-Path (Join-Path $OutputDir $moduleName) '*'
    New-Item -ItemType Directory -Path $destination -Force | Out-Null
    Copy-Item -Path $source -Destination $destination -Recurse -Force | Out-Null
}

task . Build
