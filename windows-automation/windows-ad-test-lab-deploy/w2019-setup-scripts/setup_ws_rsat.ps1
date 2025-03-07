# получить список модулей
#Get-WindowsCapability -Name RSAT* -Online | Select-Object -Property DisplayName, State
# отключить автообновление с WSUS
#New-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU -Name UseWUServer -PropertyType dword -Value 0 -Force
# перезапустить службу windows update
#restart-service wuauserv
# установить все неустановленные модули
Get-WindowsCapability -Name RSAT* -Online | where State -EQ NotPresent | Add-WindowsCapability -Online
