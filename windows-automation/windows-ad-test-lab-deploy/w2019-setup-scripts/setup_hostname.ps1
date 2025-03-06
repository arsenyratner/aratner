# load variables
. .\setup_variables.ps1

Rename-Computer -NewName $compname
Restart-Computer -force
