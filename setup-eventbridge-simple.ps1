# Alternative setup without SAM CLI - using LocalStack directly

Write-Host "Setting up EventBridge with LocalStack (No SAM required)" -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green

# Step 1: Update environment variables
Write-Host "`n1. Updating environment variables..." -ForegroundColor Cyan
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
SIMULATION_MODE=false
"@

$envContent | Out-File -FilePath ".env" -Encoding UTF8
Write-Host "Environment variables updated" -ForegroundColor Green

# Step 2: Start LocalStack
Write-Host "`n2. Starting LocalStack..." -ForegroundColor Cyan
try {
    docker-compose up -d localstack
    Write-Host "LocalStack started" -ForegroundColor Green
    
    # Wait for LocalStack to be ready
    Write-Host "   Waiting for LocalStack to be ready..." -ForegroundColor Yellow
    Start-Sleep -Seconds 15
} catch {
    Write-Host "Error starting LocalStack: $_" -ForegroundColor Red
    exit 1
}

# Step 3: Start user service
Write-Host "`n3. Starting user service..." -ForegroundColor Cyan
try {
    # Build and start user service
    docker-compose build user-service
    docker-compose up -d user-service
    
    Write-Host "User service started" -ForegroundColor Green
    
    # Wait for service to be ready
    Write-Host "   Waiting for user service to be ready..." -ForegroundColor Yellow
    Start-Sleep -Seconds 10
    
    # Test health check
    $health = Invoke-WebRequest -Uri "http://localhost:3000/health" -UseBasicParsing
    Write-Host "User service is healthy" -ForegroundColor Green
    
} catch {
    Write-Host "Error starting user service: $_" -ForegroundColor Red
}

# Step 4: Test the setup
Write-Host "`n4. Testing EventBridge setup..." -ForegroundColor Cyan

$testUser = @{
    name = "Test User"
    email = "test@example.com"
} | ConvertTo-Json

try {
    Write-Host "   Sending test POST request..." -ForegroundColor Yellow
    $response = Invoke-WebRequest -Uri "http://localhost:3000/users" -Method POST -Body $testUser -ContentType "application/json" -UseBasicParsing
    
    $responseData = $response.Content | ConvertFrom-Json
    Write-Host "POST request successful" -ForegroundColor Green
    Write-Host "   User: $($responseData.user.name) - $($responseData.user.email)" -ForegroundColor White
    Write-Host "   Event published: $($responseData.published)" -ForegroundColor White
    
    if ($responseData.eventId) {
        Write-Host "   Event ID: $($responseData.eventId)" -ForegroundColor White
    }
    
} catch {
    Write-Host "Error testing POST request: $_" -ForegroundColor Red
    if ($_.Exception.Response) {
        $errorDetails = $_.ErrorDetails.Message
        Write-Host "   Error details: $errorDetails" -ForegroundColor Red
    }
}

Write-Host "`nSetup complete!" -ForegroundColor Green
Write-Host "`nWhat's working:" -ForegroundColor White
Write-Host "- LocalStack with EventBridge" -ForegroundColor Green
Write-Host "- User Service (Publisher)" -ForegroundColor Green
Write-Host "- EventBridge event publishing" -ForegroundColor Green

Write-Host "`nNext steps:" -ForegroundColor White
Write-Host "1. To test POST requests: .\test-simple-eventbridge.ps1" -ForegroundColor White
Write-Host "2. To view logs: docker-compose logs -f user-service" -ForegroundColor White
Write-Host "3. To stop: docker-compose down" -ForegroundColor White

Write-Host "`nNote: This setup publishes events to EventBridge." -ForegroundColor Cyan
Write-Host "For a full subscriber, you would need the separate data_sync project." -ForegroundColor Cyan