import-module Active-Diretory

$File = Import-Csv -delimiter ';' -path c:\WSC2019_TP39_Module_B_Users.csv

$File|Select-Object|Sort-Object 'Organizational Unit' -Unique|Select-Object 'Organizational Unit'|ForEach-Object {
    New-ADOrganizationalUnit -Name $_.'Organizational Unit'
}

$File|Select-Object|Sort-Object 'Group','Organizational Unit' -Unique|Select-Object 'Group','Organizational Unit'|ForEach-Object {
    New-ADGroup -Name $_.Group -Path "OU=$($_.'Organizational Unit'),dc=wsc2019,dc=ru"
}

$File|ForEach-Object {
    New-ADUser `
    -Name ($_.'Given Name'+' '+$_.Surname) `
    -AccountPassword (ConvertTo-SecureString $_.Password -AsPlainText -Force) `
    -ChangePasswordAtLogin:$false
    -City $_.City `
    -Company $_.Company `
    -DisplayName ($_.'Given Name'+' '+$_.Surname) `
    -EmailAddress $_.'E-Mail' `
    -Enabled $true `
    -GivenName $_.'Given Name' `
    -HomeDirectory '\\dc2\Homes\%username%' `
    -HomeDrive 'G:\' `
    -PasswordNeverExpires $true `
    -Path ("ou="+$_."organizational unit"+",dc=wsc2019,dc=ru") `
    -SamAccountName $_.ID `
    -UserPrincipalName ($_.ID+'@wsc2019.ru') `
    -Surname $_.Surname `
    -Title $.'Job Title'
    Add-ADGroupMember -Identity $_.Group -Members $_.ID
}

