FROM node:18-alpine

WORKDIR /app

# Copiar arquivos de configuração
COPY package.json ./
COPY tsconfig.json ./

# Instalar dependências
RUN npm install

# Copiar código fonte
COPY . .

# Compilar TypeScript
RUN npm run build

# Comando de inicialização
CMD ["npm", "start"]