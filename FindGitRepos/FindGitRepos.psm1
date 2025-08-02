function FindGitRepositories {
    param (
        [string]$RootPath = "$HOME",
        [string]$OutputPath = "$HOME\Documents\PowerShell\repo_list.json"
    )

    function Get-GitRepositories {
        param ($Path)

        Get-ChildItem -Path $Path -Recurse -Directory -Force -ErrorAction SilentlyContinue |
            Where-Object { Test-Path "$($_.FullName)\.git" } |
            Select-Object -ExpandProperty FullName
    }

    function Create-RepoList {
        param ($RepoPaths)

        $repoList = @()

        foreach ($repoPath in $RepoPaths) {
            Write-Host "`nFound repository at:" -ForegroundColor Cyan
            Write-Host $repoPath -ForegroundColor Yellow
            $customName = Read-Host "Enter a custom name for this repository"

            $repoList += [PSCustomObject]@{
                Name = $customName
                Path = $repoPath
            }
        }

        return $repoList
    }

    Write-Host "Scanning for Git repositories under $RootPath..." -ForegroundColor Green
    $gitRepos = Get-GitRepositories -Path $RootPath

    if (-not $gitRepos) {
        Write-Host "No Git repositories found in the specified path." -ForegroundColor Red
        return
    }

    $repoEntries = Create-RepoList -RepoPaths $gitRepos
    $repoEntries | ConvertTo-Json -Depth 2 | Out-File -Encoding UTF8 -FilePath $OutputPath

    Write-Host "`nSaved $($repoEntries.Count) repositories to $OutputPath" -ForegroundColor Green
}
