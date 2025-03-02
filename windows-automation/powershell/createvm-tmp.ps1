param (
  [string]$VMDiskTmp = "",
	[string]$VMName = "",
	[string]$VMtemplatedir = "C:\ProgramData\hyper-v\_tmp",
  [string]$hashedpass = "`$6`$Wts4Xy2KaAAPRjEa$CF9JedCgijoN9emk9Uj.6ZGvIma7gwr229jwMs9K.tJE2ecn1N0Il4DjC.ubzaRUvPUe1sASXjEYfpQjUS9pQ0",
	[string]$sshPubKey = "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEA7YUTXCKAMavLy98/Kep6eDKK2NyVEc/kUklZUbBubg4DfFHDO2KDXtFN7uq8HPcYR7uqFLqkRijhBwJbnPGLpp2mA+iOHLpJvD/tGpDyNt/ImM0hQG3+dzPLtvzc9Ln5mY2RUfOUTFEx7dqGVuwPQXMhZLCEkpIcGicPTpdG0CIu/GdELUtwgrZZ+reNXMG82VnFBVDZObL7H1YsmrgyyWBUMAzwf+EeUFk9Q4k8qsV8utONo3AvscaESxyt5UDvVuV7PrPxp28a03k9ybMMrXjPzuEaM2P0pxGT0VsIoR/fG78MwkSPTveX0QgDU4gBihOAcH2/2WHGBE+1pr9saw== appc@appc-pc"
)

function Create-CloudInit {
  param(
      $vmname = "$NEWVMNAME",
      $path = "$NEWVMPATH",
      $sshPubKey
  )

  $oscdimgPath = "C:\Program Files\cmdutils\oscdimg.exe"
  $metaDataIso = "$($path)\metadata.iso"
  $metadata = @"
instance-id: uuid-$([GUID]::NewGuid())
local-hostname: $($vmname)
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: true
"@
  $userdata = @"
#cloud-config
users:
  - name: appc
    gecos: appc
    password: $($hashedpass)
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh_import_id: None
    lock_passwd: true
    ssh_authorized_keys: $($sshPubKey)
"@

  Write-Host "Creating CI ISO VMPATH=$path"

  # Output meta and user data to files
  if(-not (Test-Path "$($path)\Bits")) {New-Item -ItemType Directory "$($path)\Bits" | out-null}
  sc "$($path)\Bits\meta-data" ([byte[]][char[]] "$metadata") -Encoding Byte
  sc "$($path)\Bits\user-data" ([byte[]][char[]] "$userdata") -Encoding Byte

  # Create meta data ISO image - this thing apparently outputs in stderr so it shows as red but it's not errors, it's just the progress for it.
  & $oscdimgPath "$($path)\Bits" $metaDataIso -j2 -lcidata | Out-null
}

if ($VMName -eq "") {
  $NEWVMSITE = "vm"
  $NEWVMROLE = -join ((48..57) + (97..122) | Get-Random -Count 4 | % {[char]$_})
  $NEWVMNAME = "$($NEWVMSITE)-$($NEWVMROLE)"
  write-host "VMName = $($NEWVMNAME)"
} else {
  $NEWVMNAME = $VMName
  write-host "VMName = $($NEWVMNAME)"
}
$NEWVMPATH = "c:\vm"
$NEWVMSWITCH = "VMI"
$NEWVMCPU = "2"

