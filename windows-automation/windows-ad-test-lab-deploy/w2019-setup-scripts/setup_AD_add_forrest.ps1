# load variables
. .\setup_variables.ps1

Install-WindowsFeature AD-Domain-Services -IncludeManagementTools -Verbose

$credential=New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $domainadmin, $adminpassword

$HashArguments = @{
  DomainName = $domainname
  DomainMode = $domainmode
  ForestMode = $domainmode
  DomainNetbiosName = $nbname
  SafeModeAdministratorPassword = $restorepassword
  InstallDns = $true
  NoRebootOnCompletion = $true
  DatabasePath = $dbpath
  LogPath = $logpath
  SysvolPath = $sysvolpath
}

Install-ADDSForest @HashArguments -verbose -force
