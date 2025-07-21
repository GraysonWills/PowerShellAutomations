function CleanProfileImports {
    $profilePath = $PROFILE
    $modulesPath = Join-Path $HOME 'Documents\PowerShell\Modules'

    if (-not (Test-Path $profilePath)) {
        Write-Host "Creating new profile at: $profilePath"
        New-Item -ItemType File -Path $profilePath -Force | Out-Null
    }

    $profileLines = Get-Content $profilePath
    $normalizedLines = @()
    $foundModules = @{}
    $updated = $false

    # === Step 1: Normalize and remove duplicates ===
    foreach ($line in $profileLines) {
        if ($line -match 'Import-Module ".*\\Documents\\PowerShell\\Modules\\([^\\]+)\\\1.psm1"') {
            $moduleName = $matches[1]
            $correctLine = "Import-Module `"`$HOME\Documents\PowerShell\Modules\$moduleName\$moduleName.psm1`""

            if (-not $foundModules.ContainsKey($moduleName)) {
                $normalizedLines += "# Auto-import $moduleName"
                $normalizedLines += $correctLine
                $foundModules[$moduleName] = $true
            } else {
                $updated = $true
                Write-Host "Removed duplicate import for: $moduleName"
            }
        } else {
            $normalizedLines += $line
        }
    }

    # === Step 2: Check for missing modules ===
    $moduleFolders = Get-ChildItem -Path $modulesPath -Directory

    foreach ($folder in $moduleFolders) {
        $moduleName = $folder.Name
        $psm1Path = Join-Path $folder.FullName "$moduleName.psm1"

        if (-not (Test-Path $psm1Path)) {
            continue
        }

        if (-not $foundModules.ContainsKey($moduleName)) {
            $importLine = "Import-Module `"`$HOME\Documents\PowerShell\Modules\$moduleName\$moduleName.psm1`""
            $normalizedLines += "`n# Auto-import $moduleName"
            $normalizedLines += $importLine
            $foundModules[$moduleName] = $true
            Write-Host "Added missing import for: $moduleName"
            $updated = $true
        }
    }

    # === Step 3: Save updated profile ===
    if ($updated) {
        Set-Content -Path $profilePath -Value $normalizedLines
        Write-Host "`nProfile cleaned and updated."
    } else {
        Write-Host "Profile already up to date. No changes made."
    }
}
