# load variables
. .\setup_variables.ps1

$HashParams = @{
  SamAccountName = $joinuser
  Name = $joinuser
  AccountPassword = $joinpassword
  Enabled = $true
  GivenName = $joinuser
  DisplayName = $joinuser
  UserPrincipalName = "$sAMAccountName@$domainname"
}
New-ADUser @HashParams
# пока добавим в группу администраторы
# в будущем сделаем делегирование для создания и удаления компьютеров в АД
Add-ADGroupMember -Identity Administrators -members $joinuser
