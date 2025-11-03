import { testHandler } from './main';

// Simular dados de evento que viriam do data_sync_poc
const mockEventData = {
  userId: 'user-test-123',
  userData: {
    name: 'João Silva',
    email: 'joao.silva@teste.com'
  },
  timestamp: new Date().toISOString(),
  source: 'user-service'
};

console.log('🚀 Iniciando teste do data_sync simulator...\n');

// Executar o teste
testHandler(mockEventData)
  .then(result => {
    console.log('\n🎉 Teste concluído com sucesso!');
    console.log('📊 Resultado:', JSON.stringify(result, null, 2));
  })
  .catch(error => {
    console.error('\n❌ Erro no teste:', error);
    process.exit(1);
  });