$url = "https://go.dev/dl/go1.22.10.windows-amd64.msi"
$out = "$env:TEMP\go1.22.10.windows-amd64.msi"
Write-Host "Downloading Go 1.22.10..."
Invoke-WebRequest -Uri $url -OutFile $out -UseBasicParsing
Write-Host "Installing Go..."
msiexec /i $out /quiet /norestart
Write-Host "Go installation complete."
