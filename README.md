```

$gitRepoUrl = "https://github.com/GraysonWills/PowerShellAutomations.git"
$clonePath = Join-Path $HOME "Documents\PowerShell\Modules"


if (-not (Test-Path $clonePath)) {
    New-Item -ItemType Directory -Path $clonePath -Force | Out-Null
}

Write-Host "Cloning repository from $gitRepoUrl..."
try {
    git clone $gitRepoUrl $clonePath
    Write-Host "Repository cloned to: $clonePath"
} catch {
    Write-Error "Failed to clone repository. Make sure Git is installed and the repo URL is correct."
    return
}

$profilePath = $PROFILE
if (-not (Test-Path $profilePath)) {
    New-Item -ItemType File -Path $profilePath -Force | Out-Null
}

$profileContent = Get-Content $profilePath -Raw
$moduleDirs = Get-ChildItem -Path $clonePath -Directory

foreach ($module in $moduleDirs) {
    $moduleName = $module.Name
    $psm1Path = Join-Path $module.FullName "$moduleName.psm1"

    if (-not (Test-Path $psm1Path)) {
        Write-Host "Skipping '$moduleName': No .psm1 file found"
        continue
    }

    $importLine = "Import-Module `"$HOME\Documents\PowerShell\Modules\$moduleName\$moduleName.psm1`""

    if ($profileContent -notmatch [regex]::Escape($importLine)) {
        Add-Content -Path $profilePath -Value "`n# Auto-import $moduleName`n$importLine"
        Write-Host "Added import for $moduleName"
    } else {
        Write-Host "Import for $moduleName already present"
    }
}

Write-Host "`nSetup complete. To apply the changes now, run:"
Write-Host "    . `$PROFILE`"
```
