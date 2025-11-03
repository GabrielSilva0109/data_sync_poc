# Script para configurar e testar EventBridge com SAM

Write-Host "🚀 Setting up EventBridge Publisher/Subscriber with AWS SAM" -ForegroundColor Green
Write-Host "================================================================" -ForegroundColor Green

# Step 1: Update environment variables
Write-Host "`n1️⃣ Updating environment variables..." -ForegroundColor Cyan
$envContent = @"
# AWS Configuration
AWS_REGION=us-east-1
AWS_ENDPOINT=http://localhost:4566
AWS_ACCESS_KEY_ID=test
AWS_SECRET_ACCESS_KEY=test

# EventBridge Configuration
EVENT_BUS_NAME=data-sync-event-bus
EVENT_SOURCE=data-sync-poc.user-service

# Application Settings
USER_SERVICE_PORT=3000
NODE_ENV=development
"@

$envContent | Out-File -FilePath ".env" -Encoding UTF8
Write-Host "✅ Environment variables updated" -ForegroundColor Green

# Step 2: Install SAM CLI check
Write-Host "`n2️⃣ Checking AWS SAM CLI..." -ForegroundColor Cyan
try {
    $samVersion = sam --version
    Write-Host "✅ SAM CLI found: $samVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ AWS SAM CLI not found. Please install it first:" -ForegroundColor Red
    Write-Host "   - Windows: https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/install-sam-cli.html" -ForegroundColor Yellow
    exit 1
}

# Step 3: Build SAM application
Write-Host "`n3️⃣ Building SAM application..." -ForegroundColor Cyan
try {
    Push-Location "../data_sync"
    
    # Install dependencies
    Write-Host "   📦 Installing dependencies..." -ForegroundColor Yellow
    npm install
    
    # Build TypeScript
    Write-Host "   🔨 Building TypeScript..." -ForegroundColor Yellow
    npm run build
    
    Pop-Location
    
    # Build SAM template
    Write-Host "   🏗️ Building SAM template..." -ForegroundColor Yellow
    sam build
    
    Write-Host "✅ SAM application built successfully" -ForegroundColor Green
} catch {
    Write-Host "❌ Error building SAM application: $_" -ForegroundColor Red
    exit 1
}

# Step 4: Start SAM local
Write-Host "`n4️⃣ Starting SAM local..." -ForegroundColor Cyan
Write-Host "📋 This will start EventBridge simulation locally" -ForegroundColor Yellow
Write-Host "📋 Keep this terminal open and run tests in another terminal" -ForegroundColor Yellow

Write-Host "`nTo test the integration:" -ForegroundColor White
Write-Host "1. Keep this SAM local running" -ForegroundColor White
Write-Host "2. In another terminal, run: docker-compose up -d user-service" -ForegroundColor White
Write-Host "3. Test POST request: .\test-eventbridge.ps1" -ForegroundColor White

Write-Host "`nStarting SAM local..." -ForegroundColor Cyan
sam local start-api --host 0.0.0.0 --port 3001