function PowerDown {
    # PowerDown - Closes Outlook, Slack, and Microsoft Teams

    $apps = @("OUTLOOK", "slack", "ms-teams")

    foreach ($app in $apps) {
        $processes = Get-Process -Name $app -ErrorAction SilentlyContinue
        if ($processes) {
            foreach ($p in $processes) {
                try {
                    Stop-Process -Id $p.Id -Force
                    Write-Output "Closed $($p.ProcessName)"
                } catch {
                    Write-Warning "Could not close $($p.ProcessName): $_"
                }
            }
        } else {
            Write-Output "$app is not running."
        }
    }
}
