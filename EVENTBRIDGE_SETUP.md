# 🚀 EventBridge Publisher/Subscriber Setup

## 📖 Overview

This setup demonstrates a **real EventBridge integration** between two projects:

- **📤 Publisher**: `data_sync_poc` (this project) - sends events via POST → EventBridge
- **📥 Subscriber**: `data_sync` (separate project) - receives events via Lambda handler in `main.ts`

## 🏗️ Architecture

```
POST /users → User Service → EventBridge → Lambda (main.ts handler) → Business Logic
    (data_sync_poc)                           (data_sync project)
```

## 🚀 Quick Setup

### 1️⃣ **Prerequisites**
```bash
# Install AWS SAM CLI
# Windows: https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/install-sam-cli.html

# Verify installation
sam --version
```

### 2️⃣ **Setup Projects**
```bash
# In data_sync_poc directory
cd data_sync_poc
npm install

# Setup data_sync subscriber project
cd ../data_sync
npm install
npm run build
```

### 3️⃣ **Start Services**
```bash
# Terminal 1: Start LocalStack
cd data_sync_poc
docker-compose up -d localstack

# Terminal 2: Start SAM local (EventBridge simulation)
cd data_sync_poc
.\setup-eventbridge.ps1

# Terminal 3: Start User Service
cd data_sync_poc
docker-compose up -d user-service
```

### 4️⃣ **Test Integration**
```bash
# Run integration tests
.\test-eventbridge.ps1
```

## 🧪 Testing

### **Test Subscriber Only**
```bash
cd data_sync
sam local invoke DataSyncSubscriberFunction --event event.json
```

### **Test Publisher Only**
```bash
curl -X POST http://localhost:3000/users \
  -H "Content-Type: application/json" \
  -d '{"name": "John Doe", "email": "john@example.com"}'
```

### **Test Full Flow**
```bash
# 1. Start all services (see step 3 above)
# 2. Run test script
.\test-eventbridge.ps1
```

## 📁 Project Structure

```
data_sync_poc/              # 📤 Publisher Project
├── user-service/
│   └── src/index.ts        # EventBridge publisher
├── template.yaml           # SAM template
├── setup-eventbridge.ps1   # Setup script
└── test-eventbridge.ps1    # Test script

data_sync/                  # 📥 Subscriber Project  
├── main.ts                 # 🎯 Handler function (entry point)
├── package.json
├── tsconfig.json
└── event.json             # Test event
```

## 🔧 Configuration

### **Environment Variables**
```bash
# EventBridge Settings
EVENT_BUS_NAME=data-sync-event-bus
EVENT_SOURCE=data-sync-poc.user-service

# AWS Settings (LocalStack)
AWS_ENDPOINT=http://localhost:4566
AWS_REGION=us-east-1
```

### **Event Format**
```json
{
  "source": "data-sync-poc.user-service",
  "detail-type": "User Created",
  "detail": {
    "userId": "user-1698675000123",
    "userData": {
      "name": "John Doe", 
      "email": "john@example.com"
    },
    "timestamp": "2025-10-29T14:30:00Z",
    "source": "user-service"
  }
}
```

## 🎯 Handler Function (`data_sync/main.ts`)

The **main entry point** for events:

```typescript
export const handler: Handler = async (event: UserCreatedEvent, context: Context) => {
  console.log('🎯 Event received in data_sync project:', event);
  
  // Your business logic here
  await processUserCreatedEvent(event.detail);
  
  return { statusCode: 200, body: 'Event processed' };
};
```

## 📊 Event Flow

1. **📱 Client** sends POST to `/users`
2. **🌐 User Service** validates and publishes to EventBridge
3. **📡 EventBridge** routes event to Lambda
4. **⚡ Lambda** calls `handler` in `main.ts`
5. **🔄 Handler** processes business logic

## 🛠️ Development

### **Local Development**
```bash
# Start LocalStack + SAM
.\setup-eventbridge.ps1

# In another terminal, test
.\test-eventbridge.ps1
```

### **Production Deployment**
```bash
# Deploy SAM template
sam deploy --guided
```

## 📝 Notes

- **EventBridge** provides reliable event delivery
- **Lambda** auto-scales based on event volume  
- **SAM** simulates AWS services locally
- **Handler** in `main.ts` is the entry point for all events