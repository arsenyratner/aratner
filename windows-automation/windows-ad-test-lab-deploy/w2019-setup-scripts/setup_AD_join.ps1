# load variables
. .\setup_variables.ps1

Rename-Computer -NewName $compname
$adcred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "$($nbname)\$($joinuser)", $joinpassword
Add-computer -Credential $adcred -domainname $domainname
#Restart-Computer -force
