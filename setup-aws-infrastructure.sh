#!/bin/bash

# Script para configurar EventBridge, SQS e Lambda no LocalStack

echo "🚀 Configurando infraestrutura AWS no LocalStack..."

# Aguardar LocalStack estar pronto
echo "⏳ Aguardando LocalStack estar pronto..."
sleep 10

# Definir variáveis
AWS_ENDPOINT="http://localhost:4566"
REGION="us-east-1"
EVENT_BUS_NAME="user-events-bus"
QUEUE_NAME="user-events-queue"
LAMBDA_FUNCTION_NAME="user-events-processor"

# Configurar AWS CLI para LocalStack
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=$REGION

echo "📋 Criando EventBridge custom bus..."
aws --endpoint-url=$AWS_ENDPOINT eventbridge create-event-bus \
    --name $EVENT_BUS_NAME

echo "📋 Criando SQS Queue..."
QUEUE_URL=$(aws --endpoint-url=$AWS_ENDPOINT sqs create-queue \
    --queue-name $QUEUE_NAME \
    --query 'QueueUrl' --output text)

echo "📋 Queue URL: $QUEUE_URL"

echo "📋 Criando regra do EventBridge..."
aws --endpoint-url=$AWS_ENDPOINT eventbridge put-rule \
    --event-bus-name $EVENT_BUS_NAME \
    --name "UserCreatedRule" \
    --event-pattern '{"source":["user-service"],"detail-type":["UserCreated"]}'

echo "📋 Criando Lambda function..."
# Primeiro, criar um arquivo zip simples para o Lambda
echo 'exports.handler = async (event) => { console.log("Event received:", event); return { statusCode: 200 }; };' > /tmp/lambda.js
cd /tmp && zip lambda-function.zip lambda.js

aws --endpoint-url=$AWS_ENDPOINT lambda create-function \
    --function-name $LAMBDA_FUNCTION_NAME \
    --runtime nodejs18.x \
    --role arn:aws:iam::000000000000:role/lambda-role \
    --handler index.handler \
    --zip-file fileb://lambda-function.zip

echo "📋 Adicionando permissão para EventBridge invocar Lambda..."
aws --endpoint-url=$AWS_ENDPOINT lambda add-permission \
    --function-name $LAMBDA_FUNCTION_NAME \
    --statement-id eventbridge-invoke \
    --action lambda:InvokeFunction \
    --principal events.amazonaws.com

echo "📋 Configurando target para EventBridge..."
aws --endpoint-url=$AWS_ENDPOINT eventbridge put-targets \
    --event-bus-name $EVENT_BUS_NAME \
    --rule "UserCreatedRule" \
    --targets "Id"="1","Arn"="arn:aws:lambda:us-east-1:000000000000:function:$LAMBDA_FUNCTION_NAME"

echo "✅ Configuração da infraestrutura concluída!"
echo "📋 EventBridge Bus: $EVENT_BUS_NAME"
echo "📋 SQS Queue: $QUEUE_NAME"
echo "📋 Lambda Function: $LAMBDA_FUNCTION_NAME"