$VMEXIST = Get-VM -Name $NEWVMNAME -ErrorAction SilentlyContinue
if ($VMEXIST) {
	write-host "VM exists VMName = $($NEWVMNAME)"
	exit
}
# create new VM
New-VM `
  -Generation 2 `
  -NoVHD `
  -Name $NEWVMNAME `
  -Path $NEWVMPATH `
  -SwitchName $NEWVMSWITCH
# set vm settings
Set-VM `
  -Name $NEWVMNAME `
  -AutomaticStartAction Nothing `
  -AutomaticStopAction ShutDown `
  -AutomaticCheckpointsEnabled $false
#   -CheckpointType Disabled `
# set proc settings
Set-VMProcessor $NEWVMNAME `
  -Count $NEWVMCPU
# disable secure boot
Set-VMFirmware `
  -VMName $NEWVMNAME `
  -EnableSecureBoot off

Create-CloudInit -vmname $NEWVMNAME -path $NEWVMPATH\$NEWVMNAME -sshPubKey $sshPubKey
Add-VMDvdDrive -VMName $NEWVMNAME -path "$NEWVMPATH\$NEWVMNAME\metadata.iso"
  
if ($VMDiskTmp -eq "") {
  write-host "place template vhdx to $($VMtemplatedir)"
} else {
  $NEWVMDISKTMPLT = "$($VMtemplatedir)\$($VMDiskTmp)"
  write-host "Template = $($VMtemplatedir)\$($VMDiskTmp)"
  # add vhdx to VM
  #copy teplate vhdx and add to VM
  Copy-Item -Path $NEWVMDISKTMPLT -Destination "$($NEWVMPATH)\$($NEWVMNAME)\$($NEWVMNAME).vhdx"
  Add-VMHardDiskDrive -VMName $NEWVMNAME -ControllerType SCSI -ControllerNumber 0 -Path  "$($NEWVMPATH)\$($NEWVMNAME)\$($NEWVMNAME).vhdx"
  # get disk name and set them first boot
  $VMHDD = Get-VMHardDiskDrive -VMName $NEWVMNAME
  Set-VMFirmware -VMName $NEWVMNAME -FirstBootDevice $VMHDD
  #Write-Host "Create-CloudInit -vmname $NEWVMNAME -path $NEWVMPATH -sshPubKey $sshPubKey"
  # starting VM
  Start-VM $NEWVMNAME
  Get-VM $NEWVMNAME | Get-VMNetworkAdapter | ft MacAddress
}
Start-Process -FilePath "C:\Windows\System32\vmconnect.exe"  -ArgumentList "localhost $NEWVMNAME"
# SIG # Begin signature block
# MIIFrAYJKoZIhvcNAQcCoIIFnTCCBZkCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUZtKf0iux3d2fz/J6IQlptdcc
# wfmgggMyMIIDLjCCAhagAwIBAgIQFVqhe1NkpItHxflkIAsofDANBgkqhkiG9w0B
# AQ0FADAvMS0wKwYDVQQDDCRBUkFUTkVSIFBvd2VyU2hlbGwgQ29kZSBTaWduaW5n
# IENlcnQwHhcNMjQwMzIwMTg0NTMxWhcNNDQwMzIwMTg1NTMxWjAvMS0wKwYDVQQD
# DCRBUkFUTkVSIFBvd2VyU2hlbGwgQ29kZSBTaWduaW5nIENlcnQwggEiMA0GCSqG
# SIb3DQEBAQUAA4IBDwAwggEKAoIBAQC9XIza+6Jh6u3H6/WPlrmV9ZqEpuHRvkVS
# xNuSaDUGxad5b5+p3ZZDzoMJXgrLoBxaywDPdhCxPhAGJZ8D6UGXsnQVmlT/I/VZ
# SJZuO9Uql5EwMqGvtpEezVlG9IhZELKmniK4AawL7u2rW0FXPzviZdMIWAfdKVVW
# 7A5JmMkzEEfhjZI5TufbnowvFNFwJznHhBcWUMx27D7zsKJrWBlUe+nCPhMj71+P
# MMnBIOB0zl1CGT+rhlVdhRoTNO/bB5W7Z2WQ+82lM+DwgW/u9y5usxZ5AzIAjKhx
# KoBbnxIzrgB5NT+UzRJUj5P0t1onQmQ87/FsYM7oZ2FVhgvS4OUpAgMBAAGjRjBE
# MA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggrBgEFBQcDAzAdBgNVHQ4EFgQU
# rxshP7adLWNu2qFjT9PMwH6OkVMwDQYJKoZIhvcNAQENBQADggEBAHIzmxyV8PLE
# iGfQkQ96/e4aQ/c39xQRRoKKJA0O65HrgrHZ2TxjlcMlYHiUSGoi6hgCTknHm3U4
# 055nvqCgZX0UsygNJ1V3IXv90njBF6qJc4NnhAuzvyuD40XUvV9/qqGaemYjEGU+
# czWT22WiBhQ0h4wCVbmOO8McbrHnQWBZVuf4fAVwNc7cZ26h42bh+6oe90/7Aq4S
# DRhSCxc580ABV5T1bkSgNSQ5cx0E/olsXWAutAoW6qqB0hIuj/XsFus8ZPuFKmVX
# f/ZCCuqHNXPBibillth5JbGvdnhbWqjzk3G4y4eLWXeAszpUTqrGDKlIp6UMNhXr
# HbIaSzGKGmsxggHkMIIB4AIBATBDMC8xLTArBgNVBAMMJEFSQVRORVIgUG93ZXJT
# aGVsbCBDb2RlIFNpZ25pbmcgQ2VydAIQFVqhe1NkpItHxflkIAsofDAJBgUrDgMC
# GgUAoHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMxDAYK
# KwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG
# 9w0BCQQxFgQUBjoHyszkCBmQZso6Pn92vkl/pxMwDQYJKoZIhvcNAQEBBQAEggEA
# h+ERpjJ6yHzU3F78hSN1ye6Jco3kctJ5lUVOpC3/NU48UQNHM+0ESuIghzBvQzTy
# E7NbToeEZ/+9UdcV0Kg3tdZ2Z8TUKEXsp1VaJObV/NCYG+X46Cf7rII8Eb4Kswnk
# vXX7K41j5UxklvGfAZUAPjYV2KnHhF09hP6e6CsopS3VEC2f+uqNsoi+JQq6fV2c
# oggy/pZit34XR8DJGvZYsRFz/txb4TSChgILxyqN4Yd3UY3l6E/va6yrm8HlNkcz
# tNfKCwK5vMNJc3u4wmltkvb/ufHC286niAyHEpwhJKM8sLWEXW4cOivQn67R108S
# J0CFmwgrgqAAFQH9THSAgw==
# SIG # End signature block
