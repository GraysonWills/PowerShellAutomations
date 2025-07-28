function chat {
    param (
        [string]$sessionName
    )

    $apiKey = $env:OPENAI_API_KEY
    if (-not $apiKey) {
        Write-Error "OPENAI_API_KEY environment variable is not set. Please set it first."
        return
    }

    $model = "gpt-3.5-turbo"
    $chatEndpoint = "https://api.openai.com/v1/chat/completions"
    $basePath = Join-Path $HOME 'Documents\PowerShell\ChatSessions'

    if (-not (Test-Path $basePath)) {
        New-Item -Path $basePath -ItemType Directory | Out-Null
    }

    # === Select or create a session ===
    if (-not $sessionName) {
        $existing = Get-ChildItem -Path $basePath -Filter *.json | Select-Object -ExpandProperty BaseName

        Write-Host "`nAvailable sessions:"
        for ($i = 0; $i -lt $existing.Count; $i++) {
            Write-Host "$($i + 1). $($existing[$i])"
        }
        Write-Host "$($existing.Count + 1). Start a new session"
        Write-Host "$($existing.Count + 2). Cancel"

        $choice = Read-Host "`nChoose a session or action"
        if ($choice -as [int] -and $choice -ge 1 -and $choice -le $existing.Count) {
            $sessionName = $existing[$choice - 1]
        } elseif ($choice -eq ($existing.Count + 1).ToString()) {
            $sessionName = Read-Host "Enter a name for the new session"
        } else {
            Write-Host "Operation cancelled."
            return
        }
    }

    $sessionPath = Join-Path $basePath "$sessionName.json"
    $messages = @()

    if (Test-Path $sessionPath) {
        try {
            $messages = Get-Content $sessionPath -Raw | ConvertFrom-Json
        } catch {
            Write-Warning "Failed to load conversation history. Starting fresh."
            $messages = @()
        }
    }

    if ($messages.Count -eq 0) {
        $messages += @{ role = "system"; content = "You are a helpful assistant." }
    }

    Write-Host "`nChatGPT session [$sessionName] started. Type 'exit' to end or 'reset' to clear this session.`n"

    while ($true) {
        $userInput = Read-Host "You"
        if ($userInput -eq "exit") {
            Write-Host "`nSession [$sessionName] ended."
            break
        } elseif ($userInput -eq "reset") {
            Write-Host "Session [$sessionName] reset.`n"
            $messages = @(@{ role = "system"; content = "You are a helpful assistant." })
            Remove-Item -Path $sessionPath -Force -ErrorAction SilentlyContinue
            continue
        }

        $messages += @{ role = "user"; content = $userInput }

        $body = @{
            model = $model
            messages = $messages
        } | ConvertTo-Json -Depth 3

        $headers = @{
            "Authorization" = "Bearer $apiKey"
            "Content-Type"  = "application/json"
        }

        try {
            $response = Invoke-RestMethod -Uri $chatEndpoint -Method Post -Headers $headers -Body $body
            $reply = $response.choices[0].message.content.Trim()
            Write-Host "`nChatGPT: $reply`n"
            $messages += @{ role = "assistant"; content = $reply }

            # Save session
            $messages | ConvertTo-Json -Depth 3 | Set-Content $sessionPath
        } catch {
            Write-Error "Failed to connect to ChatGPT: $_"
            break
        }
    }
}
