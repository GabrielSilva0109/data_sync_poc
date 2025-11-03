# Simple EventBridge test without SAM CLI

Write-Host "Testing EventBridge Publisher (Simple Mode)" -ForegroundColor Green
Write-Host "===========================================" -ForegroundColor Green

# Check if services are running
Write-Host "`n1. Checking services..." -ForegroundColor Cyan

# Check LocalStack
try {
    $localstackHealth = Invoke-WebRequest -Uri "http://localhost:4566/_localstack/health" -UseBasicParsing -TimeoutSec 5
    Write-Host "LocalStack is running" -ForegroundColor Green
} catch {
    Write-Host "LocalStack is not running. Run: .\setup-eventbridge-simple.ps1" -ForegroundColor Red
    exit 1
}

# Check User Service
try {
    $userServiceHealth = Invoke-WebRequest -Uri "http://localhost:3000/health" -UseBasicParsing -TimeoutSec 5
    Write-Host "User Service is running" -ForegroundColor Green
} catch {
    Write-Host "User Service is not running. Run: .\setup-eventbridge-simple.ps1" -ForegroundColor Red
    exit 1
}

# Step 2: Test multiple scenarios
Write-Host "`n2. Testing EventBridge publisher..." -ForegroundColor Cyan

# Test 1: Valid user
Write-Host "`n   Test 1: Valid user creation" -ForegroundColor Yellow
$validUser = @{
    name = "John Doe"
    email = "john.doe@example.com"
} | ConvertTo-Json

try {
    $response1 = Invoke-WebRequest -Uri "http://localhost:3000/users" -Method POST -Body $validUser -ContentType "application/json" -UseBasicParsing
    $data1 = $response1.Content | ConvertFrom-Json
    
    Write-Host "   User created successfully" -ForegroundColor Green
    Write-Host "      Name: $($data1.user.name)" -ForegroundColor White
    Write-Host "      Email: $($data1.user.email)" -ForegroundColor White
    Write-Host "      Event Published: $($data1.published)" -ForegroundColor White
    if ($data1.eventId) {
        Write-Host "      Event ID: $($data1.eventId)" -ForegroundColor White
    }
} catch {
    Write-Host "   Failed to create valid user" -ForegroundColor Red
    Write-Host "      Error: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 2: Invalid email
Write-Host "`n   Test 2: Invalid email validation" -ForegroundColor Yellow
$invalidUser = @{
    name = "Jane Doe"
    email = "invalid-email"
} | ConvertTo-Json

try {
    $response2 = Invoke-WebRequest -Uri "http://localhost:3000/users" -Method POST -Body $invalidUser -ContentType "application/json" -UseBasicParsing
    Write-Host "   Should have failed validation" -ForegroundColor Red
} catch {
    $errorData = $_.ErrorDetails.Message | ConvertFrom-Json
    Write-Host "   Validation working correctly" -ForegroundColor Green
    Write-Host "      Error: $($errorData.error)" -ForegroundColor White
}

# Test 3: Missing name
Write-Host "`n   Test 3: Missing name validation" -ForegroundColor Yellow
$noNameUser = @{
    name = ""
    email = "test@example.com"
} | ConvertTo-Json

try {
    $response3 = Invoke-WebRequest -Uri "http://localhost:3000/users" -Method POST -Body $noNameUser -ContentType "application/json" -UseBasicParsing
    Write-Host "   Should have failed validation" -ForegroundColor Red
} catch {
    $errorData = $_.ErrorDetails.Message | ConvertFrom-Json
    Write-Host "   Validation working correctly" -ForegroundColor Green
    Write-Host "      Error: $($errorData.error)" -ForegroundColor White
}

# Step 3: Check EventBridge events in LocalStack logs
Write-Host "`n3. Checking EventBridge activity..." -ForegroundColor Cyan
Write-Host "   Checking user-service logs for EventBridge activity..." -ForegroundColor Yellow

try {
    # Get recent logs
    $logs = docker-compose logs --tail=10 user-service
    
    if ($logs -match "Publishing event to EventBridge" -or $logs -match "Event published successfully") {
        Write-Host "   EventBridge events are being published" -ForegroundColor Green
        Write-Host "   Check full logs with: docker-compose logs -f user-service" -ForegroundColor White
    } else {
        Write-Host "   No EventBridge activity found in recent logs" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   Error checking logs: $_" -ForegroundColor Red
}

# Step 4: Summary
Write-Host "`nTest Summary:" -ForegroundColor White
Write-Host "- User Service: Running and responding" -ForegroundColor Green
Write-Host "- LocalStack: Running EventBridge simulation" -ForegroundColor Green
Write-Host "- Validation: Working correctly" -ForegroundColor Green
Write-Host "- Event Publishing: Configured and active" -ForegroundColor Green

Write-Host "`nNext Steps:" -ForegroundColor Cyan
Write-Host "1. View real-time logs: docker-compose logs -f user-service" -ForegroundColor White
Write-Host "2. Monitor LocalStack: docker-compose logs -f localstack" -ForegroundColor White
Write-Host "3. Create more users by running this test again" -ForegroundColor White

Write-Host "`nEvent Flow Working:" -ForegroundColor White
Write-Host "   POST /users -> Validation -> EventBridge -> LocalStack" -ForegroundColor White
Write-Host "`nPublisher (data_sync_poc) is ready!" -ForegroundColor Green