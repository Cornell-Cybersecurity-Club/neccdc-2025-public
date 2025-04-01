[CmdletBinding()]
param (
    [string[]]$GPONames
)

Import-Module GroupPolicy
$Ansible.Changed = $false

$Domain = Get-ADDomain | Select-Object -ExpandProperty DNSRoot
$DomainDN = Get-ADDomain | Select-Object -ExpandProperty DistinguishedName

Write-Output "[+] Creating and linking fake GPOs in $Domain"

$GPONames.GetType().FullName

foreach ($fake_gpo in $GPONames) {
    try {
        Write-Output "  [+] Found GPO $fake_gpo"

        New-GPO -Name $fake_gpo | New-GPLink -Target $DomainDN -LinkEnabled Yes | Out-Null
        $Ansible.Changed = $true
    } catch {
        if ($_.Exception.Message -match "GPO already exists in the") {
            continue
        } else {
            throw $_
        }
    }
}