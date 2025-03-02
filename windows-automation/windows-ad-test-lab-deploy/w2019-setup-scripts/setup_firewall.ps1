# disable firewall
#Set-NetFirewallProfile -All -Enabled False
# enable firewall
#Set-NetFirewallProfile -All -Enabled True

# check icmp rule
Get-NetFirewallRule *icmp4* | ft Name,DisplayName,Enabled
# enable icmp in
Set-NetFirewallRule FPS-ICMP4-ERQ-In -Enabled True
# check smb rule
Get-NetFirewallRule *smb-in* | ft Name,DisplayName,Enabled
# enable smb in
Set-NetFirewallRule FPS-SMB-In-TCP -Enabled True
