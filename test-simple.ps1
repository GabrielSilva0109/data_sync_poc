# Script de teste para o Data Sync PoC

Write-Host "Testando Data Sync PoC" -ForegroundColor Green
Write-Host "======================" -ForegroundColor Green

Write-Host "`n1. Testando Health Check..." -ForegroundColor Cyan
try {
    $health = Invoke-WebRequest -Uri "http://localhost:3000/health" -UseBasicParsing
    $healthData = $health.Content | ConvertFrom-Json
    Write-Host "Health Check OK: $($healthData.service) - $($healthData.timestamp)" -ForegroundColor Green
} catch {
    Write-Host "Health Check FALHOU: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "`n2. Testando criacao de usuario valido..." -ForegroundColor Cyan
try {
    $body = '{"name":"Ana Silva","email":"ana@email.com"}'
    $response = Invoke-WebRequest -Uri "http://localhost:3000/users" -Method POST -Body $body -ContentType "application/json" -UseBasicParsing
    $responseData = $response.Content | ConvertFrom-Json
    Write-Host "Usuario criado: $($responseData.user.name) - $($responseData.user.email)" -ForegroundColor Green
    Write-Host "Evento simulado para: $($responseData.simulatedEvent.eventBusName)" -ForegroundColor Blue
} catch {
    Write-Host "Erro ao criar usuario: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n3. Testando validacao - nome vazio..." -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000/users" -Method POST -Body '{"name":"","email":"test@email.com"}' -ContentType "application/json" -UseBasicParsing
    Write-Host "ERRO: Deveria ter falhado com nome vazio" -ForegroundColor Red
} catch {
    $errorContent = $_.ErrorDetails.Message | ConvertFrom-Json
    Write-Host "Validacao OK: $($errorContent.error)" -ForegroundColor Green
}

Write-Host "`nTodos os testes concluidos!" -ForegroundColor Green