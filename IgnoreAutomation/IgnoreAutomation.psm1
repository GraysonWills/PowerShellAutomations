function IgnoreAutomation {
    $modulesPath = Join-Path $HOME 'Documents\PowerShell\Modules'
    $gitignorePath = Join-Path $modulesPath '.gitignore'

    if (-not (Test-Path $modulesPath)) {
        Write-Error "Modules directory not found: $modulesPath"
        return
    }

    $folders = Get-ChildItem -Path $modulesPath -Directory | Select-Object -ExpandProperty Name

    if ($folders.Count -eq 0) {
        Write-Host "No module folders found to ignore."
        return
    }

    Write-Host "Select the folders you want to add to .gitignore (enter numbers separated by commas):`n"

    $i = 1
    foreach ($folder in $folders) {
        Write-Host "$i. $folder"
        $i++
    }

    $selection = Read-Host "`nEnter your selection (e.g., 1,3,5) or press Enter to cancel"
    if (-not $selection) {
        Write-Host "Operation cancelled."
        return
    }

    $indices = $selection -split ',' | ForEach-Object { ($_ -as [int]) - 1 }

    $selectedFolders = $indices | ForEach-Object {
        if ($_ -ge 0 -and $_ -lt $folders.Count) {
            $folders[$_]
        }
    }

    if ($selectedFolders.Count -eq 0) {
        Write-Host "No valid selections made."
        return
    }

    if (-not (Test-Path $gitignorePath)) {
        New-Item -ItemType File -Path $gitignorePath -Force | Out-Null
        Write-Host "Created new .gitignore file."
    }

    $existingIgnores = Get-Content $gitignorePath -ErrorAction SilentlyContinue

    $newIgnores = @()
    foreach ($folder in $selectedFolders) {
        $ignoreLine = "$folder/"
        if ($existingIgnores -notcontains $ignoreLine) {
            $newIgnores += $ignoreLine
        }
    }

    if ($newIgnores.Count -gt 0) {
        Add-Content -Path $gitignorePath -Value $newIgnores
        Write-Host "Added to .gitignore:`n$($newIgnores -join "`n")"
    } else {
        Write-Host "All selected folders are already in .gitignore."
    }
}
