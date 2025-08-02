# =============================
#      Daily Briefing Script
# =============================

# -------- System Status --------
function Get-SystemStatus {
    $cpu = (Get-CimInstance Win32_Processor | Measure-Object -Property LoadPercentage -Average).Average
    $battery = Get-CimInstance Win32_Battery | Select-Object -ExpandProperty EstimatedChargeRemaining -ErrorAction SilentlyContinue
    $disk = Get-PSDrive -PSProvider FileSystem | Where-Object {$_.Used -gt 0} | 
            Select-Object Name, @{Name="Free(GB)";Expression={[math]::Round($_.Free/1GB,2)}}
    
    [PSCustomObject]@{
        CPU_Load_Percent = $cpu
        Battery_Percent = $battery
        Disks = $disk
    }
}

# -------- Weather Forecast --------
function Get-Weather {
    param (
        [string]$City = "Detroit",
        [string]$ApiKey = "YOUR_OPENWEATHER_API_KEY"
    )

    $url = "https://api.openweathermap.org/data/2.5/weather?q=$City&appid=$ApiKey&units=imperial"
    try {
        $response = Invoke-RestMethod -Uri $url -ErrorAction Stop
        [PSCustomObject]@{
            City      = $response.name
            Weather   = $response.weather[0].main
            TempF     = $response.main.temp
            FeelsLike = $response.main.feels_like
        }
    } catch {
        Write-Warning "Unable to retrieve weather data."
    }
}

# -------- Outlook Calendar --------
function Get-OutlookCalendarEvents {
    try {
        $Outlook = New-Object -ComObject Outlook.Application
        $Namespace = $Outlook.GetNamespace("MAPI")
        $Calendar = $Namespace.GetDefaultFolder(9)  # olFolderCalendar
        $Today = Get-Date
        $Tomorrow = $Today.AddDays(1)

        $Items = $Calendar.Items
        $Items.IncludeRecurrences = $true
        $Items.Sort("[Start]")
        
        $TodayItems = $Items | Where-Object {
            $_.Start -ge $Today -and $_.Start -lt $Tomorrow
        }

        foreach ($item in $TodayItems) {
            [PSCustomObject]@{
                Subject  = $item.Subject
                Start    = $item.Start
                End      = $item.End
                Location = $item.Location
            }
        }
    } catch {
        Write-Warning "Unable to access Outlook Calendar. Is Outlook installed?"
    }
}

# -------- News Headlines --------
function Get-NewsHeadlines {
    param ([string]$FeedUrl = "http://feeds.feedburner.com/TechCrunch/")
    
    try {
        $feed = Invoke-RestMethod -Uri $FeedUrl
        return $feed.items | Select-Object -First 5 -Property title, pubDate
    } catch {
        Write-Warning "Unable to retrieve news headlines."
    }
}

# -------- Daily Quote --------
function Get-DailyQuote {
    try {
        $url = "https://zenquotes.io/api/today"
        $response = Invoke-RestMethod -Uri $url
        return "`"$($response.q)`" - $($response.a)"
    } catch {
        Write-Warning "Unable to fetch quote of the day."
    }
}

# -------- Main Briefing Function --------
function DailyBriefing {
    Write-Host "`n===== Daily Briefing =====`n" -ForegroundColor Cyan

    Write-Host "System Status"
    Get-SystemStatus | Format-List

    Write-Host "`nWeather"
    Get-Weather -City "Detroit" -ApiKey $ENV:OPENWEATHER_API_KEY | Format-List

    Write-Host "`nCalendar Events"
    Get-OutlookCalendarEvents | Format-Table

    Write-Host "`nTop News Headlines"
    Get-NewsHeadlines | Format-Table -Property Title, pubDate

    Write-Host "`nQuote of the Day"
    Get-DailyQuote

    Write-Host "`n=============================`n"
}

# -------- Optional: Call briefing immediately --------
