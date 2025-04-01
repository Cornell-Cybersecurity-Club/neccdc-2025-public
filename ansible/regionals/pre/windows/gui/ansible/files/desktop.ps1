# Define the source directory where the shortcuts are located
$sourceDirectory = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Administrative Tools"

# Define the destination directory for the Public Desktop
$publicDesktopDirectory = [System.Environment]::GetFolderPath("CommonDesktopDirectory")

# Ensure the destination directory exists
if (-not (Test-Path -Path $publicDesktopDirectory)) {
    New-Item -Path $publicDesktopDirectory -ItemType Directory -Force
}

# Define the list of allowed shortcuts to be copied
$allowedShortcuts = @(
    "Active Directory Administrative Center.lnk",
    "Active Directory Domains and Trusts.lnk",
    "Active Directory Sites and Services.lnk",
    "Active Directory Users and Computers.lnk",
    "Certification Authority.lnk",
    "DNS.lnk",
    "Event Viewer.lnk",
    "Group Policy Management.lnk",
    "IIS Manager.lnk",
    "Performance Monitor.lnk",
    "Resource Monitor.lnk",
    "Server Manager.lnk",
    "Windows Defender Firewall with Advanced Security.lnk"
)

# Copy only the allowed shortcuts to the Public Desktop directory
foreach ($shortcutName in $allowedShortcuts) {
    $sourcePath = Join-Path -Path $sourceDirectory -ChildPath $shortcutName
    $destinationPath = Join-Path -Path $publicDesktopDirectory -ChildPath $shortcutName
    
    if (Test-Path -Path $sourcePath) {
        Copy-Item -Path $sourcePath -Destination $destinationPath -Force
    } else {
        Write-Host "Skipping: $shortcutName (Not Found in Source Directory)"
    }
}

Write-Host "Specified shortcuts copied to Public Desktop for all users."
