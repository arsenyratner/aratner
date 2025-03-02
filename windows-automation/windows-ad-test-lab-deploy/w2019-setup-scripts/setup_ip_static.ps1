# скрипт установит статикой адрес? который получен от DHCP сервера
$NICs = Get-WmiObject -Class Win32_NetworkAdapterConfiguration | where {$_.IPEnabled -eq $true -and $_.DHCPEnabled -eq $true}
foreach($NIC in $NICs) {
   $DNSServers = $NIC.DNSServerSearchOrder 
   $NIC.SetDNSServerSearchOrder($DNSServers)
   $NIC.SetDynamicDNSRegistration("TRUE")
   $IPADDR = ($NIC.IPAddress[0])
   $gateway = $NIC.DefaultIPGateway
   $NETMASK = $NIC.IPSubnet[0]
   $NIC.EnableStatic($IPADDR, $NETMASK)
   $NIC.SetGateways($gateway)
}
