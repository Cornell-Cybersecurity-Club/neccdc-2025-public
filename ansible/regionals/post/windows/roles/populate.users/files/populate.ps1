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

$UsersOUPath = "CN=Users,$DomainDN"
$GroupsOUPath = "CN=Users,$DomainDN"


# If UPN Suffix not blank, add it to the domain
#if ($UPNSuffix) {
#    $ExistingUPNSuffixes = (Get-ADForest).UPNSuffixes
#    if ($UPNSuffix -notin $ExistingUPNSuffixes) {
#        Get-ADForest | Set-ADForest -UPNSuffixes @{add = $UPNSuffix }
#        Write-Output "[+] Added UPN suffix $UPNSuffix to the domain"
#    } else {
#        Write-Output "[+] UPN suffix $UPNSuffix already exists"
#    }
#}

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
                #UserPrincipalName = $_.Email
                UserPrincipalName = "$($_.Username)@$Domain"
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
    foreach ($Group in $Groups) {
        try {
            New-ADGroup -Name $Group -GroupCategory Security -GroupScope Global -Description "PLACEBO PHARMA" -Path $GroupsOUPath
        } catch {
            if ($_.Exception.Message -match "already exists") {
                Write-Output "[+] Group '$Group' already exists"
                continue
            } else {
                Write-Output "[+] An error occurred while creating '$Group': $_"
            }
        } finally {
            # Add users to the group
            $Users = Get-ADUser -Filter { Department -eq $Group }
            if ($Users) {
                Add-ADGroupMember -Identity $Group -Members $Users
            }
        }
    }

    Write-Output "[+] Adding IT employees to respective admin groups"

    # Retrieve IT Employees with relevant properties
    $ITEmployees = Get-ADUser -Filter { (Department -eq "IT") -or (Title -eq "CTO") } -Properties Title

    # Define Role-to-Group Mapping
    $RoleMapping = @{
        "Enterprise Admins"           = "CTO|IT Manager|System Administrator"
        "Domain Admins"               = "CTO|IT Manager|System Administrator|SOC Analyst|Network Administrator"
        "Group Policy Creator Owners" = "CTO|IT Manager|System Administrator|Operations Security|Security Engineer"
        "Schema Admins"               = "CTO|IT Manager|System Administrator|Operations Security"
        "DnsAdmins"                   = "CTO|IT Manager|System Administrator|Operations Security|Network Administrator"
        "Key Admins"                  = "CTO|IT Manager|System Administrator|Operations Security|Network Administrator"
        "Cert Publishers"             = "CTO|IT Manager|System Administrator|Operations Security|Network Administrator"
    }

    try {
        foreach ($Group in $RoleMapping.Keys) {
            $Members = $ITEmployees | Where-Object { $_.Title -match $RoleMapping[$Group] }
            if ($Members) {
                Add-ADGroupMember -Identity $Group -Members $Members
                Write-Output "[+] Added members to '$Group'"
            }
        }
    } catch {
        Write-Output "An error occurred while adding members to groups: $_"
    }

} else {
    Write-Output "[+] Skipping group creation"
}
