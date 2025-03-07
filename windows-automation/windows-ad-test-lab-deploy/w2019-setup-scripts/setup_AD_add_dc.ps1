# load variables
. .\setup_variables.ps1

Install-WindowsFeature AD-Domain-Services -IncludeManagementTools -Verbose

$credential=New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $domainadmin, $adminpassword

$HashArguments = @{
    DomainName = $domainname
    InstallDns = $true
    NoGlobalCatalog = $false
    SiteName = $sitename
    NoRebootOnCompletion = $true 
    Force = $true
    SafeModeAdministratorPassword = $restorepassword
    Credential = $credential
    DatabasePath = $dbpath
    LogPath = $logpath
    SysvolPath = $sysvolpath
}

Install-ADDSDomainController @HashArguments -verbose
