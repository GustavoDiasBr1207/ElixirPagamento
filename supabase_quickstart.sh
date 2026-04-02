#!/bin/bash

# 🚀 Quick Setup Script - Supabase + PhoenixPay
# Execute: bash supabase_quickstart.sh

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║           PhoenixPay + Supabase Quick Setup                    ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"

echo -e "\n${YELLOW}⚠️  PRÉ-REQUISITOS:${NC}"
echo "1. Conta Supabase: https://app.supabase.com"
echo "2. Elixir 1.14+ instalado"
echo "3. Mix instalado"

echo -e "\n${YELLOW}INFORMAÇÕES SUPABASE:${NC}"
echo "Colar as informações do seu projeto Supabase abaixo."
echo "(Encontrar em: Settings → Database → Connection string)"

echo -e "\n${BLUE}Passo 1: Dados da Conexão${NC}"
read -p "📧 DATABASE_USER (geralmente 'postgres'): " DB_USER
read -sp "🔐 DATABASE_PASSWORD (senha do banco): " DB_PASS
echo
read -p "🌐 DATABASE_HOST (db.xxxxx.supabase.co): " DB_HOST
read -p "🔢 DATABASE_PORT (geralmente 5432): " DB_PORT

# Criar .env
echo -e "\n${GREEN}Criando .env...${NC}"
cat > .env << EOF
# Supabase Database
DATABASE_USER=$DB_USER
DATABASE_PASSWORD=$DB_PASS
DATABASE_HOST=$DB_HOST
DATABASE_PORT=$DB_PORT
DATABASE_NAME=postgres
DATABASE_SSL=true

# Environment
MIX_ENV=dev
PHX_PORT=4000
PHX_HOST=localhost

# JWT
JWT_SECRET=$(openssl rand -base64 32)
EOF

echo -e "${GREEN}✓ .env criado${NC}"

echo -e "\n${BLUE}Passo 2: Instalar Dependências${NC}"
mix deps.get
echo -e "${GREEN}✓ Dependências instaladas${NC}"

echo -e "\n${BLUE}Passo 3: Testar Conexão${NC}"
if mix ecto.load > /dev/null 2>&1; then
  echo -e "${GREEN}✓ Conexão com Supabase OK!${NC}"
else
  echo -e "${RED}✗ Erro na conexão. Verificar credenciais.${NC}"
  exit 1
fi

echo -e "\n${BLUE}Passo 4: Rodar Migrations${NC}"
mix ecto.migrate
echo -e "${GREEN}✓ Migrations aplicadas${NC}"

echo -e "\n${BLUE}Passo 5: Carregar Dados Demo${NC}"
read -p "Carregar dados de teste? (s/n) " -n 1 -r
if [[ $REPLY =~ ^[Ss]$ ]]; then
  mix run priv/repo/seeds.exs
  echo -e "${GREEN}✓ Dados de demo carregados${NC}"
fi

echo -e "\n${GREEN}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                    SETUP COMPLETO! 🎉                         ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════════╝${NC}"

echo -e "\n${YELLOW}📊 Próximos Passos:${NC}"
echo "1. Rodar servidor: ${BLUE}mix phx.server${NC}"
echo "2. Abrir: ${BLUE}http://localhost:4000${NC}"
echo "3. Dashboard: ${BLUE}http://localhost:4000/dashboard${NC}"

echo -e "\n${YELLOW}📚 Referenciais:${NC}"
echo "• Documentação: SUPABASE_SETUP.md"
echo "• Código: lib/phoenix_pay/"
echo "• API: README.md"

echo -e "\n${YELLOW}🎤 Para apresentar na entrevista:${NC}"
echo "1. Ver INTERVIEW_GUIDE.md"
echo "2. Testar API com postman_collection.json"
echo "3. Rodar demo.sh para teste fácil"

echo
