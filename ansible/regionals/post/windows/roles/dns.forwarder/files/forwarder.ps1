[CmdletBinding()]
param (
    [IPAddress[]]$IPAddresses
)

Import-Module DnsServer
$Ansible.Changed = $false

try {
    Set-DnsServerForwarder -IPAddress $IPAddresses
    $Ansible.Changed = $true
} catch {
    throw $_
}