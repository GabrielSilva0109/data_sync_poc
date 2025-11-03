# Script para testar o fluxo completo EventBridge

Write-Host "🧪 Testing EventBridge Publisher/Subscriber Flow" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green

# Step 1: Test subscriber function directly
Write-Host "`n1️⃣ Testing subscriber function with sample event..." -ForegroundColor Cyan
try {
    Push-Location "../data_sync"
    
    Write-Host "   📧 Invoking Lambda function with test event..." -ForegroundColor Yellow
    sam local invoke DataSyncSubscriberFunction --event event.json
    
    Pop-Location
    Write-Host "✅ Subscriber function test completed" -ForegroundColor Green
} catch {
    Write-Host "❌ Error testing subscriber function: $_" -ForegroundColor Red
}

# Step 2: Test publisher (user-service)
Write-Host "`n2️⃣ Testing publisher (user-service)..." -ForegroundColor Cyan

# Check if user-service is running
try {
    $health = Invoke-WebRequest -Uri "http://localhost:3000/health" -UseBasicParsing -TimeoutSec 5
    Write-Host "✅ User service is running" -ForegroundColor Green
} catch {
    Write-Host "❌ User service is not running. Starting it..." -ForegroundColor Red
    Write-Host "   Run: docker-compose up -d user-service" -ForegroundColor Yellow
    exit 1
}

# Step 3: Send test POST request
Write-Host "`n3️⃣ Sending test POST request..." -ForegroundColor Cyan
try {
    $testUser = @{
        name = "Test User"
        email = "test.user@example.com"
    } | ConvertTo-Json

    Write-Host "   📤 Sending POST request to create user..." -ForegroundColor Yellow
    $response = Invoke-WebRequest -Uri "http://localhost:3000/users" -Method POST -Body $testUser -ContentType "application/json" -UseBasicParsing
    
    $responseData = $response.Content | ConvertFrom-Json
    Write-Host "✅ POST request successful" -ForegroundColor Green
    Write-Host "   📋 Response:" -ForegroundColor White
    Write-Host "      User: $($responseData.user.name) - $($responseData.user.email)" -ForegroundColor White
    Write-Host "      Event ID: $($responseData.eventId)" -ForegroundColor White
    Write-Host "      Published: $($responseData.published)" -ForegroundColor White
    
} catch {
    Write-Host "❌ Error sending POST request: $_" -ForegroundColor Red
    if ($_.Exception.Response) {
        $errorResponse = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorResponse)
        $errorBody = $reader.ReadToEnd()
        Write-Host "   Error details: $errorBody" -ForegroundColor Red
    }
}

Write-Host "`n📋 Integration Test Summary:" -ForegroundColor White
Write-Host "✅ 1. Subscriber function (data_sync/main.ts handler) - tested" -ForegroundColor Green
Write-Host "✅ 2. Publisher service (data_sync_poc user-service) - tested" -ForegroundColor Green
Write-Host "🔄 3. EventBridge connection - requires LocalStack/SAM setup" -ForegroundColor Yellow

Write-Host "`n💡 Next steps:" -ForegroundColor Cyan
Write-Host "   1. Set up LocalStack with EventBridge" -ForegroundColor White
Write-Host "   2. Deploy SAM template to LocalStack" -ForegroundColor White
Write-Host "   3. Test end-to-end event flow" -ForegroundColor White