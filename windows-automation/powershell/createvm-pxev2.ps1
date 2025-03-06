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

# get disk name and set them first boot
#$firstbootdev = Get-VMHardDiskDrive -VMName $NEWVMNAME
#$firstbootdev = Get-VMDVDDrive -VMName $NEWVMNAME
$firstbootdev = Get-VMNetworkAdapter -VMName $NEWVMNAME
Set-VMFirmware -VMName $NEWVMNAME -FirstBootDevice $firstbootdev
Start-Process -FilePath "C:\Windows\System32\vmconnect.exe"  -ArgumentList "localhost $NEWVMNAME"

# SIG # Begin signature block
# MIIFeQYJKoZIhvcNAQcCoIIFajCCBWYCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUEYsShUBysX/2bGNkrNltJowe
# yi2gggMQMIIDDDCCAfSgAwIBAgIQbG8uhNAfmZtKU+9FTikRcDANBgkqhkiG9w0B
# AQUFADAeMRwwGgYDVQQDDBNhcHBjLXA2MjUgQ29kZSBTaWduMB4XDTI0MDUwNjA4
# NDgwMloXDTQ0MDUwNjA4NTgwMlowHjEcMBoGA1UEAwwTYXBwYy1wNjI1IENvZGUg
# U2lnbjCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAMssR/FW6BhEsMHX
# jW6jgySOLkCMFUPNBQ97R2d6gsq1uo0BIt74lO21min0PFqg8Zc2Wg4fzbshJf8U
# xC2btgUWcKWRp9RqtNelvRQfv4xd5T8aTAEDCciTVNruqdC6fQZhhHQXaVwU4QzN
# /FEMU0xahm491GL1X3YF1isL5jvJdpQZvh+pvkHTXxCttichXdP+nt2IpXnty9q4
# Z2HQ+HxoOwOfW6jZ5kcgtfF8sHoDRg30EhQ07g2g58JxF7hR9ga7XbZ7FAf997CF
# Y+IkKrEUex0pgzP/yzfu7/Cypbo5wyJRR76Z54CLGR+uwk8IM1jHKUCBgqiv6c4H
# 4F4hW/UCAwEAAaNGMEQwDgYDVR0PAQH/BAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUF
# BwMDMB0GA1UdDgQWBBSrZ7YSTAz6BulQsMnTjMRwILq9yzANBgkqhkiG9w0BAQUF
# AAOCAQEAxlF+82G9yTFayGMc8honYGrWXHPMJS8D6+dCGNDf+jtITFpkQzByQiWK
# CUZOffdjDnURIrg9DhJGelaGujEsLXt5RnIQXG+FnRWCNdRgeo+/0yMEoXN76RvS
# cBefqDtC1JONhgWFHxvhbnmgWOg/IUB6+FYcAT3/Ra8NrT0VP0Z4Hdb5YXKZ+gQr
# xHwnGWFoWOjsfS2/NLGE1MPIPdy+v/Aqq3YyLC2qYsboZk4z9wEEYB39QKVKJIrE
# 3UaDzunrs9xmD4oe7NRBU2pDBisCyjK6hWXVox+ldmdCYevVGe95i7qUJpZd8uJy
# wVpb6vrgxhRjMXt13rjUCL0Jt9WPBjGCAdMwggHPAgEBMDIwHjEcMBoGA1UEAwwT
# YXBwYy1wNjI1IENvZGUgU2lnbgIQbG8uhNAfmZtKU+9FTikRcDAJBgUrDgMCGgUA
# oHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYB
# BAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0B
# CQQxFgQUs5UE1gYtSLuR1QGr4mWrjO1YfjMwDQYJKoZIhvcNAQEBBQAEggEAoqie
# xuaoH65xYJDBR8mHY6j54uz09k2/LwwNhzIe5nOy3aW++2XLWPWCMCWbz81PEhXL
# L85nzd6zxFmyrT2Kl1xnWV3L7cDaneovTT/E5m3dr2+rdzaSpdYym4In6V0kH/BQ
# Qrj0BM90LYXGGp5tybtjoFrYLxZ/az6TchylYe7HSf344Gyck48x8yN8GU6eZH8a
# oho6wKe5Yuq79wvpyIb+sAS50p3a7fRTYn6D54p+5GtzQkkfym4l57oJp5i/OIGr
# ZhhZf2Os0NLsT1XcoujJvyEY4k0i7q0RvxnmkeK6aYwVNBOuBRxuwlYAEHMJ6UT4
# 8lRpN+l7jndTPgJOqw==
# SIG # End signature block
