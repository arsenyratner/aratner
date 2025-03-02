# load variables
. .\setup_variables.ps1

$adcred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "$($nbname)\$($joinuser)", $joinpassword
remove-computer -UnJoinDomainCredential $adcred -WorkgroupName "WORKGROUP" -Force -Restart
