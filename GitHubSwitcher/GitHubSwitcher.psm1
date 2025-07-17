function GitHubPersonal {
    git config --global user.name "Grayson Wills"
    git config --global user.email "[enter here]"
    Write-Output "Switched to Personal GitHub account"
}

function GitHubBusiness {
    git config --global user.name "Grayson Wills"
    git config --global user.email "[enter here]"
    Write-Output "Switched to Business GitHub account"
}

function CheckGitHubAccount {
    $name = git config --global user.name
    $email = git config --global user.email

    if ($name -and $email) {
        Write-Output "GitHub user.name: $name"
        Write-Output "GitHub user.email: $email"
    } else {
        Write-Output "No GitHub user set globally."
    }
}
