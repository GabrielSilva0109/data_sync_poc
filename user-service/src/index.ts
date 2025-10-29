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

const eventBridge = new AWS.EventBridge({
  region: process.env.AWS_REGION,
  endpoint: process.env.AWS_ENDPOINT
});

interface UserData {
  name: string;
  email: string;
}

// Função para validar email
const isValidEmail = (email: string): boolean => {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
};

app.post('/users', async (req: Request, res: Response) => {
  try {
    const { name, email }: UserData = req.body;

    // Validações
    if (!name || typeof name !== 'string' || name.trim().length === 0) {
      return res.status(400).json({ error: 'Nome é obrigatório e deve ser uma string válida' });
    }

    if (!email || typeof email !== 'string' || !isValidEmail(email)) {
      return res.status(400).json({ error: 'Email é obrigatório e deve ter um formato válido' });
    }

    const userData: UserData = {
      name: name.trim(),
      email: email.trim().toLowerCase()
    };

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

    const result = await eventBridge.putEvents(params).promise();
    console.log('✅ Evento publicado:', result);
    res.json({ 
      message: 'Usuário criado e evento publicado com sucesso!',
      user: userData 
    });
  } catch (error) {
    console.error('❌ Erro ao processar requisição:', error);
    res.status(500).json({ error: 'Erro interno do servidor' });
  }
});

app.listen(3000, () => console.log('🚀 User Service rodando em http://localhost:3000'));
