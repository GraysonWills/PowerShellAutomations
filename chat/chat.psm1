function chat {
    $apiKey = $env:OPENAI_API_KEY
    if (-not $apiKey) {
        Write-Error "OPENAI_API_KEY is not set."
        return
    }

    $basePath = Join-Path $HOME 'Documents\PowerShell\ChatSessions'
    if (-not (Test-Path $basePath)) { New-Item $basePath -ItemType Directory | Out-Null }

    # === Category selection ===
    $categories = Get-ChildItem -Path $basePath -Directory | Select-Object -ExpandProperty Name
    Write-Host "`nAvailable session categories:"
    $index = 1
    foreach ($cat in $categories) {
        Write-Host "$index. $cat"
        $index++
    }
    Write-Host "$index. Create new category"
    Write-Host "$($index + 1). Cancel"

    $catChoice = Read-Host "`nChoose category number"
    if ($catChoice -eq "$($index + 1)") { return }

    if ($catChoice -eq "$index") {
        $category = Read-Host "New category name"
        $categoryPath = Join-Path $basePath $category
        New-Item $categoryPath -ItemType Directory -Force | Out-Null
    } else {
        $category = $categories[[int]$catChoice - 1]
        $categoryPath = Join-Path $basePath $category
    }

    # === Sub-session selection ===
    $sessions = Get-ChildItem -Path $categoryPath -Filter *.json | Select-Object -ExpandProperty BaseName
    Write-Host "`nSub-sessions in [$category]:"
    $index = 1
    foreach ($s in $sessions) {
        Write-Host "$index. $s"
        $index++
    }
    Write-Host "$index. Create new sub-session"
    Write-Host "$($index + 1). Cancel"

    $sessChoice = Read-Host "`nChoose sub-session number"
    if ($sessChoice -eq "$($index + 1)") { return }

    if ($sessChoice -eq "$index") {
        $sessionName = Read-Host "Enter name for new sub-session"

        # Choose model
        Write-Host "`nChoose model:"
        Write-Host "1. gpt-4o (best and fastest)"
        Write-Host "2. gpt-4"
        Write-Host "3. gpt-3.5-turbo (fast and cheap)"
        $modelChoice = Read-Host "Enter model number"
        switch ($modelChoice) {
            1 { $model = "gpt-4o" }
            2 { $model = "gpt-4" }
            3 { $model = "gpt-3.5-turbo" }
            default { $model = "gpt-4o" }
        }

        $messages = @(@{ role = "system"; content = "You are a helpful assistant." })
        $sessionData = @{ model = $model; messages = $messages }
    } else {
        $sessionName = $sessions[[int]$sessChoice - 1]
        $sessionFile = "$sessionName.json"
        $sessionPath = Join-Path $categoryPath $sessionFile

        try {
            $sessionData = Get-Content $sessionPath -Raw | ConvertFrom-Json
            $model = $sessionData.model
            if (-not $model) { $model = "gpt-4o" }
            $messages = $sessionData.messages
        } catch {
            Write-Warning "Failed to load existing session. Starting fresh with gpt-4o."
            $model = "gpt-4o"
            $messages = @(@{ role = "system"; content = "You are a helpful assistant." })
            $sessionData = @{ model = $model; messages = $messages }
        }
    }

    $sessionFile = "$sessionName.json"
    $sessionPath = Join-Path $categoryPath $sessionFile
    Write-Host "`nChatGPT session [$category/$sessionName] using model [$model] started.`nType 'exit' or 'reset'.`n"

    while ($true) {
        $input = Read-Host "You"
        if ($input -eq 'exit') { break }
        if ($input -eq 'reset') {
            $messages = @(@{ role = "system"; content = "You are a helpful assistant." })
            $sessionData.messages = $messages
            Remove-Item $sessionPath -Force -ErrorAction SilentlyContinue
            Write-Host "Session reset.`n"
            continue
        }

        $messages += @{ role = "user"; content = $input }
        $sessionData.messages = $messages

        $body = @{
            model = $model
            messages = $messages
        } | ConvertTo-Json -Depth 3

        $headers = @{
            "Authorization" = "Bearer $apiKey"
            "Content-Type"  = "application/json"
        }

        try {
            $response = Invoke-RestMethod -Uri "https://api.openai.com/v1/chat/completions" `
                                           -Method POST -Headers $headers -Body $body
            $reply = $response.choices[0].message.content.Trim()
            Write-Host "`nChatGPT: $reply`n"
            $messages += @{ role = "assistant"; content = $reply }
            $sessionData.messages = $messages

            # Save session
            $sessionData | ConvertTo-Json -Depth 3 | Set-Content $sessionPath
        } catch {
            Write-Error "Failed to get response: $_"
            break
        }
    }
}
