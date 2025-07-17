function CleanProfileImports {
    $profilePath = $PROFILE
    $home = [Regex]::Escape($HOME)

    if (-not (Test-Path $profilePath)) {
        Write-Warning "Profile not found: $profilePath"
        return
    }

    $originalContent = Get-Content $profilePath -ErrorAction Stop
    $updatedContent = @()
    $replacementsMade = $false

    foreach ($line in $originalContent) {
        if ($line -match '^\s*Import-Module') {
            # Match quoted strings containing hardcoded home path
            if ($line -match "$home\\Documents\\PowerShell\\Modules\\[^""']+\\[^""']+\.psm1") {
                $newLine = $line -replace "$home", '$HOME'
                $updatedContent += $newLine
                $replacementsMade = $true
                continue
            }
        }
        $updatedContent += $line
    }

    if ($replacementsMade) {
        $updatedContent | Set-Content $profilePath
        Write-Host "Replaced hardcoded Import-Module paths with \$HOME in $profilePath"
    } else {
        Write-Host "No changes made. All Import-Module lines are already using \$HOME."
    }
}
