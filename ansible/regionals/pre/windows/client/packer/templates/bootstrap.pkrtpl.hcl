<powershell>
# Allow time for Windows to initialize fully
Start-Sleep -Seconds 180

# Set administrator password
net user ${windows_username} ${windows_password}
wmic useraccount where "name='${windows_username}'" set PasswordExpires=FALSE

# Log WinRM setup progress
Write-Host "Starting WinRM configuration..."

# Delete any existing WinRM listeners
winrm delete winrm/config/listener?Address=*+Transport=HTTP  2>$Null
winrm delete winrm/config/listener?Address=*+Transport=HTTPS 2>$Null

# Disable group policies which block basic authentication and unencrypted login
try {
    Set-ItemProperty -Path HKLM:\Software\Policies\Microsoft\Windows\WinRM\Client -Name AllowBasic -Value 1 -ErrorAction SilentlyContinue
    Set-ItemProperty -Path HKLM:\Software\Policies\Microsoft\Windows\WinRM\Client -Name AllowUnencryptedTraffic -Value 1 -ErrorAction SilentlyContinue
    Set-ItemProperty -Path HKLM:\Software\Policies\Microsoft\Windows\WinRM\Service -Name AllowBasic -Value 1 -ErrorAction SilentlyContinue
    Set-ItemProperty -Path HKLM:\Software\Policies\Microsoft\Windows\WinRM\Service -Name AllowUnencryptedTraffic -Value 1 -ErrorAction SilentlyContinue
    Write-Host "Group policies configured"
} catch {
    Write-Host "Warning: Could not configure all group policies: $($_.Exception.Message)"
}

# Create a new WinRM listener and configure
winrm create winrm/config/listener?Address=*+Transport=HTTP
winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="0"}'
winrm set winrm/config '@{MaxTimeoutms="7200000"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service '@{MaxConcurrentOperationsPerUser="12000"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/client/auth '@{Basic="true"}'

# Configure UAC to allow privilege elevation in remote shells
$Key = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
$Setting = 'LocalAccountTokenFilterPolicy'
Set-ItemProperty -Path $Key -Name $Setting -Value 1 -Force

# Configure and restart the WinRM Service; Enable the required firewall exception
Stop-Service -Name WinRM -Force
Set-Service -Name WinRM -StartupType Automatic
netsh advfirewall firewall set rule name="Windows Remote Management (HTTP-In)" new action=allow localip=any remoteip=any
Start-Service -Name WinRM

# Wait for service to fully start and test connectivity
Start-Sleep -Seconds 30
$winrmStatus = Get-Service -Name WinRM
Write-Host "WinRM Service Status: $($winrmStatus.Status)"

# Test WinRM listener
try {
    $listener = winrm enumerate winrm/config/listener
    Write-Host "WinRM Listener configured successfully"
    Write-Host $listener
} catch {
    Write-Host "Warning: WinRM listener test failed: $($_.Exception.Message)"
}

Write-Host "WinRM configuration completed"
</powershell>