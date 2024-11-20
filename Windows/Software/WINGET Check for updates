cls
$scriptName = "WINGET check for upgrades"
$logFolder = "C:\temp\scripts\$scriptName"
$logFile = "{0}\{1}-{2:MM-dd-yy---hh-mm--ss-tt}.log" -f $logFolder, $scriptName, (Get-Date)

# Create the log folder if it doesn't exist
if (-not (Test-Path $logFolder)) {
    New-Item -ItemType Directory -Path $logFolder | Out-Null
}

# Check if running with admin privileges, and elevate if not
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    $arguments = "-ExecutionPolicy Bypass -NoProfile -File `"$PSCommandPath`""
    Start-Process -FilePath "powershell.exe" -ArgumentList $arguments -Verb RunAs
    Exit
}

# Function to check if Winget is installed
function IsWingetInstalled() {
    $wingetPath = Get-Command -Name 'winget' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source
    return [bool]$wingetPath
}

# Function to install dependencies
function install-depends {
    # Check if Microsoft.UI.Xaml.2.7 framework is installed and install it if needed
    Write-Host "Installing Microsoft.UI.Xaml.2.7 framework (if required)"
    $frameworkPackageUrl = "https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx"
    $frameworkPackagePath = "C:\temp\scripts\$scriptName\Microsoft.VCLibs.x64.14.00.Desktop.appx"
    $frameworkLicenseUrl = "https://aka.ms/VCLibsDependency.14.00.appx"
    $frameworkLicensePath = "C:\temp\scripts\$scriptName\VCLibsDependency.14.00.appx"
    $license_path = "C:\temp\scripts\$scriptName\winget-license.xml"
    $license_url = "https://github.com/microsoft/winget-cli/releases/download/v1.6.1573-preview/ba27c402ae29410eb93cfa9cb27f1376_License1.xml"
    
    # Download required packages and license files
    Invoke-WebRequest -Uri $license_url -OutFile $license_path -ErrorAction Stop
    Invoke-WebRequest -Uri $frameworkPackageUrl -OutFile $frameworkPackagePath -ErrorAction Stop
    Invoke-WebRequest -Uri $frameworkLicenseUrl -OutFile $frameworkLicensePath -ErrorAction Stop
    
    # Install dependencies
    Write-Host "Installing dependencies"
    Add-AppxProvisionedPackage -Online -PackagePath $frameworkPackagePath -LicensePath $license_path
}

# Function to install Winget
function Install-WinGet {
    Set-ExecutionPolicy RemoteSigned
    install-depends

    $wingetInstallerUrl = "https://github.com/microsoft/winget-cli/releases/download/v1.6.1573-preview/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
    $wingetInstallerPath = "C:\temp\scripts\$scriptName\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"

    Write-Host "Downloading Winget installer"
    Invoke-WebRequest -Uri $wingetInstallerUrl -OutFile $wingetInstallerPath -ErrorAction Stop

    Write-Host "Installing Winget"
    Add-AppxPackage -Path $wingetInstallerPath -ForceUpdateFromAnyVersion -ForceTargetApplicationShutdown
}

# Winget function
function run-winget-command {
    $command = "winget"
    $arguments = "upgrade"

    Write-Host "Running Winget upgrade check"
    & $command $arguments --disable-interactivity --accept-source-agreements --include-unknown *>&1 | Out-Default
}

# Start logging
Start-Transcript -Path $logFile

# Install dependencies and check Winget installation
install-depends

if (-not (IsWingetInstalled)) {
    Write-Host "Winget is not installed on this system. Installing Winget."
    Install-WinGet
}

# Run the Winget command to check for upgrades
run-winget-command

# Stop logging
Stop-Transcript
