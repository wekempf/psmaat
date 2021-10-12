function Use-Module {
    param (
        [Parameter(Position=0, Mandatory=$True)]
        [string]$Name,

        [Parameter(Mandatory=$False)]
        [string]$MinimumVersion,

        [Parameter(Mandatory=$False)]
        [string]$MaximumVersion,

        [Parameter(Mandatory=$False)]
        [string]$RequiredVersion,

        [Parameter(Mandatory=$False)]
        [string]$Repository = 'PSGallery',

        [Parameter(Mandatory=$False)]
        [string]$Destination = (Join-Path $PsScriptRoot '.tools'),

        [switch]$AllowPrerelease
    )
    
    $module = Get-Module -Name $Name -ErrorAction SilentlyContinue
    if ($module -and (*TestModuleVersion $module.Version $MinimumVersion $MaximumVersion $RequiredVersion)) {
        return
    }

    $moduleRootDir = Join-Path $Destination $Name
    if (Test-Path $moduleRootDir) {
        $moduleDir = *FindModuleDir $moduleRootDir $MinimumVersion $MaximumVersion $RequiredVersion
        if ($moduleDir) {
            $psd1 = Join-Path $moduleDir "$Name.psd1"
            if (Test-Path $psd1) {
                Import-Module $psd1 -Force
                return
            }
            throw "$moduleDir does not appear to be a valid module (couldn't find $Name.psd1 file)"
        }
    }

    if (-not (Test-Path $Destination -PathType Container)) {
        New-Item -ItemType Directory $Destination -Force -ErrorAction Stop | Out-Null
    }

    Write-Host "Save-Module $Name"
    Save-Module -Name $Name -Path $Destination -MinimumVersion $MinimumVersion -MaximumVersion $MaximumVersion -RequiredVersion $RequiredVersion -Repository $Repository
    $moduleDir = *FindModuleDir $moduleRootDir $MinimumVersion $MaximumVersion $RequiredVersion
    if ($moduleDir) {
        $psd1 = Join-Path $moduleDir "$Name.psd1"
        if (Test-Path $psd1) {
            Import-Module $psd1 -Force
            return
        }
        throw "$moduleDir does not appear to be a valid module (couldn't find $Name.psd1 file)"
    }

    throw "Unable to import module $Name"
}

function *IsVersion {
    param(
        [Parameter(Position=0, Mandatory=$True)]
        [string]$Text
    )

    [ref]$version = [Version]'0.0'
    [Version]::TryParse($Text, $version)
}

function *TestModuleVersion {
    param(
        [Parameter(Position=0, Mandatory=$False)]
        $Version,

        [Parameter(Position=1, Mandatory=$False)]
        [string]$MinimumVersion,

        [Parameter(Position=2, Mandatory=$False)]
        [string]$MaximumVersion,

        [Parameter(Position=3, Mandatory=$False)]
        [string]$RequiredVersion
    )

    if ($RequiredVersion) {
        return $version -eq [Version]$RequiredVersion
    }
    elseif ($MinimumVersion -and ($version -lt [Version]$MinimumVersion)) {
        return $False
    }
    elseif ($MaximumVersion -and ($version -gt [Version]$MaximumVersion)) {
        return $False
    }
    else {
        return $True
    }
}

function *FindModuleDir {
    param(
        [Parameter(Position=0)]
        [string]$RootDir,

        [Parameter(Position=1, Mandatory=$False)]
        $Version,

        [Parameter(Position=2, Mandatory=$False)]
        [string]$MinimumVersion,

        [Parameter(Position=3, Mandatory=$False)]
        [string]$MaximumVersion,

        [Parameter(Position=4, Mandatory=$False)]
        [string]$RequiredVersion
    )
    Get-ChildItem $moduleRootDir |
        Sort-Object -Property 'Name' |
        Where-Object { (*IsVersion $_.Name) -and (*TestModuleVersion $_.Name $MinimumVersion $MaximumVersion $RequiredVersion) } |
        Select-Object -First 1
}