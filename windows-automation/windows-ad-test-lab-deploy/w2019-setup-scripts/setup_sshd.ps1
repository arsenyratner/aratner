#install openssh server
Get-WindowsCapability -Online | Where-Object Name -like "OpenSSH.Server*" | Add-WindowsCapability -Online

#enable service 
Set-Service -Name sshd -StartupType 'Automatic'
Start-Service sshd

# add firewall rule
#Get-NetFirewallRule -Name *OpenSSH-Server* | select Name, DisplayName, Description, Enabled
New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22

# powershell вместо cmd
New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -PropertyType String -Force
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name Shell -Value 'PowerShell.exe -NoExit'

#добавить ключ для авторизации
$authorizedKey = @'
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC8z/rBphuDpGKHpcDtWDISCZFWybdH3fSKzVxWouLG0JuEhqZSpJT9Hd+16teA8daRPb1gY+l9+mRnCqTVDKxpnMq7jkjlfNKQPunDHhr3u7JDjeBel2JrgXs/GANMSbxyC5aRNP7XYs4TooRDUFr0XXvdglcYyP+34I0M+p9m94taK1q5FtL+JrpRXXGnhYzQn/GaV0rM9Qj21GFVWPfuqqG8wWwhaYPkeibJNhMcBy+qKRK0fIiklv68fWmIwd0Os9qEAJ4XTuVP8yfKR/Cu1hXPm/4+9JfXaw3Lh9e/J54NkRcyeT3wb0BgOpXMXnexl6HTUK59EcMaLGEaU+4F aratner@croc.ru
'@
# for admin users
Add-Content -Force -Path $env:ProgramData\ssh\administrators_authorized_keys -Value $authorizedKey
icacls.exe "$env:ProgramData\ssh\administrators_authorized_keys" /inheritance:r /grant "Administrators:F" /grant "SYSTEM:F"
# for current user 
New-Item -Force -ItemType Directory -Path $env:USERPROFILE\.ssh
Add-Content -Force -Path $env:USERPROFILE\.ssh\authorized_keys -Value $authorizedKey

# replace default values in sshd_config
$sshdconfig="$env:ProgramData\ssh\sshd_config"
$null=(Get-Content -path $sshdconfig -Raw) -replace '#StrictModes yes','StrictModes yes' | Set-Content -Path $sshdconfig
$null=(Get-Content -path $sshdconfig -Raw) -replace 'StrictModes yes','StrictModes no' | Set-Content -Path $sshdconfig
$null=(Get-Content -path $sshdconfig -Raw) -replace '#PubkeyAuthentication yes','PubkeyAuthentication yes' | Set-Content -Path $sshdconfig
$null=(Get-Content -path $sshdconfig -Raw) -replace '#AllowAgentForwarding yes','AllowAgentForwarding yes' | Set-Content -Path $sshdconfig

Restart-Service sshd
