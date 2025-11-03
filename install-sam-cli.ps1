# Script para instalar AWS SAM CLI no Windows

Write-Host "🚀 Installing AWS SAM CLI for Windows" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

if (-not $isAdmin) {
    Write-Host "⚠️  This script needs to run as Administrator" -ForegroundColor Yellow
    Write-Host "   Please right-click PowerShell and 'Run as Administrator'" -ForegroundColor Yellow
    Write-Host "   Then run this script again" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Running as Administrator" -ForegroundColor Green

# Method 1: Try using Chocolatey (if available)
Write-Host "`n1️⃣ Checking for Chocolatey..." -ForegroundColor Cyan
try {
    choco --version | Out-Null
    Write-Host "✅ Chocolatey found. Installing SAM CLI..." -ForegroundColor Green
    choco install aws-sam-cli -y
    
    # Verify installation
    sam --version
    Write-Host "✅ SAM CLI installed successfully via Chocolatey!" -ForegroundColor Green
    exit 0
} catch {
    Write-Host "❌ Chocolatey not found" -ForegroundColor Red
}

# Method 2: Download and install MSI directly
Write-Host "`n2️⃣ Downloading SAM CLI MSI installer..." -ForegroundColor Cyan

$downloadUrl = "https://github.com/aws/aws-sam-cli/releases/latest/download/AWS_SAM_CLI_64_PY3.msi"
$installerPath = "$env:TEMP\AWS_SAM_CLI_64_PY3.msi"

try {
    Write-Host "   📥 Downloading from GitHub releases..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri $downloadUrl -OutFile $installerPath -UseBasicParsing
    
    Write-Host "   📦 Installing SAM CLI..." -ForegroundColor Yellow
    Start-Process msiexec.exe -ArgumentList "/i", $installerPath, "/quiet", "/norestart" -Wait
    
    # Add to PATH if needed
    $samPath = "${env:ProgramFiles}\Amazon\AWSSAMCLI\bin"
    if (Test-Path $samPath) {
        $currentPath = [Environment]::GetEnvironmentVariable("PATH", [EnvironmentVariableTarget]::Machine)
        if ($currentPath -notlike "*$samPath*") {
            Write-Host "   🔧 Adding SAM CLI to PATH..." -ForegroundColor Yellow
            [Environment]::SetEnvironmentVariable("PATH", "$currentPath;$samPath", [EnvironmentVariableTarget]::Machine)
        }
    }
    
    # Refresh environment
    $env:PATH = [Environment]::GetEnvironmentVariable("PATH", [EnvironmentVariableTarget]::Machine)
    
    # Verify installation
    Write-Host "`n3️⃣ Verifying installation..." -ForegroundColor Cyan
    sam --version
    Write-Host "✅ SAM CLI installed successfully!" -ForegroundColor Green
    
    # Clean up
    Remove-Item $installerPath -ErrorAction SilentlyContinue
    
} catch {
    Write-Host "❌ Error installing SAM CLI: $_" -ForegroundColor Red
    Write-Host "`n📋 Manual installation steps:" -ForegroundColor Yellow
    Write-Host "1. Download MSI from: https://github.com/aws/aws-sam-cli/releases/latest" -ForegroundColor White
    Write-Host "2. Look for 'AWS_SAM_CLI_64_PY3.msi'" -ForegroundColor White
    Write-Host "3. Run the MSI installer" -ForegroundColor White
    Write-Host "4. Restart PowerShell and try again" -ForegroundColor White
    exit 1
}

Write-Host "`n🎉 Installation complete!" -ForegroundColor Green
Write-Host "📋 You can now run: .\setup-eventbridge.ps1" -ForegroundColor White