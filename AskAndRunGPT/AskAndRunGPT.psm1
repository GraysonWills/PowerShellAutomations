function AskAndRunGPT {
    param (
        [string]$message = $(Read-Host "Ask ChatGPT to write PowerShell")
    )

    $apiKey = $env:OPENAI_API_KEY
    if (-not $apiKey) {
        Write-Error "OPENAI_API_KEY environment variable is not set."
        return
    }

    $model = "gpt-4o"
    $endpoint = "https://api.openai.com/v1/chat/completions"

    # Force ChatGPT to ONLY respond with raw PowerShell code
    $engineeredPrompt = "Respond ONLY with valid executable PowerShell code. Do not include explanation, markdown, comments, or any formatting. $message"

    $body = @{
        model = $model
        messages = @(
            @{ role = "system"; content = "You are a PowerShell code generator." }
            @{ role = "user"; content = $engineeredPrompt }
        )
    } | ConvertTo-Json -Depth 3 -Compress

    $headers = @{
        "Authorization" = "Bearer $apiKey"
        "Content-Type"  = "application/json"
    }

    try {
        $bodyBytes = [System.Text.Encoding]::UTF8.GetBytes($body)
        $response = Invoke-RestMethod -Uri $endpoint -Method Post -Headers $headers -Body $bodyBytes -ContentType "application/json"
        $powershellCode = $response.choices[0].message.content.Trim()

        if (-not $powershellCode) {
            Write-Host "No code returned."
            return
        }

        # Save to temporary PS1 file
        $tempPath = [System.IO.Path]::GetTempFileName() -replace '\.tmp$', '.ps1'
        Set-Content -Path $tempPath -Value $powershellCode -Encoding UTF8

        Write-Host "`nRunning PowerShell code from ChatGPT..." -ForegroundColor Cyan
        Write-Host $powershellCode -ForegroundColor Yellow

        # Execute it
        & powershell -NoProfile -ExecutionPolicy Bypass -File $tempPath

        # Clean up
        Remove-Item $tempPath -Force
    }
    catch {
        Write-Error "Failed to get or run PowerShell code from ChatGPT: $_"
    }
}
