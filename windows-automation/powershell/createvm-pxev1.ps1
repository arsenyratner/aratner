param (
  [string]$VMName = ""
)

if ($VMName -eq "") {
  $NEWVMSITE = "pxe"
  $NEWVMROLE = -join ((48..57) + (97..122) | Get-Random -Count 4 | % {[char]$_})
  $NEWVMNAME = "$($NEWVMSITE)-$($NEWVMROLE)"
  write-host "VMName = $($NEWVMNAME)"
} else {
  $NEWVMNAME = $VMName
  write-host "VMName = $($NEWVMNAME)"
}

$NEWVMPATH = "c:\vm"
$NEWVMSWITCH = "VMI"
$NEWVMCPU = "4"

$VMEXIST = Get-VM -Name $NEWVMNAME -ErrorAction SilentlyContinue
if ($VMEXIST) {
	write-host "VM exists VMName = $($NEWVMNAME)"
	exit
}
# create new VM
New-VM `
  -Generation 1 `
  -NoVHD `
  -Name $NEWVMNAME `
  -Path $NEWVMPATH `
  -BootDevice LegacyNetworkAdapter `
  -SwitchName $NEWVMSWITCH
# set vm settings
Start-Process -FilePath "C:\Windows\System32\vmconnect.exe"  -ArgumentList "localhost $NEWVMNAME"

Set-VM `
  -Name $NEWVMNAME `
  -AutomaticStartAction Nothing `
  -AutomaticStopAction ShutDown `
  -AutomaticCheckpointsEnabled $false
#   -CheckpointType Disabled `
# set proc settings
Set-VMProcessor $NEWVMNAME `
  -Count $NEWVMCPU
Set-VMMemory $NEWVMNAME -StartupBytes 4096MB -DynamicMemoryEnabled $false

# add vhdx to VM
New-VHD -Path "$($NEWVMPATH)\$($NEWVMNAME)\$($NEWVMNAME).vhdx" -SizeBytes 7GB -Dynamic
Add-VMHardDiskDrive -VMName $NEWVMNAME -ControllerType IDE -ControllerNumber 0 -Path  "$($NEWVMPATH)\$($NEWVMNAME)\$($NEWVMNAME).vhdx"
Set-VMBios $NEWVMNAME -StartupOrder @("LegacyNetworkAdapter", "CD", "IDE", "Floppy" )
