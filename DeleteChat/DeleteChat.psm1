function DeleteChatSession {
    $basePath = Join-Path $HOME 'Documents\PowerShell\ChatSessions'

    if (-not (Test-Path $basePath)) {
        Write-Warning "No chat session directory found."
        return
    }

    # List session categories
    $categories = Get-ChildItem -Path $basePath -Directory | Select-Object -ExpandProperty Name
    if ($categories.Count -eq 0) {
        Write-Warning "No session categories exist."
        return
    }

    Write-Host "`nAvailable session categories:"
    $i = 1
    foreach ($cat in $categories) {
        Write-Host "$i. $cat"
        $i++
    }
    Write-Host "$i. Cancel"
    $catChoice = Read-Host "`nChoose a category number"
    if ($catChoice -eq $i) { return }

    $category = $categories[[int]$catChoice - 1]
    $categoryPath = Join-Path $basePath $category

    # List sub-sessions
    $sessions = Get-ChildItem -Path $categoryPath -Filter *.json | Select-Object -ExpandProperty BaseName
    if ($sessions.Count -eq 0) {
        $confirmDelete = Read-Host "No sub-sessions found. Delete entire category [$category]? (y/n)"
        if ($confirmDelete -eq 'y') {
            Remove-Item -Path $categoryPath -Recurse -Force
            Write-Host "Deleted category [$category]."
        } else {
            Write-Host "Operation cancelled."
        }
        return
    }

    Write-Host "`nSub-sessions in [$category]:"
    $j = 1
    foreach ($s in $sessions) {
        Write-Host "$j. $s"
        $j++
    }
    Write-Host "$j. Delete entire category"
    Write-Host "$($j + 1). Cancel"

    $sessChoice = Read-Host "`nChoose an option"
    if ($sessChoice -eq "$($j + 1)") { return }

    if ($sessChoice -eq "$j") {
        $confirm = Read-Host "Are you sure you want to delete the entire category [$category]? (y/n)"
        if ($confirm -eq 'y') {
            Remove-Item -Path $categoryPath -Recurse -Force
            Write-Host "Deleted category [$category]."
        } else {
            Write-Host "Operation cancelled."
        }
        return
    }

    $sessionName = $sessions[[int]$sessChoice - 1]
    $sessionPath = Join-Path $categoryPath "$sessionName.json"

    $confirmSession = Read-Host "Delete session [$sessionName] in category [$category]? (y/n)"
    if ($confirmSession -eq 'y') {
        Remove-Item -Path $sessionPath -Force
        Write-Host "Deleted session [$sessionName] in category [$category]."
    } else {
        Write-Host "Operation cancelled."
    }
}
