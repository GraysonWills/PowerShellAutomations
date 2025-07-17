function NewAutomation {
    param (
        [Parameter(Mandatory = $true)]
        [string]$moduleName
    )

    $moduleDir = "$HOME\Documents\PowerShell\Modules\$moduleName"
    $moduleFile = "$moduleDir\$moduleName.psm1"

    # Create the module directory if it doesn't exist
    if (-not (Test-Path $moduleDir)) {
        New-Item -ItemType Directory -Path $moduleDir | Out-Null
        Write-Output "Created directory: $moduleDir"
    } else {
        Write-Output "Directory already exists: $moduleDir"
    }

    # Create the .psm1 file if it doesn't exist
    if (-not (Test-Path $moduleFile)) {
        New-Item -ItemType File -Path $moduleFile | Out-Null
        Write-Output "Created module file: $moduleFile"
    } else {
        Write-Output "Module file already exists: $moduleFile"
    }

    # Open the module file in Notepad
    Start-Process notepad.exe $moduleFile

    # Add portable Import-Module line to profile if not already present
    $relativeImport = "Import-Module `"`$HOME\Documents\PowerShell\Modules\$moduleName\$moduleName.psm1`""
    $profilePath = $PROFILE
    $profileContent = Get-Content $profilePath -ErrorAction SilentlyContinue

    if ($profileContent -notcontains $relativeImport) {
        Add-Content $profilePath "`n# Auto-import $moduleName`n$relativeImport"
        Write-Output "Added import to profile: $relativeImport"
    } else {
        Write-Output "Import already present in profile."
    }
}
