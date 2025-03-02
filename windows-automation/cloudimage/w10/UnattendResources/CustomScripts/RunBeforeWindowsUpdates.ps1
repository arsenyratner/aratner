# Disable antivirus
Write-Log "Disable realtime monitoring"
Set-MpPreference -DisableRealtimeMonitoring $true

# install choco
Write-Log "install choco"
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# install rsat for server
# Write-Log "install RSAT for server"
# Get-WindowsFeature | Where-Object {$_.name -like "*RSAT*"}| Install-WindowsFeature -IncludeAllSubFeature

# install rsat for pro
Write-Log "install RSAT"
$Folder = 'D:\LanguagesAndOptionalFeatures'
if (Test-Path -Path $Folder) {
    Get-WindowsCapability -Name RSAT* -Online -Source "$Folder" | Where-Object State -EQ NotPresent | Add-WindowsCapability -Online -Source "$Folder" -ErrorAction SilentlyContinue 
} else {
    Get-WindowsCapability -Name RSAT* -Online | Where-Object State -EQ NotPresent | Add-WindowsCapability -Online
}

# $capabilities = Get-WindowsCapability -Online | Where-Object { $_.Name -like "RSAT*" -AND $_.State -eq "NotPresent" }
# If ($null -ne $capabilities) {
#     #something to install
#     Write-Log -Message "Found $($capabilities.count) capabilities to install"
#     ForEach ($capability in $capabilities) {
#         Try {
#             Write-Log -Message "Installing $($capability.Name)"
#             $result = Add-WindowsCapability -Online -Name $capability.Name
#             If (!$rebootNeeded -AND $result.RestartNeeded) {
#                 #$True or $rebootNeeded already $true (don't process further)
#                 Write-Log -Message "Found reboot requirement, updating return code" -Severity 2
#                 $rebootNeeded = $True
#             }
#         } 
#         Catch [System.Exception] {
#             Write-Log -Message "There was an error adding $($capability.Name)" -Severity 3
#             $failureDetected = $True
#         }
#     }
# }
# Else {
#     Write-Log -Message "No capabilities found to add"
# }
