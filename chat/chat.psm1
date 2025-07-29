function chat {
    $basePath = Join-Path $HOME 'Documents\PowerShell\ChatSessions'

    if (-not (Test-Path $basePath)) {
        New-Item -Path $basePath -ItemType Directory | Out-Null
    }

    # Category selection
    $categories = Get-ChildItem $basePath -Directory | Select-Object -ExpandProperty Name
    Write-Host "`nAvailable session categories:"
    for ($i = 0; $i -lt $categories.Count; $i++) {
        Write-Host "$($i + 1). $($categories[$i])"
    }
    Write-Host "$($categories.Count + 1). Create new category"
    Write-Host "$($categories.Count + 2). Cancel"

    $catChoice = Read-Host "`nChoose a category"
    if ($catChoice -eq "$($categories.Count + 2)") { return }

    if ($catChoice -eq "$($categories.Count + 1)") {
        $category = Read-Host "Enter name for new category"
        $categoryPath = Join-Path $basePath $category
        New-Item -Path $categoryPath -ItemType Directory | Out-Null
    } else {
        $category = $categories[[int]$catChoice - 1]
        $categoryPath = Join-Path $basePath $category
    }

    # Session selection
    $sessions = Get-ChildItem $categoryPath -Filter *.json | Select-Object -ExpandProperty BaseName
    Write-Host "`nAvailable sessions in [$category]:"
    for ($j = 0; $j -lt $sessions.Count; $j++) {
        Write-Host "$($j + 1). $($sessions[$j])"
    }
    Write-Host "$($sessions.Count + 1). Create new session"
    Write-Host "$($sessions.Count + 2). Cancel"

    $sessChoice = Read-Host "`nChoose a session"
    if ($sessChoice -eq "$($sessions.Count + 2)") { return }

    if ($sessChoice -eq "$($sessions.Count + 1)") {
        $sessionName = Read-Host "Enter name for new session"

        Write-Host "`nSelect a model:"
        Write-Host "1. gpt-4o"
        Write-Host "2. gpt-4"
        Write-Host "3. gpt-3.5-turbo"
        $modelChoice = Read-Host "Model choice"
        switch ($modelChoice) {
            '1' { $model = "gpt-4o" }
            '2' { $model = "gpt-4" }
            '3' { $model = "gpt-3.5-turbo" }
            default { $model = "gpt-4o" }
        }

        $sessionPath = Join-Path $categoryPath "$sessionName.json"
        $sessionData = @{ model = $model; messages = @() }
        $sessionData | ConvertTo-Json -Depth 3 | Set-Content $sessionPath
    } else {
        $sessionName = $sessions[[int]$sessChoice - 1]
        $sessionPath = Join-Path $categoryPath "$sessionName.json"
        $sessionData = Get-Content $sessionPath | ConvertFrom-Json
        $model = $sessionData.model
        if (-not $model) { $model = "gpt-4o" }
    }

    $apiKey = $env:OPENAI_API_KEY
    if (-not $apiKey) {
        Write-Error "OPENAI_API_KEY environment variable is not set."
        return
    }

    Write-Host "`nChatGPT session [$category/$sessionName] using model [$model] started."
    Write-Host "Type 'exit' to end, or 'reset' to clear the conversation."

    while ($true) {
        $message = Read-Host "`nYou"

        if ($message -eq "exit") { break }
        if ($message -eq "reset") {
            $sessionData.messages = @()
            Write-Host "Conversation reset."
            continue
        }

        $sessionData.messages += @{ role = "user"; content = $message }

        $jsonBody = @{
            model = $model
            messages = $sessionData.messages
        } | ConvertTo-Json -Depth 3 -Compress

        $headers = @{
            "Authorization" = "Bearer $apiKey"
            "Content-Type"  = "application/json"
        }

        try {
            $bodyBytes = [System.Text.Encoding]::UTF8.GetBytes($jsonBody)
            $response = Invoke-RestMethod -Uri "https://api.openai.com/v1/chat/completions" -Method Post -Headers $headers -Body $bodyBytes -ContentType "application/json"
            $reply = $response.choices[0].message.content
            Write-Host "`nChatGPT: $reply"

            $sessionData.messages += @{ role = "assistant"; content = $reply }
            $sessionData | ConvertTo-Json -Depth 3 | Set-Content $sessionPath
        } catch {
            Write-Error "Error contacting ChatGPT: $_"
        }
    }
}
