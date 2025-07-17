function ListModules {
    $modulesPath = Join-Path $HOME 'Documents\PowerShell\Modules'

    if (-not (Test-Path $modulesPath)) {
        Write-Warning "Modules folder does not exist: $modulesPath"
        return
    }

    $moduleDirs = Get-ChildItem -Path $modulesPath -Directory

    if ($moduleDirs.Count -eq 0) {
        Write-Host "No modules found in $modulesPath"
        return
    }

    foreach ($dir in $moduleDirs) {
        $moduleName = $dir.Name
        $psm1Path = Join-Path $dir.FullName "$moduleName.psm1"

        Write-Host "`nModule: $moduleName"

        if (-not (Test-Path $psm1Path)) {
            Write-Host "  [!] No .psm1 file found at expected path: $psm1Path"
            continue
        }

        try {
            $fileContent = Get-Content $psm1Path -Raw
            $functionNames = ($fileContent | Select-String -Pattern 'function\s+([a-zA-Z0-9_]+)' -AllMatches).Matches | ForEach-Object {
                $_.Groups[1].Value
            }

            if ($functionNames.Count -eq 0) {
                Write-Host "  [ ] No functions found."
            } else {
                foreach ($name in $functionNames) {
                    Write-Host "  - $name"
                }
            }
        } catch {
            Write-Error "  Failed to read module file: $_"
        }
    }
}
