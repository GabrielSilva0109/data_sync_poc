import express, { Request, Response } from 'express';
import AWS from 'aws-sdk';
import dotenv from 'dotenv';
dotenv.config();

const app = express();
app.use(express.json());

const eventBridge = new AWS.EventBridge({
  region: process.env.AWS_REGION,
  endpoint: process.env.AWS_ENDPOINT
});

interface UserData {
  id: number;
  name: string;
  email?: string;
}

app.post('/users', async (req: Request, res: Response) => {
  const userData: UserData = req.body;

  const params: AWS.EventBridge.PutEventsRequest = {
    Entries: [
      {
        EventBusName: process.env.EVENT_BUS_NAME!,
        Source: 'user-service',
        DetailType: 'UserCreated',
        Detail: JSON.stringify(userData)
      }
    ]
  };

  try {
    const result = await eventBridge.putEvents(params).promise();
    console.log('✅ Evento publicado:', result);
    res.json({ message: 'Evento publicado com sucesso!' });
  } catch (error) {
    console.error('❌ Erro ao publicar evento:', error);
    res.status(500).json({ error: 'Erro ao publicar evento' });
  }
});

app.listen(3000, () => console.log('🚀 User Service rodando em http://localhost:3000'));
