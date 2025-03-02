# Disable antivirus
Write-Log "Disable realtime monitoring"
Set-MpPreference -DisableRealtimeMonitoring $true

# install choco
Write-Log "install choco"
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# install rsat for server
Write-Log "install RSAT for server"
Get-WindowsFeature | Where-Object {$_.name -like "*RSAT*"}| Install-WindowsFeature -IncludeAllSubFeature

# install rsat for pro
#Write-Log "install RSAT"
#Get-WindowsCapability -Name RSAT* -Online | where State -EQ NotPresent | Add-WindowsCapability -Online
