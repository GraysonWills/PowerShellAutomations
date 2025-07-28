function AskChatGPT {
    $apiKey = $env:OPENAI_API_KEY
    if (-not $apiKey) {
        Write-Error "OPENAI_API_KEY environment variable is not set. Please set it first."
        return
    }

    $model = "gpt-3.5-turbo"
    $chatEndpoint = "https://api.openai.com/v1/chat/completions"

    # Start conversation history
    $messages = @(
        @{ role = "system"; content = "You are a helpful assistant." }
    )

    Write-Host "`nChatGPT conversation started. Type 'exit' to quit.`n"

    while ($true) {
        $userInput = Read-Host "You"
        if ($userInput -eq "exit") {
            Write-Host "`nConversation ended."
            break
        }

        # Add user's message
        $messages += @{ role = "user"; content = $userInput }

        # Prepare request body
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
        } catch {
            Write-Error "Failed to connect to ChatGPT: $_"
            break
        }
    }
}
