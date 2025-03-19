# Define the URL to download the Speedtest CLI zip file
$SpeedtestUrl = "https://install.speedtest.net/app/cli/ookla-speedtest-1.2.0-win64.zip"

# Define the temporary folder to store the Speedtest CLI tool
$TempFolder = [System.IO.Path]::Combine($env:TEMP, "SpeedtestCLI")
$SpeedtestPath = [System.IO.Path]::Combine($TempFolder, "speedtest.exe")

# Check if the temporary folder exists, if not create it
if (-not (Test-Path $TempFolder)) {
    New-Item -ItemType Directory -Path $TempFolder
}

# Check if Speedtest CLI is already downloaded
if (-not (Test-Path $SpeedtestPath)) {
    Write-Host "Downloading Speedtest CLI..."
    
    # Download the Speedtest CLI zip file
    $ZipFile = [System.IO.Path]::Combine($TempFolder, "speedtest.zip")
    Invoke-WebRequest -Uri $SpeedtestUrl -OutFile $ZipFile

    # Extract the zip file
    Write-Host "Extracting Speedtest CLI..."
    Expand-Archive -Path $ZipFile -DestinationPath $TempFolder -Force

    # Clean up the zip file after extraction
    Remove-Item -Path $ZipFile
}

# Define the output format (json)
$OutputFormat = "json"

# Run the speedtest with the specified output format and capture the output
Write-Host "Running Speedtest..."
$SpeedtestOutput = & $SpeedtestPath --accept-license --format=$OutputFormat

# Convert the JSON output to a PowerShell object
$SpeedtestJson = $SpeedtestOutput | ConvertFrom-Json

# Format and display the results
Write-Host "`nSpeedtest Results:"
Write-Host "---------------------"
Write-Host "Ping: $($SpeedtestJson.ping.latency) ms (Jitter: $($SpeedtestJson.ping.jitter) ms)"
Write-Host "Download Speed: $([math]::round($SpeedtestJson.download.bandwidth / 1MB, 2)) Mbps"
Write-Host "Upload Speed: $([math]::round($SpeedtestJson.upload.bandwidth / 1MB, 2)) Mbps"
Write-Host "Packet Loss: $($SpeedtestJson.packetLoss)%"
Write-Host "ISP: $($SpeedtestJson.isp)"
Write-Host "Server: $($SpeedtestJson.server.name), $($SpeedtestJson.server.location)"
Write-Host "Result URL: $($SpeedtestJson.result.url)"

Write-Host "Speed test completed"
