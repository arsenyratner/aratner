# load variables
. .\setup_variables.ps1

$HashParams = @{
    Path = "$sharedfolderlocalpath"
    ItemType = "directory"
    # Name = $sharedfoldername
}
$null = New-Item @HashParams -Force 

$Parameters = @{
    Name = $sharedfoldername
    Path = "$sharedfolderlocalpath"
    FullAccess = 'Everyone'
}
$null = New-SmbShare @Parameters
