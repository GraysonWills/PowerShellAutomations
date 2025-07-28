function EditAutomation {
    param (
        [string]$moduleName
    )

    $modulesPath = Join-Path $HOME 'Documents\PowerShell\Modules'

    # === Step 1: Choose module if none provided ===
    if (-not $moduleName) {
        $folders = Get-ChildItem -Path $modulesPath -Directory | Where-Object {
            Test-Path (Join-Path $_.FullName "$($_.Name).psm1")
        }

        if ($folders.Count -eq 0) {
            Write-Host "No automation modules found in $modulesPath"
            return
        }

        Write-Host "`nSelect a module to modify:`n"
        for ($i = 0; $i -lt $folders.Count; $i++) {
            Write-Host "$($i + 1). $($folders[$i].Name)"
        }
        Write-Host "$($folders.Count + 1). Cancel"

        $selection = Read-Host "`nEnter selection number"
        if ($selection -as [int] -and $selection -ge 1 -and $selection -le $folders.Count) {
            $moduleName = $folders[$selection - 1].Name
        } else {
            Write-Host "Operation cancelled."
            return
        }
    }

    $modulePath = Join-Path $modulesPath $moduleName
    $psm1Path = Join-Path $modulePath "$moduleName.psm1"

    if (-not (Test-Path $psm1Path)) {
        Write-Error "Module file not found: $psm1Path"
        return
    }

    # === Step 2: Choose action ===
    Write-Host "`nChoose an action for '$moduleName':"
    Write-Host "1. Edit the .psm1 script"
    Write-Host "2. Rename the module and function"
    Write-Host "3. Cancel"

    $action = Read-Host "Enter selection number"
    switch ($action) {
        "1" {
            notepad $psm1Path
        }

        "2" {
            $newName = Read-Host "Enter new name for the module and function"
            if ([string]::IsNullOrWhiteSpace($newName)) {
                Write-Host "Invalid name. Operation cancelled."
                return
            }

            $newModulePath = Join-Path $modulesPath $newName
            $newPsm1Path = Join-Path $newModulePath "$newName.psm1"

            # Create new folder and move file
            Rename-Item -Path $modulePath -NewName $newName
            Rename-Item -Path (Join-Path $newModulePath "$moduleName.psm1") -NewName "$newName.psm1"

            # Replace function name in script
            (Get-Content $newPsm1Path) -replace "function\s+$moduleName", "function $newName" |
                Set-Content $newPsm1Path

            # Update $PROFILE
            $profilePath = $PROFILE
            $profileLines = Get-Content $profilePath
            $oldImport = "Import-Module `"`$HOME\Documents\PowerShell\Modules\$moduleName\$moduleName.psm1`""
            $newImport = "Import-Module `"`$HOME\Documents\PowerShell\Modules\$newName\$newName.psm1`""

            $updatedLines = $profileLines | ForEach-Object {
                $_ -replace [regex]::Escape($oldImport), $newImport
            }

            Set-Content $profilePath -Value $updatedLines
            Write-Host "`nRenamed '$moduleName' to '$newName' and updated profile successfully."
        }

        default {
            Write-Host "Operation cancelled."
        }
    }
}
