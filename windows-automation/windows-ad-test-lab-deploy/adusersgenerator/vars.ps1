$labname = "_lab03"
$sharedfoldersrootpath="\\aratner-dc1\pub"

$userCount = 100
$locationCount = 2

# Files 
$departmentsFile = "departments.csv"
$firstNameFile = "Firstnames.txt"
$lastNameFile = "Lastnames.txt"
$addressFile = "Addresses.txt"
$postalAreaFile = "PostalAreaCode.txt"
$foldersListFile = "folders.txt"

# Other parameters
$baseOU = "DC=ad,DC=aratner,DC=ru" # 
$ou = "OU=$($labname),$($baseOU)" # OU в которой будет создана структура
$initialPassword = "Password2" # пароль для всех пользователей
$orgShortName = "ARAD" # не используется
$emailDomain = "aratner.ru" # доменная часть почтового адреса
$dnsDomain = "ad.aratner.ru" # домен AD
$company = "ARA co" # название компании

function SetFolderAcls ($rootpath,$foldername,$group_prefix) {
    Write-Debug "R: $rootpath F: $foldername Pre: $group_prefix"
    $HashParams = @{
        Path = "$rootpath"
        ItemType = "directory"
        Name = $foldername
    }
    $null = New-Item @HashParams -Force 
    # Path to folder
    $DirPath = "$($rootpath)\$($foldername)"
    # Get current ACLs
    $DirAcl = Get-Acl -Path $DirPath
    # Remove existing ACLs
    ForEach ($Access in $DirAcl.Access) {$Null = $DirAcl.RemoveAccessRule($Access)}
    # Add new explicit ACLs
    $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("BUILTIN\Administrators","FullControl","ContainerInherit,ObjectInherit","None","Allow")
    $Null = $DirAcl.SetAccessRule($AccessRule)
    $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("NT AUTHORITY\SYSTEM","FullControl","ContainerInherit,ObjectInherit","None","Allow")
    $Null = $DirAcl.SetAccessRule($AccessRule)
    $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("$($group_prefix)_$($foldername)_modify","Modify","ContainerInherit,ObjectInherit","None","Allow")
    $Null = $DirAcl.SetAccessRule($AccessRule)
    $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("$($group_prefix)_$($foldername)_read","Read","ContainerInherit,ObjectInherit","None","Allow")
    $Null = $DirAcl.SetAccessRule($AccessRule)
    $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("$($group_prefix)_$($foldername)_list","ListDirectory","ContainerInherit,ObjectInherit","None","Allow")
    $Null = $DirAcl.SetAccessRule($AccessRule)
    # Disable inheritance
    $DirAcl.SetAccessRuleProtection($True,$False)
    # Write ACLs back to folder
    Set-Acl -Path $DirPath -AclObject $DirAcl
}
