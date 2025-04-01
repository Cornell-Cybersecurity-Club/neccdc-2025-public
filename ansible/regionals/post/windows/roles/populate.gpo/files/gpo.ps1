[CmdletBinding()]
param (
    [string]$GPOPath  = "C:\temp\gpo\"
)

Import-Module GroupPolicy
$Ansible.Changed = $false

$Domain = Get-ADDomain | Select-Object -ExpandProperty DNSRoot
$DomainDN = Get-ADDomain | Select-Object -ExpandProperty DistinguishedName

Write-Output "[+] Creating and linking GPOs in $Domain"

foreach ($policyFolder in Get-ChildItem -Path $GPOPath -Directory) { 
    foreach ($gpo in Get-ChildItem -Path $policyFolder.FullName -Directory) {
        $BackupXmlPath = Join-Path -Path $gpo.FullName -ChildPath "Backup.xml"

        if (Test-Path $BackupXmlPath) {
            $GPOName = Select-String -Path $BackupXmlPath -Pattern "(?<=<DisplayName><!\[CDATA\[)(.*?)(?=\]\])"
            $GPOName = $GPOName.Matches.Value

            Write-Output "  [+] Found GPO $GPOName in folder '$($policyFolder.Name)'"

            try {
                Import-GPO -BackupId $gpo.Name.Substring(1, 36) -TargetName $GPOName -Path $policyFolder.FullName -CreateIfNeeded | Out-Null

                # If GPOName is not Default Domain Policy or Default Domain Controllers Policy, link it to the appropriate OU
                if ($GPOName -notmatch "Default Domain Policy|Default Domain Controllers Policy") {
                    New-GPLink -Name $GPOName -Target $DomainDN -LinkEnabled Yes | Out-Null
                    $Ansible.Changed = $true
                }
            } catch {
                if ($_.Exception.Message -match "already linked to a Scope of Management with Path") {
                    continue
                } else {
                    throw $_
                }
            }
        } else {
            Write-Warning "  [!] Backup.xml not found for GPO in '$($gpo.FullName)'"
        }
    }
}
