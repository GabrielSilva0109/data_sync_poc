import express, { Request, Response } from 'express';
import AWS from 'aws-sdk';
import dotenv from 'dotenv';
dotenv.config();

const app = express();
app.use(express.json());

// Health check endpoint
app.get('/health', (req: Request, res: Response) => {
  res.json({ 
    status: 'OK', 
    service: 'user-service',
    timestamp: new Date().toISOString()
  });
});

// Configure EventBridge client
const eventBridge = new AWS.EventBridge({
  region: process.env.AWS_REGION || 'us-east-1',
  endpoint: process.env.AWS_ENDPOINT || undefined,
  accessKeyId: process.env.AWS_ACCESS_KEY_ID || undefined,
  secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY || undefined
});

interface UserData {
  name: string;
  email: string;
}

// Function to validate email
const isValidEmail = (email: string): boolean => {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
};

app.post('/users', async (req: Request, res: Response) => {
  try {
    const { name, email }: UserData = req.body;

    // Validations
    if (!name || typeof name !== 'string' || name.trim().length === 0) {
      return res.status(400).json({ error: 'Name is required and must be a valid string' });
    }
    if (!email || typeof email !== 'string' || !isValidEmail(email)) {
      return res.status(400).json({ error: 'Email is required and must have a valid format' });
    }

    const userData: UserData = {
      name: name.trim(),
      email: email.trim().toLowerCase()
    };

    // Publish event to EventBridge
    const eventParams: AWS.EventBridge.PutEventsRequest = {
      Entries: [
        {
          EventBusName: process.env.EVENT_BUS_NAME || 'default',
          Source: 'data-sync-poc.user-service',
          DetailType: 'User Created',
          Detail: JSON.stringify({
            userId: `user-${Date.now()}`,
            userData: userData,
            timestamp: new Date().toISOString(),
            source: 'user-service'
          }),
          Time: new Date()
        }
      ]
    };

    console.log('Publishing event to EventBridge:', JSON.stringify(eventParams, null, 2));
    
    const result = await eventBridge.putEvents(eventParams).promise();
    
    res.json({ 
      message: 'User created and event published successfully!',
      user: userData,
      eventId: result.Entries?.[0]?.EventId,
      published: true
    });
  } catch (error) {
    console.error('❌ Error processing request:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

app.listen(3000, () => console.log('🚀 User Service rodando em http://localhost:3000'));