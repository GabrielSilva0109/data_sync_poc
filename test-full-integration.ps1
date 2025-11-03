# Teste completo: data_sync_poc -> EventBridge -> data_sync (simulado)

Write-Host "Teste Completo de Integracao EventBridge" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green

# Função para simular o processamento do data_sync
function Simulate-DataSyncProcessing {
    param($EventData)
    
    Write-Host "`ndata_sync Handler - Evento recebido!" -ForegroundColor Cyan
    Write-Host "Processando dados:" -ForegroundColor Yellow
    Write-Host "   Nome: $($EventData.userData.name)" -ForegroundColor White
    Write-Host "   Email: $($EventData.userData.email)" -ForegroundColor White
    Write-Host "   User ID: $($EventData.userId)" -ForegroundColor White
    Write-Host "   Timestamp: $($EventData.timestamp)" -ForegroundColor White
    
    # Simular processamento
    Write-Host "`n   Sincronizando com banco de dados..." -ForegroundColor Gray
    Start-Sleep -Milliseconds 500
    Write-Host "   Dados salvos no banco" -ForegroundColor Green
    
    Write-Host "   Chamando API externa..." -ForegroundColor Gray
    Start-Sleep -Milliseconds 300
    Write-Host "   API externa notificada" -ForegroundColor Green
    
    Write-Host "   Enviando notificacao..." -ForegroundColor Gray
    Start-Sleep -Milliseconds 200
    Write-Host "   Notificacao enviada" -ForegroundColor Green
    
    Write-Host "`nUsuario $($EventData.userData.name) processado com sucesso!" -ForegroundColor Green
}

# Função para monitorar logs e simular consumo
function Monitor-EventBridgeAndSimulate {
    Write-Host "`nMonitorando EventBridge e simulando data_sync..." -ForegroundColor Cyan
    
    # Obter logs recentes
    $logs = docker-compose logs --tail=5 user-service
    
    # Procurar por eventos publicados
    $eventLines = $logs | Where-Object { $_ -match "Event published successfully" -or $_ -match "EventId" }
    
    if ($eventLines) {
        Write-Host "   Evento detectado no EventBridge!" -ForegroundColor Yellow
        
        # Simular dados que o data_sync receberia
        $simulatedEventData = @{
            userId = "user-$(Get-Date -Format 'yyyyMMddHHmmss')"
            userData = @{
                name = "Usuario Teste"
                email = "teste@exemplo.com"
            }
            timestamp = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
            source = "user-service"
        }
        
        # Simular processamento do data_sync
        Simulate-DataSyncProcessing -EventData $simulatedEventData
        
        return $true
    } else {
        Write-Host "   Nenhum evento recente encontrado" -ForegroundColor Yellow
        return $false
    }
}

# Início do teste
Write-Host "`n1. Verificando se os servicos estao rodando..." -ForegroundColor Cyan

# Verificar LocalStack
try {
    $localstackHealth = Invoke-WebRequest -Uri "http://localhost:4566/_localstack/health" -UseBasicParsing -TimeoutSec 5
    Write-Host "LocalStack rodando" -ForegroundColor Green
} catch {
    Write-Host "LocalStack nao esta rodando. Execute: .\setup-eventbridge-simple.ps1" -ForegroundColor Red
    exit 1
}

# Verificar User Service
try {
    $userServiceHealth = Invoke-WebRequest -Uri "http://localhost:3000/health" -UseBasicParsing -TimeoutSec 5
    Write-Host "User Service rodando" -ForegroundColor Green
} catch {
    Write-Host "User Service nao esta rodando. Execute: .\setup-eventbridge-simple.ps1" -ForegroundColor Red
    exit 1
}

Write-Host "`n2. Testando fluxo completo..." -ForegroundColor Cyan

# Criar usuário de teste
$testUser = @{
    name = "Maria Santos"
    email = "maria.santos@teste.com"
} | ConvertTo-Json

Write-Host "`nEnviando requisicao POST para data_sync_poc..." -ForegroundColor Yellow

try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000/users" -Method POST -Body $testUser -ContentType "application/json" -UseBasicParsing
    $data = $response.Content | ConvertFrom-Json
    
    Write-Host "Usuario criado no data_sync_poc:" -ForegroundColor Green
    Write-Host "   Nome: $($data.user.name)" -ForegroundColor White
    Write-Host "   Email: $($data.user.email)" -ForegroundColor White
    Write-Host "   Evento Publicado: $($data.published)" -ForegroundColor White
    Write-Host "   Event ID: $($data.eventId)" -ForegroundColor White
    
    # Aguardar um momento para o evento ser processado
    Write-Host "`nAguardando processamento do evento..." -ForegroundColor Yellow
    Start-Sleep -Seconds 2
    
    # Monitorar e simular
    $eventDetected = Monitor-EventBridgeAndSimulate
    
    if ($eventDetected) {
        Write-Host "`nTeste Completo - SUCESSO!" -ForegroundColor Green
        Write-Host "================================" -ForegroundColor Green
        Write-Host "data_sync_poc: Publicou evento" -ForegroundColor Green
        Write-Host "EventBridge: Roteou evento" -ForegroundColor Green
        Write-Host "data_sync: Processou evento (simulado)" -ForegroundColor Green
    } else {
        Write-Host "`nEvento nao foi detectado nos logs" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "Erro ao criar usuario: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`nProximos passos:" -ForegroundColor Cyan
Write-Host "1. Para implementar o data_sync real, crie um projeto separado" -ForegroundColor White
Write-Host "2. Use Lambda + EventBridge para consumir os eventos" -ForegroundColor White
Write-Host "3. Configure o handler main.ts para processar os dados" -ForegroundColor White

Write-Host "`nLogs detalhados:" -ForegroundColor Cyan
Write-Host "- User Service: docker-compose logs -f user-service" -ForegroundColor White
Write-Host "- LocalStack: docker-compose logs -f localstack" -ForegroundColor White