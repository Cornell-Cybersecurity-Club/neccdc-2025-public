#Requires -Modules ActiveDirectory

[CmdletBinding()]
param (
    [String]
    $LockoutThreshold = 120,

    [String]
    $MinLength = 2,

    [String]
    $LockoutDuration = "0:0:0:0.0",

    [String]
    $LockoutObservationWindow = "0:0:0:0.0",

    [Boolean]
    $ComplexityEnabled = $false,

    [Boolean]
    $ReversibleEncryptionEnabled = $true
)

try {
    $RootDSE = Get-ADRootDSE
    $PasswordPolicyParams = @{
        Identity                      = $RootDSE.defaultNamingContext
        AuthType                      = "Negotiate"
        LockoutDuration               = $LockoutDuration
        LockoutObservationWindow      = $LockoutObservationWindow
        LockoutThreshold              = $LockoutThreshold
        ComplexityEnabled             = $ComplexityEnabled
        ReversibleEncryptionEnabled   = $ReversibleEncryptionEnabled
        MinPasswordLength             = $MinLength
        MaxPasswordAge                = "10675199.00:00:00"
    }
    
    Set-ADDefaultDomainPasswordPolicy @PasswordPolicyParams    
}
catch {
    $Ansible.Failed = $true
    $Ansible.Message = $_.Exception.Message
}