function CreateGitRepo {
    param (
        [string]$repoName,
        [string]$path
    )

    if (-not $repoName) {
        $repoName = Read-Host "Enter the name of the new GitHub repository"
    }

    # Prompt for folder selection if no path provided
    if (-not $path) {
        Add-Type -AssemblyName System.Windows.Forms
        $folderDialog = New-Object System.Windows.Forms.FolderBrowserDialog
        $folderDialog.Description = "Select or create the folder where the repo will be created"

        if ($folderDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            $path = $folderDialog.SelectedPath
        } else {
            Write-Host "Folder selection cancelled. Exiting."
            return
        }
    }

    if (-not (Test-Path $path)) {
        try {
            New-Item -ItemType Directory -Path $path -Force | Out-Null
            Write-Host "Created new folder: $path"
        } catch {
            Write-Error "Could not create directory: $_"
            return
        }
    } else {
        Write-Host "Using existing folder: $path"
    }

    # Use folder name as repo name if not explicitly provided
    if (-not $repoName) {
        $repoName = Split-Path $path -Leaf
    }

    Set-Location $path

    # Initialize Git if not already a repo
    if (-not (Test-Path ".git")) {
        git init | Out-Null
        Write-Host "Initialized git repository."
    } else {
        Write-Host "Git repository already exists."
    }

    # Create a README if none exists
    if (-not (Test-Path "README.md")) {
        New-Item -ItemType File -Path "README.md" -Value "# $repoName" | Out-Null
        Write-Host "Added README.md"
    }

    git add .
    git commit -m "Initial commit" | Out-Null

    # Ask for GitHub username
    $githubUser = Read-Host "Enter your GitHub username"

    # Default to HTTPS remote (can be modified for SSH)
    $remoteUrl = "https://github.com/$githubUser/$repoName.git"

    # Add remote and push
    git remote add origin $remoteUrl
    git branch -M main
    git push -u origin main

    Write-Host "Repository '$repoName' pushed to GitHub remote: $remoteUrl"
    Write-Host "Be sure to create the repository manually on GitHub if it doesn't exist yet."
}
