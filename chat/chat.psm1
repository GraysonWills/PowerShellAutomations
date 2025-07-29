function chat {
    $basePath = Join-Path $HOME 'Documents\PowerShell\ChatSessions'
    if (-not (Test-Path $basePath)) { New-Item -Path $basePath -ItemType Directory | Out-Null }

    $categories = Get-ChildItem $basePath -Directory | Select -Expand BaseName
    Write-Host "`nAvailable session categories:"
    for ($i = 0; $i -lt $categories.Count; $i++) { Write-Host "$($i+1). $($categories[$i])" }
    Write-Host "$($categories.Count+1). Create new category"; Write-Host "$($categories.Count+2). Cancel"
    $choice = Read-Host "`nChoose a category"; if ($choice -eq "$($categories.Count+2)") { return }

    if ($choice -eq "$($categories.Count+1)") {
        $category = Read-Host "Enter new category name"
        $categoryPath = Join-Path $basePath $category; New-Item -Path $categoryPath -ItemType Directory | Out-Null
    } else {
        $index = [int]$choice -1; if ($index -lt 0 -or $index -ge $categories.Count) { Write-Error "Invalid"; return }
        $category = $categories[$index]; $categoryPath = Join-Path $basePath $category
    }

    $sessions = Get-ChildItem $categoryPath -Filter *.json | Select -Expand BaseName
    Write-Host "`nAvailable sessions in [$category]:"
    for ($j = 0; $j -lt $sessions.Count; $j++) { Write-Host "$($j+1). $($sessions[$j])" }
    Write-Host "$($sessions.Count+1). Create new session"; Write-Host "$($sessions.Count+2). Cancel"
    $sessChoice = Read-Host "`nChoose session"; if ($sessChoice -eq "$($sessions.Count+2)") { return }

    if ($sessChoice -eq "$($sessions.Count+1)") {
        $sessionName = Read-Host "Enter session name"
        # Model selection menu
        $models = @("gpt-4.1","gpt-4.1-mini","gpt-4.1-nano","gpt-4o","gpt-4o-mini",
                     "gpt-3.5-turbo","gpt-3.5-turbo-16k","gpt-4","gpt-4-32k",
                     "o1","o1-mini","o1-pro","o3-mini","o3","o3-pro","o4-mini")
        Write-Host "`nSelect model:"; for ($m=0; $m -lt $models.Count; $m++) { Write-Host "$($m+1). $($models[$m])" }
        $mChoice = Read-Host "Model choice (default 1)"; $model = $models[(if ($mChoice -as [int] -and $mChoice -ge 1 -and $mChoice -le $models.Count) { [int]$mChoice-1 } else { 0 })]

        $sessionPath = Join-Path $categoryPath "$sessionName.json"
        $sessionData = @{ model=$model; messages=@() }
        $sessionData | ConvertTo-Json -Depth 3 | Set-Content $sessionPath
    } else {
        $i2 = [int]$sessChoice-1; if ($i2 -lt 0 -or $i2 -ge $sessions.Count) { Write-Error "Invalid"; return }
        $sessionName = $sessions[$i2]; $sessionPath = Join-Path $categoryPath "$sessionName.json"
        $sessionData = Get-Content $sessionPath | ConvertFrom-Json
        $model = $sessionData.model
        if (-not $model) { $model = "gpt-4.1" }
    }

    $apiKey = $env:OPENAI_API_KEY; if (-not $apiKey) { Write-Error "OPENAI_API_KEY not set."; return }

    Write-Host "`nSession [$category/$sessionName] using model [$model]"
    while ($true) {
        $msg = Read-Host "`nYou (or type 'exit'/'reset')"
        if ($msg -eq 'exit') { break }
        if ($msg -eq 'reset') { $sessionData.messages=@(); Write-Host "Reset."; continue }

        $sessionData.messages += @{role="user";content=$msg}
        $json = @{ model=$model; messages=$sessionData.messages } | ConvertTo-Json -Depth 3 -Compress
        $bodyBytes = [System.Text.Encoding]::UTF8.GetBytes($json)
        $headers = @{Authorization="Bearer $apiKey"; "Content-Type"="application/json"}

        try {
            $resp = Invoke-RestMethod -Uri "https://api.openai.com/v1/chat/completions" -Method Post -Headers $headers -Body $bodyBytes -ContentType "application/json"
            $reply = $resp.choices[0].message.content
            Write-Host "`nChatGPT: $reply"
            $sessionData.messages += @{role="assistant";content=$reply}
            $sessionData | ConvertTo-Json -Depth 3 | Set-Content $sessionPath
        } catch {
            Write-Error "API error: $_"
            break
        }
    }
}
