// Simulador do data_sync - Handler principal
import { EventBridgeEvent } from 'aws-lambda';

interface UserCreatedDetail {
  userId: string;
  userData: {
    name: string;
    email: string;
  };
  timestamp: string;
  source: string;
}

export const handler = async (event: EventBridgeEvent<'User Created', UserCreatedDetail>) => {
  console.log('🎯 data_sync Handler - Evento recebido!');
  console.log('📋 Detalhes do evento:', JSON.stringify(event, null, 2));
  
  try {
    const { userId, userData, timestamp, source } = event.detail;
    
    // Simular processamento de dados
    console.log(`\n📝 Processando usuário:`);
    console.log(`   ID: ${userId}`);
    console.log(`   Nome: ${userData.name}`);
    console.log(`   Email: ${userData.email}`);
    console.log(`   Timestamp: ${timestamp}`);
    console.log(`   Source: ${source}`);
    
    // Simular sincronização com banco de dados
    await simulateDBSync(userData);
    
    // Simular chamada para API externa
    await simulateExternalAPICall(userData);
    
    // Simular notificação
    await simulateNotification(userData);
    
    console.log(`✅ Usuário ${userData.name} sincronizado com sucesso!`);
    
    return {
      statusCode: 200,
      body: JSON.stringify({
        message: 'Evento processado com sucesso',
        userId: userId,
        processedAt: new Date().toISOString()
      })
    };
    
  } catch (error) {
    console.error('❌ Erro ao processar evento:', error);
    throw error;
  }
};

// Simular sincronização com banco de dados
async function simulateDBSync(userData: { name: string; email: string }) {
  console.log('   🗄️  Sincronizando com banco de dados...');
  
  // Simular delay de operação de banco
  await new Promise(resolve => setTimeout(resolve, 100));
  
  console.log('   ✅ Dados salvos no banco de dados');
}

// Simular chamada para API externa
async function simulateExternalAPICall(userData: { name: string; email: string }) {
  console.log('   🌐 Chamando API externa...');
  
  // Simular delay de API
  await new Promise(resolve => setTimeout(resolve, 150));
  
  console.log('   ✅ API externa notificada');
}

// Simular notificação
async function simulateNotification(userData: { name: string; email: string }) {
  console.log('   📧 Enviando notificação...');
  
  // Simular delay de notificação
  await new Promise(resolve => setTimeout(resolve, 50));
  
  console.log('   ✅ Notificação enviada');
}

// Para testes diretos (não Lambda)
export async function testHandler(eventData: any) {
  const mockEvent: EventBridgeEvent<'User Created', UserCreatedDetail> = {
    version: '0',
    id: 'test-event-id',
    'detail-type': 'User Created',
    source: 'data-sync-poc.user-service',
    account: '123456789012',
    time: new Date().toISOString(),
    region: 'us-east-1',
    resources: [],
    detail: eventData
  };
  
  return await handler(mockEvent);
}