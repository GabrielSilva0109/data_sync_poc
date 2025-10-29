# Data Sync PoC

Este projeto demonstra um fluxo de sincronização de dados usando AWS EventBridge, SQS e Lambda com LocalStack para desenvolvimento local.

## Arquitetura

```
POST /users (nome, email) 
    ↓
User Service → EventBridge → Lambda Processor → SQS → Consumer
```

## Serviços

1. **user-service**: API REST que recebe POST com nome e email e publica evento no EventBridge
2. **lambda-processor**: Função Lambda que processa eventos do EventBridge e envia para SQS
3. **sqs-consumer**: Consome mensagens da fila SQS

## Como executar

### 1. Pré-requisitos
- Docker e Docker Compose
- AWS CLI (para configurar LocalStack)
- Node.js (para desenvolvimento local)

### 2. Configurar ambiente
```bash
# Copiar arquivo de exemplo
cp .env.example .env

# Instalar dependências em cada serviço
cd user-service && npm install
cd ../lambda-processor && npm install
cd ../sqs-consumer && npm install
```

### 3. Executar com Docker
```bash
# Subir todos os serviços
docker-compose up -d

# Aguardar LocalStack estar pronto (cerca de 30 segundos)
# Então configurar a infraestrutura AWS
./setup-aws-infrastructure.ps1  # No Windows
# ou
./setup-aws-infrastructure.sh   # No Linux/Mac
```

### 4. Testar o fluxo

Enviar uma requisição POST para criar usuário:
```bash
curl -X POST http://localhost:3000/users \
  -H "Content-Type: application/json" \
  -d '{
    "name": "João Silva",
    "email": "joao@email.com"
  }'
```

## Endpoints

- `GET /health` - Health check do user-service
- `POST /users` - Criar usuário (body: {name, email})

## Estrutura do projeto

```
├── user-service/          # API REST
│   ├── src/index.ts
│   ├── package.json
│   └── Dockerfile
├── lambda-processor/      # Função Lambda
│   ├── src/index.ts
│   ├── package.json
│   └── Dockerfile
├── sqs-consumer/          # Consumer SQS
│   ├── src/index.ts
│   ├── package.json
│   └── Dockerfile
├── docker-compose.yml
└── setup-aws-infrastructure.*
```

## Desenvolvimento local

Para desenvolvimento local sem Docker:

1. Subir apenas o LocalStack:
```bash
docker-compose up localstack -d
```

2. Configurar infraestrutura:
```bash
./setup-aws-infrastructure.ps1
```

3. Executar serviços individualmente:
```bash
# Terminal 1 - User Service
cd user-service
npm run dev

# Terminal 2 - SQS Consumer
cd sqs-consumer
npm run dev
```

## Logs

Para ver os logs dos containers:
```bash
docker-compose logs -f user-service
docker-compose logs -f sqs-consumer
docker-compose logs -f localstack
```