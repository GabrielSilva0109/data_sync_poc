# Script PowerShell para configurar EventBridge, SQS e Lambda no LocalStack

Write-Host "🚀 Configurando infraestrutura AWS no LocalStack..." -ForegroundColor Green

# Aguardar LocalStack estar pronto
Write-Host "⏳ Aguardando LocalStack estar pronto..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Definir variáveis
$AWS_ENDPOINT = "http://localhost:4566"
$REGION = "us-east-1"
$EVENT_BUS_NAME = "user-events-bus"
$QUEUE_NAME = "user-events-queue"
$LAMBDA_FUNCTION_NAME = "user-events-processor"

# Configurar variáveis de ambiente para AWS CLI
$env:AWS_ACCESS_KEY_ID = "test"
$env:AWS_SECRET_ACCESS_KEY = "test"
$env:AWS_DEFAULT_REGION = $REGION

Write-Host "📋 Criando EventBridge custom bus..." -ForegroundColor Cyan
aws --endpoint-url=$AWS_ENDPOINT eventbridge create-event-bus --name $EVENT_BUS_NAME

Write-Host "📋 Criando SQS Queue..." -ForegroundColor Cyan
$QUEUE_URL = aws --endpoint-url=$AWS_ENDPOINT sqs create-queue --queue-name $QUEUE_NAME --query 'QueueUrl' --output text

Write-Host "📋 Queue URL: $QUEUE_URL" -ForegroundColor White

Write-Host "📋 Criando regra do EventBridge..." -ForegroundColor Cyan
aws --endpoint-url=$AWS_ENDPOINT eventbridge put-rule --event-bus-name $EVENT_BUS_NAME --name "UserCreatedRule" --event-pattern '{\"source\":[\"user-service\"],\"detail-type\":[\"UserCreated\"]}'

Write-Host "📋 Criando Lambda function..." -ForegroundColor Cyan
# Criar um arquivo zip simples para o Lambda
$lambdaCode = 'exports.handler = async (event) => { console.log("Event received:", event); return { statusCode: 200 }; };'
$lambdaCode | Out-File -FilePath "$env:TEMP\lambda.js" -Encoding ASCII
Compress-Archive -Path "$env:TEMP\lambda.js" -DestinationPath "$env:TEMP\lambda-function.zip" -Force

aws --endpoint-url=$AWS_ENDPOINT lambda create-function --function-name $LAMBDA_FUNCTION_NAME --runtime nodejs18.x --role arn:aws:iam::000000000000:role/lambda-role --handler index.handler --zip-file fileb://$env:TEMP/lambda-function.zip

Write-Host "📋 Adicionando permissão para EventBridge invocar Lambda..." -ForegroundColor Cyan
aws --endpoint-url=$AWS_ENDPOINT lambda add-permission --function-name $LAMBDA_FUNCTION_NAME --statement-id eventbridge-invoke --action lambda:InvokeFunction --principal events.amazonaws.com

Write-Host "📋 Configurando target para EventBridge..." -ForegroundColor Cyan
aws --endpoint-url=$AWS_ENDPOINT eventbridge put-targets --event-bus-name $EVENT_BUS_NAME --rule "UserCreatedRule" --targets "Id"="1","Arn"="arn:aws:lambda:us-east-1:000000000000:function:$LAMBDA_FUNCTION_NAME"

Write-Host "✅ Configuração da infraestrutura concluída!" -ForegroundColor Green
Write-Host "📋 EventBridge Bus: $EVENT_BUS_NAME" -ForegroundColor White
Write-Host "📋 SQS Queue: $QUEUE_NAME" -ForegroundColor White
Write-Host "📋 Lambda Function: $LAMBDA_FUNCTION_NAME" -ForegroundColor White