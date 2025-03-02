# Copyright 2016 Cloudbase Solutions Srl
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.
Set-MpPreference -DisableRealtimeMonitoring $true

$ErrorActionPreference = "Stop"

$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition

try {
    Join-Path -Path $scriptPath -ChildPath "\WinImageBuilder.psm1" | Remove-Module -ErrorAction SilentlyContinue
    Join-Path -Path $scriptPath -ChildPath "\Config.psm1" | Remove-Module -ErrorAction SilentlyContinue
    Join-Path -Path $scriptPath -ChildPath "\UnattendResources\ini.psm1" | Remove-Module -ErrorAction SilentlyContinue
} finally {
    Join-Path -Path $scriptPath -ChildPath "\WinImageBuilder.psm1" | Import-Module
    Join-Path -Path $scriptPath -ChildPath "\Config.psm1" | Import-Module
    Join-Path -Path $scriptPath -ChildPath "\UnattendResources\ini.psm1" | Import-Module
}

$switchName = 'VM'
$osversion = "w2008r2std"
$windowsImagePath = "C:\vm\$($osversion)-image.qcow2"
$wimFilePath = "D:\Users\Public\iso\Microsoft\Windows Server 2008 R2\617403\sources\install.wim"
$virtIOISOPath = "D:\Users\Public\iso\virtio-win-0.1.118.iso"
$virtIODownloadLink = "https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/archive-virtio/virtio-win-0.1.118-2/virtio-win-0.1.118.iso"
$extraDriversPath = "D:\git\croc\aratner\windows-automation\2012r2\drivers"
# отличается от всех остальных
$image = (Get-WimFileImagesInfo -WimFilePath $wimFilePath)[0]

# The path were you want to create the config fille
$configFilePath = Join-Path $scriptPath "Examples\config.ini"
New-WindowsImageConfig -ConfigFilePath $configFilePath

#This is an example how to automate the image configuration file according to your needs
Set-IniFileValue -Path $configFilePath -Section "Default" -Key "wim_file_path" -Value $wimFilePath
Set-IniFileValue -Path $configFilePath -Section "Default" -Key "image_name" -Value $image.ImageName
Set-IniFileValue -Path $configFilePath -Section "Default" -Key "image_path" -Value $windowsImagePath
Set-IniFileValue -Path $configFilePath -Section "Default" -Key "image_type" -Value "KVM"
Set-IniFileValue -Path $configFilePath -Section "Default"  -Key "disk_layout" -Value "BIOS"
Set-IniFileValue -Path $configFilePath -Section "Default" -Key "install_maas_hooks" -Value "False"
Set-IniFileValue -Path $configFilePath -Section "Default" -Key "enable_administrator_account" -Value "True"
Set-IniFileValue -Path $configFilePath -Section "vm" -Key "cpu_count" -Value 6
Set-IniFileValue -Path $configFilePath -Section "vm" -Key "ram_size" -Value (8GB)
Set-IniFileValue -Path $configFilePath -Section "vm" -Key "disk_size" -Value (30GB)
Set-IniFileValue -Path $configFilePath -Section "vm" -Key "external_switch" -Value $switchName
# Set-IniFileValue -Path $configFilePath -Section "vm" -Key "disable_secure_boot" -Value "True"
Set-IniFileValue -Path $configFilePath -Section "drivers" -Key "virtio_iso_path" -Value $virtIOISOPath
Set-IniFileValue -Path $configFilePath -Section "drivers" -Key "drivers_path" -Value $extraDriversPath
Set-IniFileValue -Path $configFilePath -Section "updates" -Key "install_updates" -Value "True"
Set-IniFileValue -Path $configFilePath -Section "updates" -Key "purge_updates" -Value "True"
Set-IniFileValue -Path $configFilePath -Section "sysprep" -Key "disable_swap" -Value "True"
Set-IniFileValue -Path $configFilePath -Section "cloudbase_init" -Key "cloudbase_init_use_local_system" -Value "True"
Set-IniFileValue -Path $configFilePath -Section "cloudbase_init" -Key "msi_path" -Value "D:\pub\Install\freesoft\cloudbase\CloudbaseInitSetup_1_1_6_x64.msi"
Set-IniFileValue -Path $configFilePath -Section "cloudbase_init" -Key "cloudbase_init_config_path" -Value "D:\Users\Public\Install\freesoft\cloudbase\cloudbase-init.conf"
Set-IniFileValue -Path $configFilePath -Section "cloudbase_init" -Key "cloudbase_init_unattended_config_path" -Value "D:\Users\Public\Install\freesoft\cloudbase\cloudbase-init-unattend.conf"

# This scripts generates a raw tar.gz-ed image file, that can be used with MAAS
New-WindowsOnlineImage -ConfigFilePath $configFilePath
