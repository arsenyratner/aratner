param (
  [string]$isopath = "",
  [string]$VMName = ""
)

if ($VMName -eq "") {
  $NEWVMSITE = "iso"
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
  -MemoryStartupBytes 4GB `
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
Set-VMFirmware -VMName $NEWVMNAME -EnableSecureBoot off
# add vhdx to VM
New-VHD -Path "$($NEWVMPATH)\$($NEWVMNAME)\$($NEWVMNAME).vhdx" -SizeBytes 40GB -Dynamic
Add-VMHardDiskDrive -VMName $NEWVMNAME -ControllerType SCSI -ControllerNumber 0 -Path  "$($NEWVMPATH)\$($NEWVMNAME)\$($NEWVMNAME).vhdx"
if ($isopath -eq "") {
  write-host "vm created WO dvd"
} else {
  Add-VMDvdDrive -VMName $NEWVMNAME -path "$isopath"
  # get disk name and set them first boot
  #$firstbootdev = Get-VMHardDiskDrive -VMName $NEWVMNAME
  $firstbootdev = Get-VMDVDDrive -VMName $NEWVMNAME
  Set-VMFirmware -VMName $NEWVMNAME -FirstBootDevice $firstbootdev
}
Start-Process -FilePath "C:\Windows\System32\vmconnect.exe"  -ArgumentList "localhost $NEWVMNAME"
# SIG # Begin signature block
# MIIFrAYJKoZIhvcNAQcCoIIFnTCCBZkCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUBHg9BoX8fqJ9Vkq6s3Cxn10K
# lDCgggMyMIIDLjCCAhagAwIBAgIQFVqhe1NkpItHxflkIAsofDANBgkqhkiG9w0B
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
# 9w0BCQQxFgQUqalsQvigdRu3UD5/PkmxS5JrFVowDQYJKoZIhvcNAQEBBQAEggEA
# Msh3r+aZJnbHKqlqjhz5EYCW1Z4hNtlvfGgYvYgBaBwhlkXs2qAdMg1Xse/485We
# InTkV7cZIQu047flCLiGPub/7ifkOawi0+ldsMH8snDWgagcbXvMzUYt0WpiMGEy
# e6RzkSGOaBVMdgDal+iEx0+sei6YLQOJVg7SAmWxlDKRMO1XI7BhAMzdqe1AsdvE
# WvqUpinyAGen6PZPMm1ZRSAZGMYR4n/7Xpq9I+ylTcbpMbr47QsxrpwZFylfDpZi
# d5G26DfiQlucegzt2upFwsrc2JU/fW31BpXHT5TiZAZa8RcJuEdBPHY5JMjX0/Fr
# 1yqLrWcpzKIDpFvF4pn3yw==
# SIG # End signature block
