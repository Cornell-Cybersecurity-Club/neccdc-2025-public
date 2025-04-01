[CmdletBinding()]
param (
    [Switch]
    $CreateUsers,
    [Switch]
    $CreateGroups
)

$Data = Import-Csv -Path "C:\users.csv"
$Domain = Get-ADDomain | Select-Object -ExpandProperty DNSRoot
$DomainDN = Get-ADDomain | Select-Object -ExpandProperty DistinguishedName
$UPNSuffix = "placebo-pharma.com"

$UsersOUPath = "CN=Users,$DomainDN"
$GroupsOUPath = "CN=Users,$DomainDN"


Get-ADForest | Set-ADForest -UPNSuffixes @{add = $UPNSuffix }
Write-Output "[+] Added UPN suffix $UPNSuffix to the domain"

if ($CreateUsers) {
    Write-Output "[+] Creating bulk users in $Domain"
    foreach ($_ in $Data) {
        try {           
            $splat = @{
                AccountPassword   = $(ConvertTo-SecureString -String $_.Password -AsPlainText -Force)
                Company           = "Placebo Pharma"
                Department        = $_.Department
                Name              = "$($_.GivenName) $($_.Surname)"
                DisplayName       = "$($_.GivenName) $($_.Surname)"
                GivenName         = $_.GivenName
                Surname           = $_.Surname
                SamAccountName    = $_.Username
                UserPrincipalName = $_.Email
                Title             = $_.JobTitle
                Path              = $UsersOUPath
                Enabled           = $true
            }
            New-ADUser @splat
        } catch {
            if ($_.Exception.Message -match "already exists") {
                Write-Output "[+] Users already exists"
                break
            } else {
                Write-Output "[+] An error occurred: $_"
            }
        }
    }
} else {
    Write-Output "[+] Skipping user creation"
}

if ($CreateGroups) {
    Write-Output "[+] Creating bulk groups in $Domain"
    $Groups = $Data | Select-Object -ExpandProperty Department | Sort-Object -Unique
    foreach ($_ in $Groups) {
        try {
            New-ADGroup -Name $_ -GroupCategory Security -GroupScope Global -Description "PLACEBO PHARMA" -Path $GroupsOUPath
        } catch {
            if ($_.Exception.Message -match "already exists") {
                Write-Output "[+] Groups already exists"
                break
            } else {
                Write-Output "[+] An error occurred: $_"
            }
        } finally {
            # Add all users to the group
            $Users = Get-ADUser -Filter { Department -eq $_ }
            Add-ADGroupMember -Identity $_ -Members $Users
        }
    }

    Write-Output "[+] Adding IT employees to respective admin groups"
    $ITEmployees = Get-ADUser -Filter { (Department -eq "IT") -or (Title -eq "CTO") } -Properties Department, Title
    try {
        Add-ADGroupMember -Identity "Enterprise Admins" -Members $($ITEmployees | Where-Object { $_.Title -match "CTO|IT Manager" })
        Add-ADGroupMember -Identity "Domain Admins" -Members $($ITEmployees | Where-Object { $_.Title -match "CTO|IT Manager|System Administrator" })
        Add-ADGroupMember -Identity "Group Policy Creator Owners" -Members $($ITEmployees | Where-Object { $_.Title -match "CTO|IT Manager|System Administrator|Operations Security|Security Engineer" })
        Add-ADGroupMember -Identity "Schema Admins" -Members $($ITEmployees | Where-Object { $_.Title -match "CTO|IT Manager|System Administrator|Operations Security" })
        Add-ADGroupMember -Identity "DnsAdmins" -Members $($ITEmployees | Where-Object { $_.Title -match "CTO|IT Manager|System Administrator|Operations Security|Network Administrator" })
        Add-ADGroupMember -Identity "Key Admins" -Members $($ITEmployees | Where-Object { $_.Title -match "CTO|IT Manager|System Administrator|Operations Security|Network Administrator" })
        Add-ADGroupMember -Identity "Cert Publishers" -Members $($ITEmployees | Where-Object { $_.Title -match "CTO|IT Manager|System Administrator|Operations Security|Network Administrator" })    
    } catch {
        Write-Output "An error occurred: $_"
    }
} else {
    Write-Output "[+] Skipping group creation"
}