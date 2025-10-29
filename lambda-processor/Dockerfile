FROM node:18-alpine

WORKDIR /app

# Copiar package.json e instalar dependências
COPY package.json ./
RUN npm install

# Copiar código fonte
COPY . .

# Compilar TypeScript
RUN npm run build

# Para simular lambda localmente
CMD ["node", "-e", "const handler = require('./dist/index.js').handler; setInterval(() => console.log('Lambda processor aguardando eventos...'), 5000);"]