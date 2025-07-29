function ReorganizeChat {
    $basePath = Join-Path $HOME 'Documents\PowerShell\ChatSessions'

    if (-not (Test-Path $basePath)) {
        Write-Warning "ChatSessions folder does not exist."
        return
    }

    Write-Host "`nReorganization Options:"
    Write-Host "1. Move a sub-session to a different category"
    Write-Host "2. Rename a category"
    Write-Host "3. Rename a sub-session"
    Write-Host "4. Merge one category into another"
    Write-Host "5. Cancel"

    $choice = Read-Host "Choose an option (1-5)"
    switch ($choice) {
        1 {
            $categories = Get-ChildItem $basePath -Directory | Select-Object -ExpandProperty Name
            Write-Host "`nCategories:"
            $categories | ForEach-Object { Write-Host "- $_" }
            $fromCategory = Read-Host "Enter the category of the sub-session"
            $fromPath = Join-Path $basePath $fromCategory
            if (-not (Test-Path $fromPath)) { Write-Error "Category not found."; return }

            $sessions = Get-ChildItem $fromPath -Filter *.json | Select-Object -ExpandProperty BaseName
            if ($sessions.Count -eq 0) { Write-Warning "No sub-sessions in $fromCategory"; return }

            Write-Host "`nSub-sessions:"
            $sessions | ForEach-Object { Write-Host "- $_" }
            $sessionName = Read-Host "Enter the sub-session name to move"
            $sessionFile = "$sessionName.json"
            $sessionPath = Join-Path $fromPath $sessionFile

            if (-not (Test-Path $sessionPath)) { Write-Error "Sub-session not found."; return }

            $toCategory = Read-Host "Enter the destination category"
            $toPath = Join-Path $basePath $toCategory
            if (-not (Test-Path $toPath)) {
                $create = Read-Host "Destination category does not exist. Create it? (y/n)"
                if ($create -ne 'y') { return }
                New-Item -Path $toPath -ItemType Directory | Out-Null
            }

            Move-Item -Path $sessionPath -Destination $toPath
            Write-Host "Moved $sessionName to category $toCategory."
        }
        2 {
            $categories = Get-ChildItem $basePath -Directory | Select-Object -ExpandProperty Name
            Write-Host "`nCategories:"
            $categories | ForEach-Object { Write-Host "- $_" }
            $oldName = Read-Host "Enter the category to rename"
            $oldPath = Join-Path $basePath $oldName
            if (-not (Test-Path $oldPath)) { Write-Error "Category not found."; return }

            $newName = Read-Host "Enter new name for the category"
            $newPath = Join-Path $basePath $newName
            Rename-Item -Path $oldPath -NewName $newName
            Write-Host "Renamed category [$oldName] to [$newName]."
        }
        3 {
            $categories = Get-ChildItem $basePath -Directory | Select-Object -ExpandProperty Name
            Write-Host "`nCategories:"
            $categories | ForEach-Object { Write-Host "- $_" }
            $category = Read-Host "Enter the category of the sub-session"
            $catPath = Join-Path $basePath $category
            if (-not (Test-Path $catPath)) { Write-Error "Category not found."; return }

            $sessions = Get-ChildItem $catPath -Filter *.json | Select-Object -ExpandProperty BaseName
            Write-Host "`nSub-sessions:"
            $sessions | ForEach-Object { Write-Host "- $_" }
            $oldName = Read-Host "Enter sub-session name to rename"
            $oldPath = Join-Path $catPath "$oldName.json"
            if (-not (Test-Path $oldPath)) { Write-Error "Sub-session not found."; return }

            $newName = Read-Host "Enter new name for sub-session"
            Rename-Item -Path $oldPath -NewName "$newName.json"
            Write-Host "Renamed [$oldName] to [$newName]."
        }
        4 {
            $categories = Get-ChildItem $basePath -Directory | Select-Object -ExpandProperty Name
            Write-Host "`nCategories:"
            $categories | ForEach-Object { Write-Host "- $_" }
            $source = Read-Host "Enter category to merge"
            $dest = Read-Host "Enter destination category"
            $sourcePath = Join-Path $basePath $source
            $destPath = Join-Path $basePath $dest
            if (-not (Test-Path $sourcePath)) { Write-Error "Source not found."; return }

            if (-not (Test-Path $destPath)) {
                $makeDest = Read-Host "Destination doesn't exist. Create it? (y/n)"
                if ($makeDest -ne 'y') { return }
                New-Item -Path $destPath -ItemType Directory | Out-Null
            }

            Get-ChildItem $sourcePath -Filter *.json | ForEach-Object {
                Move-Item $_.FullName -Destination $destPath -Force
            }

            Remove-Item $sourcePath -Force -Recurse
            Write-Host "Merged [$source] into [$dest]."
        }
        5 {
            Write-Host "Cancelled."
            return
        }
        default {
            Write-Error "Invalid option selected."
        }
    }
}
