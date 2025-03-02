# install virtio-win
# Write-Log "install virtio-win"
# Start-Process -Wait -NoNewWindow -FilePath "$ENV:SystemDrive\UnattendResources\virtio-win-guest-tools.exe" -ArgumentList "/s /qn"

# install openssh server
# Write-Log "install openssh server"
# Get-WindowsCapability -Online | Where-Object Name -like "OpenSSH.Server*" | Add-WindowsCapability -Online
#enable ssh agent and server
# Set-Service -Name ssh-agent -StartupType Automatic 
# Set-Service -Name sshd -StartupType Automatic 
#powershell as default shell in ssh console
# New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -PropertyType String -Force

# install soft
Write-Log "install software"
Start-Process -Wait -NoNewWindow -FilePath "C:\ProgramData\chocolatey\choco.exe" -ArgumentList "install -y 7zip bind-toolsonly git wget gawk grep gnuwin32-coreutils.install winscp putty.install sysinternals"
# vim openssl - убрал, очень долго загружаются

function Test-RegistryValue {
    param (
     [parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]$Path,
     [parameter(Mandatory=$true)] [ValidateNotNullOrEmpty()]$Value
    )
    try {
     Get-ItemProperty -Path $Path -Name $Value -EA Stop
     return $true
    }  catch {
     return $false
    }
}

[bool]$PendingReboot = $false

#Check for Keys
If ((Test-Path -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired") -eq $true)
{
    Write-Log "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired"
    $PendingReboot = $true
}

If ((Test-Path -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\PostRebootReporting") -eq $true)
{
    Write-Log "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\PostRebootReporting"
    $PendingReboot = $true
}

If ((Test-Path -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired") -eq $true)
{
    Write-Log "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired"
    $PendingReboot = $true
}

If ((Test-Path -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending") -eq $true)
{
    Write-Log "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending"
    $PendingReboot = $true
}

If ((Test-Path -Path "HKLM:\SOFTWARE\Microsoft\ServerManager\CurrentRebootAttempts") -eq $true)
{
    Write-Log "HKLM:\SOFTWARE\Microsoft\ServerManager\CurrentRebootAttempts"
    $PendingReboot = $true
}

#Check for Values
If ((Test-RegistryValue -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Component Based Servicing" -Value "RebootInProgress") -eq $true)
{
    Write-Log "HKLM:\Software\Microsoft\Windows\CurrentVersion\Component Based Servicing > RebootInProgress"
    $PendingReboot = $true
}

If ((Test-RegistryValue -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Component Based Servicing" -Value "PackagesPending") -eq $true)
{
    Write-Log "HKLM:\Software\Microsoft\Windows\CurrentVersion\Component Based Servicing > PackagesPending"
    $PendingReboot = $true
}

If ((Test-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" -Value "PendingFileRenameOperations") -eq $true)
{
    Write-Log "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager > PendingFileRenameOperations"
    $PendingReboot = $true
}

If ((Test-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" -Value "PendingFileRenameOperations2") -eq $true)
{
    Write-Log "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager > PendingFileRenameOperations2"
    $PendingReboot = $true
}

If ((Test-RegistryValue -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce" -Value "DVDRebootSignal") -eq $true)
{
    Write-Log "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce > DVDRebootSignal"
    $PendingReboot = $true
}

If ((Test-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon" -Value "JoinDomain") -eq $true)
{
    Write-Log "HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon > JoinDomain"
    $PendingReboot = $true
}

If ((Test-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon" -Value "AvoidSpnSet") -eq $true)
{
    Write-Log "HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon > AvoidSpnSet"
    $PendingReboot = $true
}

Write-Log "Reboot pending: $PendingReboot"
if ($PendingReboot) { Restart-Computer -force }
