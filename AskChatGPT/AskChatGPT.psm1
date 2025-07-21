function AskChatGPT {
    param (
        [string]$message = $(Read-Host "Ask ChatGPT")
    )

    $apiKey = $env:OPENAI_API_KEY
    if (-not $apiKey) {
        Write-Error "OPENAI_API_KEY environment variable is not set. Please set it first."
        return
    }

    $model = "gpt-3.5-turbo"
    $chatEndpoint = "https://api.openai.com/v1/chat/completions"

    $body = @{
        model = $model
        messages = @(
            @{ role = "system"; content = "You are a helpful assistant." }
            @{ role = "user"; content = $message }
        )
    } | ConvertTo-Json -Depth 3

    $headers = @{
        "Authorization" = "Bearer $apiKey"
        "Content-Type"  = "application/json"
    }

    try {
        $response = Invoke-RestMethod -Uri $chatEndpoint -Method Post -Headers $headers -Body $body
        $reply = $response.choices[0].message.content
        Write-Host "`nChatGPT: $reply"
    } catch {
        Write-Error "Failed to connect to ChatGPT: $_"
    }
}
