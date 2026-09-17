$desktopUserPath = [Environment]::GetFolderPath("Desktop")
$desktopPublicPath = [Environment]::GetFolderPath("CommonDesktopDirectory")
$downloadsPath = [System.IO.Path]::Combine([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::UserProfile), "Downloads")

$teamviewerPath = [System.IO.Path]::Combine($downloadsPath, "teamviewerqs11.exe")
$teamviewerDesktopPath = [System.IO.Path]::Combine($desktopPublicPath, "FTINC.exe")
$teamviewerUrl = "https://download.splashtop.com/sos/SplashtopSOS.exe"

$mcafeeMcprPath = [System.IO.Path]::Combine($downloadsPath, "mcafeemcpr.exe")
$mcafeeMcprUrl = "https://download.mcafee.com/molbin/iss-loc/SupportTools/MCPR/MCPR.exe"

$edgeShortcut = "Microsoft Edge.lnk"
$adobeAcrobatShortcut = "Adobe Acrobat.lnk"

$currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name


function Delete-File {
    param (
        [string]$filePath
    )
    if (Test-Path -Path $filePath) {
        Remove-Item -Path $filePath -Force
        Write-Host "Delete-File: $filePath"
    }
    else {
        Write-Host "Delete-File not found: $filePath"
    }
}


function Download-File {
    param (
        [string]$url,
        [string]$outputPath
    )
    try {
        Invoke-WebRequest -Uri $url -OutFile $outputPath
        Write-Host "Download-File $url to $outputPath"
    }
    catch {
        Write-Host "Download-File Failed: $url"
    }
}


function Install-Google-Chrome {
    param (
        [string]$tempPath = "$env:USERPROFILE\Downloads"
    )
    $keyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe"
    $keyName = "(default)"
    $url = "https://dl.google.com/chrome/install/latest/chrome_installer.exe"
    $installerName = "chrome_installer.exe"
    $installerPath = [System.IO.Path]::Combine($tempPath, $installerName)
    if (Test-Path $keyPath) {
        $propertyValue = (Get-ItemProperty -Path $keyPath -ErrorAction SilentlyContinue).$keyName
        if ($propertyValue) {
            return $false
        }
    }
    Download-File -url $url -outputPath $installerPath
    Start-Process -FilePath $installerPath -ArgumentList "/S" -Wait
    return $true
}

function Install-Mozilla-Firefox {
    param (
        [string]$tempPath = "$env:USERPROFILE\Downloads"
    )
    $keyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\firefox.exe"
    $keyName = "(default)"
    $url = "https://download.mozilla.org/?product=firefox-latest&os=win64&lang=en-US"
    $installerName = "firefox_installer.exe"
    $installerPath = [System.IO.Path]::Combine($tempPath, $installerName)
    if (Test-Path $keyPath) {
        $propertyValue = (Get-ItemProperty -Path $keyPath -ErrorAction SilentlyContinue).$keyName
        if ($propertyValue) {
            return $false
        }
    }
    Download-File -url $url -outputPath $installerPath
    Start-Process -FilePath $installerPath -ArgumentList "/S" -Wait
    return $true
}

function Install-Adobe-AcrobatReader {
    $keyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\Acrobat.exe"
    $keyName = "(default)"
    $url = "https://get.adobe.com/reader/"
    if (Test-Path $keyPath) {
        $propertyValue = (Get-ItemProperty -Path $keyPath -ErrorAction SilentlyContinue).$keyName
        if ($propertyValue) {
            return $false
        }
    }
    Start-Process $url
    return $true
}


# Check if the script is running as an administrator
if (-not ([bool] ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))) {
    Write-Host "You need to run this script as an Administrator!"
    exit
}


# set timezone to central/winnipeg
$timeZones = Get-TimeZone -ListAvailable
$desiredTimeZone = $timeZones | Where-Object { $_.Id -eq 'Central Standard Time' }
if ($null -ne $desiredTimeZone) {
    Set-TimeZone -Id 'Central Standard Time'
}


# set background to solid and navy blue
Set-ItemProperty -Path "HKCU:\Control Panel\Colors" -Name "Background" -Value "0 99 177"
$regpathdesktop = "HKCU:\Control Panel\Desktop"
Set-ItemProperty -Path $regpathdesktop -Name "WallPaper" -Value ""
Set-ItemProperty -Path $regpathdesktop -Name "WallpaperStyle" -Value "2"
Set-ItemProperty -Path $regpathdesktop -Name "BackgroundType" -Value "2"
rundll32.exe user32.dll, UpdatePerUserSystemParameters


