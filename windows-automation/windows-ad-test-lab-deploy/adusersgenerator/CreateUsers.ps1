#
# Global variables
#
# load variables
. .\vars.ps1

#
write-debug "functions loaded"
Set-StrictMode -Version 2
$DebugPreference = "SilentlyContinue" # SilentlyContinue | Continue
Import-Module ActiveDirectory

# Set the working directory to the script's directory
Push-Location (Split-Path ($MyInvocation.MyCommand.Path))

[System.Collections.ArrayList]$phoneCountryCodes = @{"RU" = "+7"; "GB" = "+44"; "DE" = "+49"} # Country codes for the countries used in the address file

write-debug "files loaded"

# Check locationCount before importing Files else it chokes when it's set too high
if ($locationCount -ge $phoneCountryCodes.Count) {Write-Error ("ERROR: selected locationCount is higher than configured phoneCountryCodes2. You may want to configure $($phoneCountryCodes.Count-1) as max locationCount");continue}

function Translit {
   param([string]$inString)
   #Создаем хэш-таблицу соответствия русских и латинских символов
   $Translit = @{
       [char]'а' = "a"
       [char]'А' = "a"
       [char]'б' = "b"
       [char]'Б' = "b"
       [char]'в' = "v"
       [char]'В' = "v"
       [char]'г' = "g"
       [char]'Г' = "g"
       [char]'д' = "d"
       [char]'Д' = "d"
       [char]'е' = "e"
       [char]'Е' = "e"
       [char]'ё' = "e"
       [char]'Ё' = "e"
       [char]'ж' = "zh"
       [char]'Ж' = "zh"
       [char]'з' = "z"
       [char]'З' = "z"
       [char]'и' = "i"
       [char]'И' = "i"
       [char]'й' = "y"
       [char]'Й' = "y"
       [char]'к' = "k"
       [char]'К' = "k"
       [char]'л' = "l"
       [char]'Л' = "l"
       [char]'м' = "m"
       [char]'М' = "m"
       [char]'н' = "n"
       [char]'Н' = "n"
       [char]'о' = "o"
       [char]'О' = "o"
       [char]'п' = "p"
       [char]'П' = "p"
       [char]'р' = "r"
       [char]'Р' = "r"
       [char]'с' = "s"
       [char]'С' = "s"
       [char]'т' = "t"
       [char]'Т' = "t"
       [char]'у' = "u"
       [char]'У' = "u"
       [char]'ф' = "f"
       [char]'Ф' = "f"
       [char]'х' = "kh"
       [char]'Х' = "kh"
       [char]'ц' = "ts"
       [char]'Ц' = "ts"
       [char]'ч' = "ch"
       [char]'Ч' = "ch"
       [char]'ш' = "sh"
       [char]'Ш' = "sh"
       [char]'щ' = "sch"
       [char]'Щ' = "sch"
       [char]'ъ' = ""
       [char]'Ъ' = ""
       [char]'ы' = "y"
       [char]'Ы' = "y"
       [char]'ь' = ""
       [char]'Ь' = ""
       [char]'э' = "e"
       [char]'Э' = "e"
       [char]'ю' = "yu"
       [char]'Ю' = "yu"
       [char]'я' = "ya"
       [char]'Я' = "ya"
       [char]' ' = " " #пробел
   }
   $outString = "";
   $chars = $inString.ToCharArray();
   foreach ($char in $chars) {$outString += $Translit[$char]}
   return $outString;
}
#
# Read input files
#
$departments = @()
Import-Csv -path $departmentsFile -Delimiter ";" | ForEach-Object {
   $departments += @{"Name" = "$($_.Name)" ; Positions = $_.Positions -split "," ; "eMail" = "$($_.eMail)" }
}
$firstNames = Import-CSV $firstNameFile -Encoding utf7 
$lastNames = Import-CSV $lastNameFile -Encoding utf7 
$addresses = Import-CSV $addressFile -Encoding utf7 
$postalAreaCodesTemp = Import-CSV $postalAreaFile

# Convert the postal & phone area code object list into a hash
$postalAreaCodes = @{}
foreach ($row in $postalAreaCodesTemp)
{
   $postalAreaCodes[$row.PostalCode] = $row.PhoneAreaCode
}
$postalAreaCodesTemp = $null

write-debug "start preparation"

#
# Preparation
#
$securePassword = ConvertTo-SecureString -AsPlainText $initialPassword -Force

