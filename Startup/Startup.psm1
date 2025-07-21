# Startup.ps1 - Opens Outlook, Slack, and Microsoft Teams

function Startup{

Write-Output "Launching apps..."

try {
    Start-Process "OUTLOOK"
    Write-Output "Outlook launched"
} catch {
    Write-Warning "Failed to launch Outlook"
}

try {
    Start-Process "slack"
    Write-Output "Slack launched"
} catch {
    Write-Warning "Failed to launch Slack"
}


}