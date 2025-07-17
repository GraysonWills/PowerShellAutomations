function EditAutomation {
    param (
        [Parameter(Mandatory = $true)]
        [string]$moduleName
    )

    $modulePath = "$HOME\Documents\PowerShell\Modules\$moduleName\$moduleName.psm1"

    if (Test-Path $modulePath) {
        Start-Process notepad.exe $modulePath
        Write-Output "Opened: $modulePath"
    } else {
        Write-Warning "Module '$moduleName' not found at expected location: $modulePath"
    }
}
