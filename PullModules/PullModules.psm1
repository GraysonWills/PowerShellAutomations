function PullModules {
    $repoPath = Join-Path $HOME 'Documents\PowerShell\Modules'

    if (-not (Test-Path $repoPath)) {
        Write-Error "Modules folder not found at $repoPath"
        return
    }

    # Ensure the folder is a git repo
    if (-not (Test-Path (Join-Path $repoPath '.git'))) {
        Write-Error "The Modules folder is not a Git repository."
        return
    }

    try {
        Push-Location $repoPath
        git pull
        Pop-Location
        Write-Host "Successfully pulled latest changes into: $repoPath"
    } catch {
        Write-Error "Git pull failed: $_"
    }
}
