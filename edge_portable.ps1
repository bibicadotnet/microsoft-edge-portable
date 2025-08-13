# Microsoft Edge Portable with Chrome++ Auto Installer
# Downloads Edge and Chrome Plus, installs to C:\Edge_Portable

# Check admin rights
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -Command `"irm https://go.bibica.net/edge_portable | iex`"" -Verb RunAs
    exit
}

Clear-Host
Write-Host "Microsoft Edge Stable Portable with Chrome++ Auto Installer" -ForegroundColor Green

$portablePath = "C:\Edge_Portable"
$edgePath = "$portablePath\Edge"
$tempDir = "$env:TEMP\EdgeInstaller"
$originalPath = Get-Location

# Get release info
$edgeRelease = Invoke-RestMethod "https://api.github.com/repos/bibicadotnet/edge_installer/releases/latest"
$edgeDownloadUrl = $edgeRelease.assets | Where-Object { $_.name -match "MicrosoftEdge_X64_.+\.exe" } | Select-Object -First 1 -ExpandProperty browser_download_url
$edgeFileName = $edgeRelease.assets | Where-Object { $_.name -match "MicrosoftEdge_X64_.+\.exe" } | Select-Object -First 1 -ExpandProperty name
$edgeVersion = $edgeRelease.tag_name

$chromePlusRelease = Invoke-RestMethod "https://api.github.com/repos/Bush2021/chrome_plus/releases/latest"
$chromePlusDownloadUrl = $chromePlusRelease.assets | Where-Object { $_.name -eq "setdll.7z" } | Select-Object -First 1 -ExpandProperty browser_download_url
$chromePlusVersion = $chromePlusRelease.tag_name

# Prepare directories
if (Test-Path $tempDir) { Remove-Item $tempDir -Recurse -Force }
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
if (-not (Test-Path $portablePath)) { New-Item -ItemType Directory -Path $portablePath -Force | Out-Null }
if (Test-Path $edgePath) { Remove-Item $edgePath -Recurse -Force }
New-Item -ItemType Directory -Path $edgePath -Force | Out-Null

# Download files
Write-Host "`nDownloading Edge Stable v$edgeVersion..." -ForegroundColor Yellow
(New-Object System.Net.WebClient).DownloadFile($edgeDownloadUrl, "$tempDir\$edgeFileName")
(New-Object System.Net.WebClient).DownloadFile("https://www.7-zip.org/a/7zr.exe", "$tempDir\7zr.exe")

Write-Host "Downloading Chrome++ $chromePlusVersion..." -ForegroundColor Yellow
(New-Object System.Net.WebClient).DownloadFile($chromePlusDownloadUrl, "$tempDir\setdll.7z")
(New-Object System.Net.WebClient).DownloadFile("https://raw.githubusercontent.com/bibicadotnet/microsoft-edge-portable/refs/heads/main/chrome%2B%2B.ini", "$edgePath\chrome++.ini")

# Extract Edge
Write-Host "Extracting Edge..." -ForegroundColor Yellow
$sevenZPath = "$tempDir\7zr.exe"
$extractDir = "$tempDir\extract"
& $sevenZPath x "$tempDir\$edgeFileName" "-o$extractDir" -y | Out-Null

$msedge7z = Get-ChildItem -Path $extractDir -Name "MSEDGE.7z" -Recurse | Select-Object -First 1
$msedgeDir = "$tempDir\msedge"
& $sevenZPath x "$extractDir\$msedge7z" "-o$msedgeDir" -y | Out-Null

# Extract Chrome Plus
Write-Host "Extracting Chrome++..." -ForegroundColor Yellow
$chromePlusExtractDir = "$tempDir\chromeplus"
& $sevenZPath x "$tempDir\setdll.7z" "-o$chromePlusExtractDir" -y | Out-Null

# Install Edge
Write-Host "Installing Edge..." -ForegroundColor Yellow
$versionFolder = Get-ChildItem -Path $msedgeDir -Directory -Recurse | Where-Object { $_.Name -match "^\d+\.\d+\.\d+\.\d+$" } | Select-Object -First 1
Copy-Item $versionFolder.FullName "$edgePath\$($versionFolder.Name)" -Recurse -Force

$sourceFile = Get-ChildItem -Path $msedgeDir -Name "msedge.exe" -Recurse | Select-Object -First 1
Copy-Item "$msedgeDir\$sourceFile" "$edgePath\msedge.exe" -Force

# Install Chrome Plus
Write-Host "Installing Chrome++..." -ForegroundColor Yellow
Copy-Item "$chromePlusExtractDir\setdll-x64.exe" "$edgePath\setdll-x64.exe" -Force
Copy-Item "$chromePlusExtractDir\version-x64.dll" "$edgePath\version-x64.dll" -Force

# Apply Chrome Plus
Write-Host "Applying Chrome++..." -ForegroundColor Yellow
Set-Location $edgePath
& ".\setdll-x64.exe" /d:version-x64.dll msedge.exe | Out-Null
Set-Location $originalPath

# Cleanup temp files and installer remnants
Remove-Item $tempDir -Recurse -Force
Remove-Item "$edgePath\setdll-x64.exe", "$edgePath\msedge.exe~" -Force -ErrorAction SilentlyContinue

Write-Host "`nInstallation Complete!" -ForegroundColor Green
Write-Host "Run: $edgePath\msedge.exe" -ForegroundColor Cyan
Write-Host ""
