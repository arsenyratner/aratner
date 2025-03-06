## надо скопировать и вставить в окно повершелла, от сих
# скопировать ссш ключи на виртуалки для пользователей root и admin01
# файл в котором лежат ключи
$puttydir="\\npr.nornick.ru\hv$\rfexternal\RatnerAL.NPR\Documents\putty"
$puttyexe="$puttydir\putty.exe"
$plinkexe="$puttydir\plink.exe"
$sshpubkeyfile="$puttydir\ratneral.nornik.ru.txt"
# файл со списком адресов ссш серверов, 
# первой строчкой должно быть: serveraddress
$sshserverfile="\\npr.nornick.ru\hv$\rfexternal\ratneral.npr\documents\servers.txt"
# пароль для пользователя admin01
$sshadmin01pass="qaWS3214op!@"
# пароль для пользователя root
$sshrootpass="qaWS3214op!@"
# обнулим массив
$sshservers = @()
# прочитаем в обнулённый массив файл с серверами
import-csv $sshserverfile | foreach-object { $sshservers += @($_.serveraddress) }
# для каждого адреса сервера из списка добавим ключ в authorized_keys
foreach ($sshserver in $sshservers ) {
  # accept host key
  echo y | plink -pw $sshrootpass -ssh    root@$sshserver "exit"
  # add ssh key for remote users
  get-content $sshpubkeyfile | & $plinkexe -batch -pw $sshrootpass       root@$sshserver "cat >> .ssh/authorized_keys"
  get-content $sshpubkeyfile | & $plinkexe -batch -pw $sshadmin01pass admin01@$sshserver "cat >> .ssh/authorized_keys"
}
# открыть все консоли пользователем admin01
#foreach ($sshserver in $sshservers ) { & $puttyexe admin01@$sshserver }
# открыть все консоли пользователем root
#foreach ($sshserver in $sshservers ) { & $puttyexe admin01@$sshserver }
## до сих
