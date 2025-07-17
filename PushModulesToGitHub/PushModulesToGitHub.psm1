function PushModulesToGitHub {
    param (
        [string]$commitMessage
    )

    $modulesPath = Join-Path $HOME 'Documents\PowerShell\Modules'

    if (-not (Test-Path $modulesPath)) {
        Write-Error "Modules path does not exist: $modulesPath"
        return
    }

    Set-Location $modulesPath

    # Initialize Git repo if needed
    if (-not (Test-Path ".git")) {
        git init
        Write-Host "Initialized new git repository in: $modulesPath"
    }

    # Default commit message if none provided
    if (-not $commitMessage) {
        $commitMessage = Read-Host "Enter a commit message (or press Enter for default)"
        if (-not $commitMessage) {
            $commitMessage = "Update PowerShell modules"
        }
    }

    try {
        git add .
        git commit -m "$commitMessage"
    } catch {
        Write-Host "Nothing to commit or repository is up to date."
    }

    # Check for a remote
    $remote = git remote get-url origin 2>$null
    if (-not $remote) {
        $remoteUrl = Read-Host "No remote found. Enter your GitHub remote URL (e.g., https://github.com/username/repo.git)"
        git remote add origin $remoteUrl
        git branch -M main
    }

    git push -u origin master
    Write-Host "Pushed PowerShell modules to GitHub remote."
}
