function NewEnvironmentVariable {
    param (
        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [string]$Value
    )

    try {
        Write-Host "Setting system environment variable..." -ForegroundColor Cyan
        [System.Environment]::SetEnvironmentVariable($Name, $Value, 'Machine')

        Write-Host "Successfully set '$Name' to '$Value' as a system environment variable." -ForegroundColor Green
    } catch {
        Write-Error "Failed to set system environment variable: $_"
    }
}