# Select the configured number of locations from the address list
$locations = @()
$addressIndexesUsed = @()
for ($i = 0; $i -le $locationCount; $i++) {
   # Determine a random address
   $addressIndex = -1
   do {
      $addressIndex = Get-Random -Minimum 0 -Maximum $addresses.Count
   } while ($addressIndexesUsed -contains $addressIndex)
   # Store the address in a location variable
   $street = $addresses[$addressIndex].Street
   $city = $addresses[$addressIndex].City
   $state = $addresses[$addressIndex].State
   $postalCode = $addresses[$addressIndex].PostalCode
   $country = $addresses[$addressIndex].Country
   $locations += @{"Street" = $street; "City" = $city; "State" = $state; "PostalCode" = $postalCode; "Country" = $country}
   # Do not use this address again
   $addressIndexesUsed += $addressIndex
}
#
# Create OUs
# объекты создаются в трёх OU, _resourses - для групп которым будут назначены права на общие ресурсы
# например, общей папке бухгалтерия будут назначено право modify для группы F_бухгалтерия_modify
# Folders - префикс F_, общие папки
# GPO - префикс GPO_ для групповых политик
# Printers - префикс PRT_ для общих принтеров
# Mail Lists - префикс ML_ -  для групп распространения (списков рассылки)
# lab OU 
Write-Debug "Create OUs"
$newOU=New-ADOrganizationalUnit -Name $labname -path $baseOU -PassThru
$OUs = @(
"Users",
"Computers",
"_Resources"
)
ForEach ($tmpou In $OUs) {
   New-ADOrganizationalUnit -Name $tmpou -Path "OU=$($labname),$($baseOU)"
}
$OUs = @(
"Folders",
"GPO",
"Mail Lists",
"Printers"
)
ForEach ($tmpou In $OUs) {
   New-ADOrganizationalUnit -Name $tmpou -Path "OU=_Resources,OU=$($labname),$($baseOU)"
}

#
# Create groups and shared folders
#
Write-Debug "Create Groups"

# группа в которую добавляют пользователей которым нужен доступ в сеть через ВПН
# Prefix=VPN_; Suffix=_allow Type=DL
$GroupName = "$($labname)_VPN_allow"
$GroupParams = @{
   Name = $GroupName
   GroupScope = "DomainLocal"
   GroupCategory = "Security"
   Path = "OU=_Resources,$($ou)"
}
New-ADGroup @GroupParams

# создадим группы для общих папок (_modify, _read, _list) и принтеров (_print, _manage) каждого отдела
$depindex=$departments.Count - 1
while ($depindex -ge 0) {
   $department = $departments[$depindex].Name
   $departmentEmail = $departments[$depindex].eMail
   #write-host "$($depindex): $department"
   # Prefix ORG_ type Global
   $GroupName = "$($labname)_ORG_$($department)"
   New-ADOrganizationalUnit -Name $($department) -Path "OU=Users,$ou"
   $GroupParams = @{
      Name = $GroupName
      GroupScope = "Global"
      GroupCategory = "Security"
      Path = "OU=$($department),OU=Users,$($ou)"
   }
   New-ADGroup @GroupParams
   # Prefix F_ type DL
   #OU=Folders,OU=_Resources,OU=_lab01,DC=ad,DC=aratner,DC=ru
   #группы для общей папки отдела
   $GroupName = "$($labname)_F_$($department)_read"
   #доступ только для чтения
   $GroupParams = @{
      Name = $GroupName
      GroupScope = "DomainLocal"
      GroupCategory = "Security"
      Path = "OU=Folders,OU=_Resources,$($ou)"
   }
   New-ADGroup @GroupParams
   $GroupName = "$($labname)_F_$($department)_modify"
   #доступ для изменения
   $GroupParams = @{
      Name = $GroupName
      GroupScope = "DomainLocal"
      GroupCategory = "Security"
      Path = "OU=Folders,OU=_Resources,$($ou)"
   }
   New-ADGroup @GroupParams
   $GroupName = "$($labname)_F_$($department)_list"
   #доступ получить список файлов
   $GroupParams = @{
      Name = $GroupName
      GroupScope = "DomainLocal"
      GroupCategory = "Security"
      Path = "OU=Folders,OU=_Resources,$($ou)"
   }
   New-ADGroup @GroupParams
   # Prefix=GPO_; Suffix=_apply;  Type=DL
   # группе разрешено применять политику
   $GroupName = "$($labname)_GPO_$($department)_apply"
   $GroupParams = @{
      Name = $GroupName
      GroupScope = "DomainLocal"
      GroupCategory = "Security"
      Path = "OU=GPO,OU=_Resources,$($ou)"
   }
   New-ADGroup @GroupParams
   # Prefix=ML_;  Type=Distr
   # список рассылки отдела
   $GroupName = "$($labname)_ML_$($department)"
   $GroupParams = @{
      Name = $GroupName
      GroupScope = "Global"
      GroupCategory = "Distribution"
      Path = "OU=Mail Lists,OU=_Resources,$($ou)"
      OtherAttributes = @{'mail'=$departmentEmail}
   }
   New-ADGroup @GroupParams
   # Prefix=PRT_; Suffix=_print, _manage;  Type=DL
   # Разрешение печатать на принтер отдела
   $GroupName = "$($labname)_PRT_$($department)_print"
   $GroupParams = @{
      Name = $GroupName
      GroupScope = "DomainLocal"
      GroupCategory = "Security"
      Path = "OU=Printers,OU=_Resources,$($ou)"
   }
   New-ADGroup @GroupParams
   # Разрешение управлять принтером отдела
   $GroupName = "$($labname)_PRT_$($department)_manage"
   $GroupParams = @{
      Name = $GroupName
      GroupScope = "DomainLocal"
      GroupCategory = "Security"
      Path = "OU=Printers,OU=_Resources,$($ou)"
   }
   New-ADGroup @GroupParams
   # create folder and set up acls
   # функция создаст папку и назначит разрешения трём группам
   # закоментить если папки создавать не надо
   SetFolderAcls "$($sharedfoldersrootpath)\$($labname)\_Отделы" $department "$($labname)_F"
$depindex--
}
#
# Create the users
#

