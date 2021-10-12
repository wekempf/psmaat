function Invoke-Maat {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$False)]
        [ValidateSet('abs-churn', 'age', 'author-churn', 'authors', 'communication',
            'coupling', 'entity-churn', 'entity-effort', 'entity-ownership',
            'fragmentation', 'identity', 'main-dev', 'main-dev-by-revs',
            'refactoring-main-dev', 'revisions', 'soc', 'summary')] # 'messages', 
        [string]$Report = 'summary',

        [Parameter(Mandatory=$False)]
        [DateTime]$After,

        [Parameter(Mandatory=$False)]
        [string]$FilePath
    )
    
    begin {
        if (-not (Get-Command java -ErrorAction SilentlyContinue)) {
            throw "Java is either not installed or not on the path. Please install a Java Runtime."
        }

        $repoRoot = (Get-Location).Path
        while ($repoRoot -and -not (Test-Path (Join-Path $repoRoot '.git') -PathType Container)) {
            $repoRoot = Split-Path $repoRoot
        }
        
        if (-not $repoRoot) {
            throw 'Not in a repository'
        }

        $jar = Join-Path (Join-Path $ModuleRoot 'bin') 'code-maat.jar'
        $logFile = Join-Path $env:TEMP ((Split-Path -Path $repoRoot -Leaf) + '.log')
    }
    
    process {
        Push-Location $repoRoot
        try {
            if ($After) {
                git log --all --numstat --date=short --pretty=format:'--%h--%ad--%aN' --no-renames --after:"$('{0:yyyy-MM-dd}' -f $After)" | Out-String | Set-Content $logFile
            } else {
                git log --all --numstat --date=short --pretty=format:'--%h--%ad--%aN' --no-renames | Out-String | Set-Content $logFile
            }
        } finally {
            Pop-Location
        }
        
        $results = java -jar $jar -l $logFile -c git2 -a $Report |
            ConvertFrom-Csv |
            ForEach-Object { $_.pstypenames.Insert(0, "Maat$($Report.Replace('-', ''))"); $_ }

        if ($FilePath) {
            $results | Out-String -Width 4096 | Out-File -FilePath $FilePath
        } else {
            $results
        }
    }
}