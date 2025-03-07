# load variables
. .\vars.ps1

Import-CSV $foldersListFile | ForEach-Object {
    $folderslist += @($_.FolderName)
}

$groupsuffixes = @("read","modify","list")
foreach ($folder in $folderslist) {
    foreach ($suffix in $groupsuffixes) {
        $GroupParams = @{
            Name = "$($labname)_F_$($folder)_$suffix"
            GroupScope = "DomainLocal"
            GroupCategory = "Security"
            Path = "OU=Folders,OU=_Resources,$($ou)"
        }
        New-ADGroup @GroupParams
    }
    SetFolderAcls "$sharedfoldersrootpath\$($labname)" $folder "$($labname)_F"
}