# Define the start and end times for active hours
$activeHoursStart = 7
$activeHoursEnd = 20
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" -Name "ActiveHoursStart" -Value $activeHoursStart
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" -Name "ActiveHoursEnd" -Value $activeHoursEnd
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" -Name "UserChoiceActiveHoursStart" -Value $activeHoursStart
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" -Name "UserChoiceActiveHoursEnd" -Value $activeHoursEnd
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" -Name "SmartActiveHoursState" -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" -Name "AllowMUUpdateService" -Value 1
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" -Name "IsExpedited" -Value 1


# Define your business information
$businessName = "Friesen Technologies"
$supportEmail = "support@ftinc.ca"
$supportPhone = "204-346-6480"
$supportWebsite = "https://www.ftinc.ca"
$registryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation"
New-ItemProperty -Path $registryPath -Name "Manufacturer" -Value $businessName -PropertyType "String" -Force
New-ItemProperty -Path $registryPath -Name "SupportHours" -Value "" -PropertyType "String" -Force
New-ItemProperty -Path $registryPath -Name "SupportPhone" -Value $supportPhone -PropertyType "String" -Force
New-ItemProperty -Path $registryPath -Name "SupportURL" -Value $supportWebsite -PropertyType "String" -Force
New-ItemProperty -Path $registryPath -Name "SupportEmail" -Value $supportEmail -PropertyType "String" -Force


# set default power settings
powercfg /change monitor-timeout-ac 10
powercfg /change standby-timeout-ac 0


# set taskbar settings
$taskbarPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
Set-ItemProperty -Path $taskbarPath -Name "ShowTaskViewButton" -Value 0
Set-ItemProperty -Path $taskbarPath -Name "TaskbarDa" -Value 0
Set-ItemProperty -Path $taskbarPath -Name "TaskbarAl" -Value 0
Set-ItemProperty -Path $taskbarPath -Name "TaskbarGlomLevel" -Value 1

# windows 11 - turn off taskbar search
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Type DWord -Value 0

# windows 11 - turn off prompt for microsoft account
$RegistryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
$ValueName = "NoConnectedUser"
$ValueData = 3
#Set-ItemProperty -Path $RegistryPath -Name $ValueName -Value $ValueData -Type DWord -Force -ErrorAction Stop


# disable copilot
$regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
if (-not (Test-Path $regPath)) {
    New-Item -Path $regPath -Force | Out-Null
}
Set-ItemProperty -Path $regPath -Name "ShowCopilotButton" -Value 0 -Type DWord
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" -Name "TurnOffWindowsCopilot" -Value 1 -Type DWord


# disable onedrive
Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "OneDrive" -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKCU:\Software\Microsoft\OneDrive" -Name "UserSettingAutoStart" -Value 0 -ErrorAction SilentlyContinue
Get-ScheduledTask -TaskPath "\" -TaskName "OneDrive*" | Disable-ScheduledTask -ErrorAction SilentlyContinue


# download common installers
Download-File -url $teamviewerUrl -outputPath $teamviewerPath
Copy-Item -Path $teamviewerPath -Destination $teamviewerDesktopPath -Force


# delete files
$path = [System.IO.Path]::Combine($desktopPublicPath, $edgeShortcut)
Delete-File -filePath $path
$path = [System.IO.Path]::Combine($desktopUserPath, $edgeShortcut)
Delete-File -filePath $path
$path = [System.IO.Path]::Combine($desktopPublicPath, $adobeAcrobatShortcut)
Delete-File -filePath $path
$path = [System.IO.Path]::Combine($desktopUserPath, $adobeAcrobatShortcut)
Delete-File -filePath $path


# restart explorer
Stop-Process -Name explorer -Force


# installers
Install-Google-Chrome $downloadsPath
Install-Mozilla-Firefox $downloadsPath
Install-Adobe-AcrobatReader


# delete desktop shortcuts
$path = [System.IO.Path]::Combine($desktopPublicPath, "Google Chrome.lnk")
Delete-File -filePath $path
$path = [System.IO.Path]::Combine($desktopPublicPath, "Firefox.lnk")
Delete-File -filePath $path
$path = [System.IO.Path]::Combine($desktopPublicPath, "Adobe Acrobat.lnk")
Delete-File -filePath $path


$installedApps = Get-StartApps | Where-Object { $_.Name -like "*McAfee*" } | Select-Object Name, AppID
$installedApps | Format-Table -AutoSize

$installedAppsSystem = Get-AppxPackage -AllUsers | Where-Object { $_.Name -like "*McAfee*" } | Select-Object Name, PackageFullName
$installedAppsSystem | Format-Table -AutoSize

# download mcafee removal tool
Invoke-WebRequest -Uri $mcafeeMcprUrl -OutFile $mcafeeMcprPath
Start-Process -FilePath $mcafeeMcprPath -Wait

Write-Host "$($env:COMPUTERNAME)"

$SerialNumber = (Get-WmiObject -class win32_bios).SerialNumber
Write-Host $SerialNumber

Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -notlike "Loopback" } | ForEach-Object { Write-Host "IP Address: $($_.IPAddress)" }
