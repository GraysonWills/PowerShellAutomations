function DeleteAutomation {
    param (
        [string]$moduleName
    )

    $modulesPath = Join-Path $HOME 'Documents\PowerShell\Modules'

    if (-not $moduleName) {
        # No parameter provided — list modules and prompt
        if (-not (Test-Path $modulesPath)) {
            Write-Warning "Modules folder does not exist: $modulesPath"
            return
        }

        $folders = Get-ChildItem -Path $modulesPath -Directory
        if ($folders.Count -eq 0) {
            Write-Host "No modules found to delete."
            return
        }

        Write-Host "`nAvailable modules:"
        for ($i = 0; $i -lt $folders.Count; $i++) {
            Write-Host "$($i + 1). $($folders[$i].Name)"
        }

        $choice = Read-Host "Enter the number of the module to delete"
        if ($choice -notmatch '^\d+$' -or $choice -lt 1 -or $choice -gt $folders.Count) {
            Write-Error "Invalid selection. Exiting."
            return
        }

        $moduleName = $folders[$choice - 1].Name
    }

    $modulePath = Join-Path $modulesPath $moduleName

    if (-not (Test-Path $modulePath)) {
        Write-Warning "Module '$moduleName' not found at: $modulePath"
        return
    }

    Write-Host "`nAre you sure you want to permanently delete the module '$moduleName'?"
    Write-Host "Path: $modulePath"
    $confirmation = Read-Host "Type 'YES' to confirm"

    if ($confirmation -eq "YES") {
        try {
            Remove-Item -Path $modulePath -Recurse -Force
            Write-Host "Module '$moduleName' deleted successfully." -ForegroundColor Green

            # Also remove Import-Module line from $PROFILE
            $profilePath = $PROFILE
            $profileContent = Get-Content $profilePath -ErrorAction SilentlyContinue

            $filteredContent = $profileContent | Where-Object {
                $_ -notmatch "(?i)Import-Module.*\\$moduleName\\$moduleName\.psm1"
            }

            if ($profileContent.Count -ne $filteredContent.Count) {
                $filteredContent | Set-Content $profilePath
                Write-Host "Removed Import-Module line from profile." -ForegroundColor Yellow
            } else {
                Write-Host "No matching Import-Module line found in profile."
            }
        } catch {
            Write-Error "Failed to delete: $_"
        }
    } else {
        Write-Host "Deletion canceled."
    }
}
