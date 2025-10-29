import express, { Request, Response } from 'express';
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

    // Simulação do EventBridge por enquanto
    console.log('📋 Usuário criado:', userData);
    console.log('📤 Simulando publicação no EventBridge...');
    
    // Simular evento que seria enviado
    const eventData = {
      eventBusName: process.env.EVENT_BUS_NAME || 'user-events-bus',
      source: 'user-service',
      detailType: 'UserCreated',
      detail: userData,
      timestamp: new Date().toISOString()
    };
    
    console.log('✅ Evento simulado:', JSON.stringify(eventData, null, 2));
    
    res.json({ 
      message: 'Usuário criado com sucesso! (EventBridge simulado)',
      user: userData,
      simulatedEvent: eventData
    });
  } catch (error) {
    console.error('❌ Erro ao processar requisição:', error);
    res.status(500).json({ error: 'Erro interno do servidor' });
  }
});

app.listen(3000, () => console.log('🚀 User Service rodando em http://localhost:3000'));