# load variables
. .\setup_variables.ps1

Rename-Computer -NewName $compname
#$adcred = Get-Credential
$adcred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "$($nbname)\$($joinuser)", $joinpassword
$MYCOMPUTER = Get-WmiObject Win32_ComputerSystem
$MYCOMPUTER.UnJoinDomainOrWorkGroup("$($adcred.Password)", "$($adcred.UserName)", 0)
Add-computer -Credential $adcred -domainname $domainname
#Restart-Computer -force
