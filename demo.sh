#!/bin/bash

# 🚀 PhoenixPay Demo Script
# Execute este arquivo para ter uma demonstração completa do sistema

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║              PhoenixPay - Demo Script                          ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"

echo -e "\n${YELLOW}📋 PRÉ-REQUISITOS:${NC}"
echo "✓ Docker running (postgresql, redis)"
echo "✓ Mix dependencies (mix deps.get)"
echo "✓ Database setup (mix ecto.setup)"
echo "✓ Server running (mix phx.server em outro terminal)"

echo -e "\n${YELLOW}⏳ Aguarde o servidor iniciar em http://localhost:4000${NC}"
echo -e "${YELLOW}Pressione ENTER quando estiver pronto...${NC}"
read

API_URL="http://localhost:4000/api/v1"

echo -e "\n${GREEN}═══ TESTE 1: Registrar Novo Usuário ===${NC}"
REGISTER_RESPONSE=$(curl -s -X POST $API_URL/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "demo_user_'$(date +%s)'@test.com",
    "name": "Demo User",
    "password": "password123"
  }')

echo $REGISTER_RESPONSE | jq .
USER_TOKEN=$(echo $REGISTER_RESPONSE | jq -r '.token')
USER_ID=$(echo $REGISTER_RESPONSE | jq -r '.user_id')

echo -e "\n✓ Usuário registrado"
echo "Token: $USER_TOKEN"
echo "User ID: $USER_ID"

echo -e "\n${GREEN}═══ TESTE 2: Criar Pagamento ===${NC}"
PAYMENT_RESPONSE=$(curl -s -X POST $API_URL/payments \
  -H "Authorization: Bearer $USER_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "amount": "299.99",
    "description": "Laptop Pro 15 polegadas",
    "payment_method": "pix"
  }')

echo $PAYMENT_RESPONSE | jq .
PAYMENT_ID=$(echo $PAYMENT_RESPONSE | jq -r '.payment_id')

echo -e "\n✓ Pagamento criado"
echo "Payment ID: $PAYMENT_ID"

echo -e "\n${GREEN}═══ TESTE 3: Listar Pagamentos ===${NC}"
curl -s -X GET $API_URL/payments \
  -H "Authorization: Bearer $USER_TOKEN" | jq '.payments[0]'

echo -e "\n✓ Pagamentos listados"

echo -e "\n${GREEN}═══ TESTE 4: Confirmar Pagamento ===${NC}"
curl -s -X POST $API_URL/payments/$PAYMENT_ID/confirm \
  -H "Authorization: Bearer $USER_TOKEN" | jq .

echo -e "\n⏳ Aguardando processamento (1-3 segundos)..."
sleep 4

echo -e "\n${GREEN}═══ TESTE 5: Verificar Status ===${NC}"
curl -s -X GET $API_URL/payments/$PAYMENT_ID/status \
  -H "Authorization: Bearer $USER_TOKEN" | jq .

echo -e "\n${GREEN}═══ TESTE 6: Ver Estatísticas ===${NC}"
curl -s -X GET $API_URL/stats/user \
  -H "Authorization: Bearer $USER_TOKEN" | jq .

echo -e "\n${GREEN}═══ TESTE 7: Criar Webhook ===${NC}"
WEBHOOK_RESPONSE=$(curl -s -X POST $API_URL/webhooks \
  -H "Authorization: Bearer $USER_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://webhook.site/unique-id-123",
    "events": ["payment.confirmed", "payment.failed"]
  }')

echo $WEBHOOK_RESPONSE | jq .
WEBHOOK_ID=$(echo $WEBHOOK_RESPONSE | jq -r '.id')

echo -e "\n✓ Webhook criado"

echo -e "\n${BLUE}═══ RESUMO DA DEMONSTRAÇÃO ===${NC}"
echo "✓ Usuário registrado e autenticado"
echo "✓ Pagamento criado com reference_id único"
echo "✓ Pagamento processado assincronamente"
echo "✓ Status verificado em tempo real"
echo "✓ Estatísticas consultadas"
echo "✓ Webhook configurado"

echo -e "\n${BLUE}📊 Dashboard em Tempo Real:${NC}"
echo "Acesse: http://localhost:4000/dashboard"
echo "Login com as credenciais do usuário criado acima"

echo -e "\n${YELLOW}🚀 Próximos Passos:${NC}"
echo "1. Abra http://localhost:4000/dashboard"
echo "2. Confirme vários pagamentos"
echo "3. Observe as métricas atualizarem em tempo real"
echo "4. Explore a API com Postman ou cURL"

echo -e "\n${GREEN}✅ Demonstração Completa!${NC}\n"