#
# Randomly determine this user's properties
#

# Create (and overwrite) new array lists [0]
$CSV_Fname = New-Object System.Collections.ArrayList
$CSV_Lname = New-Object System.Collections.ArrayList

#Populate entire $firstNames and $lastNames into the array
$CSV_Fname.Add($firstNames)
$CSV_Lname.Add($lastNames)

# 
# Sex & name
$i = 0
if ($i -lt $userCount) {
    foreach ($firstname in $firstNames) {
      foreach ($lastname in $lastnames) {
         $Fname = ($CSV_Fname | Get-Random).FirstName
         $Lname = ($CSV_Lname | Get-Random).LastName
         write-debug "$i $Fname $Lname"
         #write-host "$Fname $Lname"
         #Capitalise first letter of each name
         $displayName = (Get-Culture).TextInfo.ToTitleCase($Lname + " " + $Fname)

         # Address
         $locationIndex = Get-Random -Minimum 0 -Maximum $locations.Count
         $street = $locations[$locationIndex].Street
         $city = $locations[$locationIndex].City
         $state = $locations[$locationIndex].State
         $postalCode = $locations[$locationIndex].PostalCode
         $country = $locations[$locationIndex].Country
         $matchcc = $phoneCountryCodes.GetEnumerator() | Where-Object {$_.Name -eq $country} # match the phone country code to the selected country above
         
         # Department & title
         $departmentIndex = Get-Random -Minimum 0 -Maximum $departments.Count
         $department = $departments[$departmentIndex].Name
         $title = $departments[$departmentIndex].Positions[$(Get-Random -Minimum 0 -Maximum $departments[$departmentIndex].Positions.Count)]
         # Phone number
         if ($matchcc.Name -notcontains $country) {
            Write-debug ("ERROR1: No country code found for $country")
            continue
         }
         if (-not $postalAreaCodes.ContainsKey($postalCode)) {
            Write-debug ("ERROR2: No country code found for $country")
            continue
         }
         $officePhone = $matchcc.Value + " " + $postalAreaCodes[$postalCode].Substring(1) + " " + (Get-Random -Minimum 100000 -Maximum 1000000)
         
         # Build the sAMAccountName: $orgShortName + employee number
         $employeeNumber = Get-Random -Minimum 100000 -Maximum 1000000
         #$sAMAccountName = $orgShortName + $employeeNumber
         $sAMAccountName = Translit($Fname.SubString(0,1) + $Lname)
         write-debug "sAMAccountName: $sAMAccountName"
         $userExists = $false
         Try   { $userExists = Get-ADUser -LDAPFilter "(sAMAccountName=$sAMAccountName)" }
         Catch { }
         if ($userExists) {
            $i=$i-1
            if ($i -lt 0)
            {$i=0}
            continue
         }

         #
         # Create the user account
         #
         $HashParams = @{
            SamAccountName = $sAMAccountName
            Name = $displayName
            Path = "OU=$department,OU=Users,$ou"
            AccountPassword = $securePassword
            Enabled = $true
            GivenName = $Fname
            Surname = $Lname
            DisplayName = $displayName
            EmailAddress = "$sAMAccountName@$emailDomain"
            StreetAddress = $street
            City = $city
            PostalCode = $postalCode
            State = $state
            Country = $country
            UserPrincipalName = "$sAMAccountName@$dnsDomain"
            Company = $company
            Department = $department
            EmployeeNumber = $employeeNumber
            Title = $title
            OfficePhone = $officePhone   
         }
         New-ADUser @HashParams 
         $GroupORG = "$($labname)_ORG_$($department)"
         Add-ADGroupMember -Identity $GroupORG -Members $sAMAccountName
         $GroupF = "$($labname)_F_$($department)_modify"
         Add-ADGroupMember -Identity $GroupF -Members $sAMAccountName
         $GroupGPO = "$($labname)_GPO_$($department)_apply"
         Add-ADGroupMember -Identity $GroupGPO -Members $sAMAccountName
         $GroupML = "$($labname)_ML_$($department)"
         Add-ADGroupMember -Identity $GroupML -Members $sAMAccountName
         $GroupPRT = "$($labname)_PRT_$($department)_print"
         Add-ADGroupMember -Identity $GroupPRT -Members $sAMAccountName

         #"Created user #" + ($i+1) + ", $displayName, $sAMAccountName, $title, $department, $officePhone, $country, $street, $city"
         $i = $i+1
         $employeeNumber = $employeeNumber+1

            if ($i -ge $userCount) 
         {
            "Script Complete. Exiting"
            exit
         }
         }
   }
}
