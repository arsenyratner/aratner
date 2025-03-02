$scriptPath = (Get-Item $PSScriptRoot).parent.FullName + '\windows-imaging-tools'
try {
    Join-Path -Path $scriptPath -ChildPath "\WinImageBuilder.psm1" | Remove-Module -ErrorAction SilentlyContinue
    Join-Path -Path $scriptPath -ChildPath "\Config.psm1" | Remove-Module -ErrorAction SilentlyContinue
    Join-Path -Path $scriptPath -ChildPath "\UnattendResources\ini.psm1" | Remove-Module -ErrorAction SilentlyContinue
} finally {
    Join-Path -Path $scriptPath -ChildPath "\WinImageBuilder.psm1" | Import-Module
    Join-Path -Path $scriptPath -ChildPath "\Config.psm1" | Import-Module
    Join-Path -Path $scriptPath -ChildPath "\UnattendResources\ini.psm1" | Import-Module
}

$osname = '2019std'
$osver = '1809'
$image_path = "C:\vm\tmp-$($osname)-$($osver).qcow2"
$switchName = 'VM'
$wim_file_path = "D:\Users\Public\iso\Microsoft\w2019-1809-202211-install.wim"
$image = (Get-WimFileImagesInfo -WimFilePath $wim_file_path)[1]
$virtIOISOPath = "D:\Users\Public\iso\virtio-win-0.1.266.iso"
$virtIODownloadLink = "https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/archive-virtio/virtio-win-0.1.266-1/virtio-win-0.1.266.iso"
$extraDriversPath = "D:\git\drivers\$osname"
$UnattendResourcesPath = ($PSScriptRoot + '\UnattendResources')
$custom_resources_path = ($UnattendResourcesPath + '\CustomResources')
$custom_scripts_path = ($UnattendResourcesPath + '\CustomScripts')
$cloudbase_init_path = (Get-Item $PSScriptRoot).parent.FullName + '\cloudbase'
$cloudbase_init_msi_path = "D:\pub\Install\freesoft\cloudbase\CloudbaseInitSetup_1_1_6_x64.msi"
$ErrorActionPreference = "Stop"

$configFilePath = Join-Path $scriptPath "Examples\config.ini"

# The path were you want to create the config fille
New-WindowsImageConfig -ConfigFilePath $configFilePath

#This is an example how to automate the image configuration file according to your needs
Set-IniFileValue -Path $configFilePath -Section "Default" -Key "wim_file_path" -Value $wim_file_path
Set-IniFileValue -Path $configFilePath -Section "Default" -Key "image_name" -Value $image.ImageName
Set-IniFileValue -Path $configFilePath -Section "Default" -Key "image_path" -Value $image_path
Set-IniFileValue -Path $configFilePath -Section "Default" -Key "image_type" -Value "KVM"
Set-IniFileValue -Path $configFilePath -Section "Default" -Key "disk_layout" -Value "UEFI"
Set-IniFileValue -Path $configFilePath -Section "Default" -Key "install_maas_hooks" -Value "False"
Set-IniFileValue -Path $configFilePath -Section "Default" -Key "enable_administrator_account" -Value "True"
Set-IniFileValue -Path $configFilePath -Section "Default" -Key "custom_resources_path" -Value $custom_resources_path
Set-IniFileValue -Path $configFilePath -Section "Default" -Key "custom_scripts_path" -Value $custom_scripts_path
Set-IniFileValue -Path $configFilePath -Section "vm" -Key "cpu_count" -Value 6
Set-IniFileValue -Path $configFilePath -Section "vm" -Key "ram_size" -Value (8GB)
Set-IniFileValue -Path $configFilePath -Section "vm" -Key "disk_size" -Value (40GB)
Set-IniFileValue -Path $configFilePath -Section "vm" -Key "external_switch" -Value $switchName
Set-IniFileValue -Path $configFilePath -Section "drivers" -Key "virtio_iso_path" -Value $virtIOISOPath
Set-IniFileValue -Path $configFilePath -Section "drivers" -Key "drivers_path" -Value $extraDriversPath
Set-IniFileValue -Path $configFilePath -Section "custom" -Key "install_qemu_ga" -Value "True"
Set-IniFileValue -Path $configFilePath -Section "updates" -Key "install_updates" -Value "True"
Set-IniFileValue -Path $configFilePath -Section "updates" -Key "purge_updates" -Value "True"
Set-IniFileValue -Path $configFilePath -Section "sysprep" -Key "disable_swap" -Value "True"
Set-IniFileValue -Path $configFilePath -Section "cloudbase_init" -Key "cloudbase_init_use_local_system" -Value "True"
Set-IniFileValue -Path $configFilePath -Section "cloudbase_init" -Key "msi_path" -Value $cloudbase_init_msi_path
Set-IniFileValue -Path $configFilePath -Section "cloudbase_init" -Key "cloudbase_init_config_path" -Value "$cloudbase_init_path\cloudbase-init.conf"
Set-IniFileValue -Path $configFilePath -Section "cloudbase_init" -Key "cloudbase_init_unattended_config_path" -Value "$cloudbase_init_path\cloudbase-init-unattend.conf"
Set-IniFileValue -Path $configFilePath -Section "cloudbase_init" -Key "cloudbase_init_use_local_system" -Value "True"

# disable realtime protection
Set-MpPreference -DisableRealtimeMonitoring $true

# This scripts generates a raw tar.gz-ed image file, that can be used with MAAS
New-WindowsOnlineImage -ConfigFilePath $configFilePath
