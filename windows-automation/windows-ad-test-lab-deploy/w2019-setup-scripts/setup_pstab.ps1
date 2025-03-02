#таб пусть работает как в bash
$profilecontent=@'
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
'@
#для пользователя
$profilefile=[Environment]::GetFolderPath([Environment+SpecialFolder]::MyDocuments)+"\WindowsPowerShell\profile.ps1"
$null=!(test-path $profilefile); if ($?) {$null=New-Item -Force -ItemType "file" -Path $profilefile}
Add-Content -Force -Path $profilefile -Value $profilecontent
#для всех 
$profilefile=$PSHOME\Profile.ps1
$null=!(test-path $profilefile); if ($?) {$null=New-Item -Force -ItemType "file" -Path $profilefile}
Add-Content -Force -Path $profilefile -Value $profilecontent
