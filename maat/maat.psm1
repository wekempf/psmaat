# Get public and private function definition files.
$Public = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue )
$ModuleRoot = $PSScriptRoot

# Dot source the files
foreach ($import in @($Public + $Private)) {
    Write-Verbose "Importing $($import.fullname)"
    try {
        . $import.fullname
    }
    catch {
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
}

Export-ModuleMember -Function $Public.Basename

Set-Alias maat Invoke-Maat
Export-ModuleMember -Alias maat