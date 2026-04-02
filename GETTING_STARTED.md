### 🎯 Como Começar Rapidamente

#### Passo 1: Clonar e Instalar

```bash
cd ElixirPagamento-1

# Instalar Elixir (se não tiver):
# - Linux: `asdf install elixir 1.14 && asdf global elixir 1.14`
# - macOS: `brew install elixir`
# - Windows: https://elixir-lang.org/install.html

# Instalar dependências
mix deps.get

# Opcional: Instalar Elixir LS para VS Code
# https://marketplace.visualstudio.com/items?itemName=JakeBecker.elixir-ls
```

#### Passo 2: Banco de Dados

```bash
# ===== OPÇÃO A: Supabase (Recomendado - Gratuito) =====
# 1. Criar conta: https://app.supabase.com
# 2. New Project → Copiar connection string
# 3. Configurar .env:

cp .env.example .env
# Editar com: DATABASE_HOST, DATABASE_USER, DATABASE_PASSWORD

# 4. Rodar migrations no Supabase
mix ecto.migrate

# ===== OPÇÃO B: Docker (Local) =====
# 1. Iniciar PostgreSQL
docker-compose up -d
# Aguarde ~5s

# 2. Criar banco
mix ecto.create

# 3. Rodar migrations
mix ecto.migrate

# ===== CARREGAR DADOS DEMO =====
mix run priv/repo/seeds.exs
```

📖 **Detalhes Supabase:** Ver [SUPABASE_SETUP.md](SUPABASE_SETUP.md)

#### Passo 3: Rodar Servidor

```bash
mix phx.server
```

**Output esperado:**
```
[info] Running PhoenixPayWeb.Endpoint with cowboy 2.10.0 at 127.0.0.1:4000
[info] Access the application at http://127.0.0.1:4000
Press CTRL-C to stop
```

✅ Pronto! Acesse: http://localhost:4000

#### Passo 4: Autenticar

**Login rápido:**
- Email: `demo@phoenixpay.com`
- Senha: `senha123456`

**Ou registrar novo usuário:**
- POST /api/v1/register com seu email

---

### 🧪 Testar a API

#### Setup: Salvar Token

```bash
# Em um novo terminal:
curl -X POST http://localhost:4000/api/v1/login \
  -H "Content-Type: application/json" \
  -d '{"email":"demo@phoenixpay.com","password":"senha123456"}' \
  | jq '.token'

# Resultado: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
# Salvar em variável:
TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

#### Criar Pagamento

```bash
curl -X POST http://localhost:4000/api/v1/payments \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "amount": "250.50",
    "description": "Laptop novo",
    "payment_method": "pix"
  }' | jq .

# Salve o payment_id retornado:
PAYMENT_ID="550e8400-e29b-41d4-a716-446655440000"
```

#### Confirmar Pagamento

```bash
curl -X POST http://localhost:4000/api/v1/payments/$PAYMENT_ID/confirm \
  -H "Authorization: Bearer $TOKEN" | jq .

# Aguarde 1-3 segundos (simulação)
# Então verifique:
curl -X GET http://localhost:4000/api/v1/payments/$PAYMENT_ID/status \
  -H "Authorization: Bearer $TOKEN" | jq .

# Status mudou para "paid"? ✅
```

#### Ver Dashboard em Tempo Real

```
Abrir: http://localhost:4000/dashboard

Observar:
1. Métrica de "Taxa de Conversão" em tempo real
2. "Pagamentos Pendentes" atualiza
3. "Volume Total" aumenta
4. Sem recarregar a página!
```

---

### 📚 Estrutura de Pastas Explicada

Abri no VS Code com `code .` e explore:

```
lib/
├── phoenix_pay/
│   ├── accounts.ex
│   │   └── Context: login, criar usuário
│   │
│   ├── payments.ex
│   │   └── Context: criar/confirmar pagamento, stats
│   │
│   ├── webhooks.ex
│   │   └── Context: criar/atualizar/deletar webhooks
│   │
│   ├── accounts/
│   │   └── user.ex (Schema)
│   │
│   ├── payments/
│   │   ├── payment.ex (Schema)
│   │   └── transaction.ex (Schema)
│   │
│   └── webhooks/
│       ├── webhook.ex (Schema)
│       └── webhook_log.ex (Schema)
│
├── phoenix_pay_web/
│   ├── controllers/
│   │   ├── api/
│   │   │   ├── auth_controller.ex
│   │   │   ├── payment_controller.ex
│   │   │   ├── stats_controller.ex
│   │   │   ├── transaction_controller.ex
│   │   │   └── webhook_controller.ex
│   │   │
│   │   ├── auth_controller.ex (Web)
│   │   └── page_controller.ex (Home)
│   │
│   ├── live/
│   │   ├── dashboard_live/
│   │   │   └── index.ex (Dashboard com stats)
│   │   │
│   │   ├── payments_live/
│   │   │   └── index.ex (Lista + criar pagamentos)
│   │   │
│   │   └── webhooks_live/
│   │       └── index.ex (Gerenciar webhooks)
│   │
│   ├── workers/
│   │   ├── payment_workers.ex
│   │   │   └── PaymentSimulationWorker
│   │   │
│   │   └── webhook_workers.ex
│   │       └── WebhookDispatchWorker
│   │
│   ├── plugs.ex (Middleware: autenticação)
│   ├── router.ex (Rotas HTTP)
│   ├── endpoint.ex (Configuração Phoenix)
│   └── telemetry.ex (Monitoramento)
│
├── config/
│   ├── config.exs (Base)
│   ├── dev.exs
│   ├── prod.exs
│   └── test.exs
│
└── priv/
    └── repo/
        ├── migrations/ (Create tables)
        └── seeds.exs (Dados de demo)
```

---

### 🛠️ Comandos Úteis

```bash
# Recompile (se mexer em código)
# Já faz auto-reload em :dev

# Apenas resetar banco
mix ecto.reset
# = drop + create + migrate + seeds

# Entrar no console Elixir
iex -S mix

# No console:
# Criar usuário:
{:ok, user} = PhoenixPay.Accounts.create_user(%{
  "email" => "test@test.com",
  "name" => "Test",
  "password" => "pass123"
})

# Listar pagamentos:
PhoenixPay.Payments.list_user_payments(user.id)

# Help:
help()
exit()
```

---

### 🐛 Troubleshooting

**"Port 4000 already in use"**
```bash
# Matar processo na porta 4000:
lsof -i :4000
kill -9 <PID>

# Ou usar porta diferente:
PHX_PORT=4001 mix phx.server
```

**"Database doesn't exist"**
```bash
mix ecto.drop --quiet
mix ecto.create
mix ecto.migrate
```

**"Dependências com erro"**
```bash
rm -rf deps _build
mix deps.get
mix compile
```

**Migrations com erro**
```bash
# Ver status:
mix ecto.migrations

# Rollback último:
mix ecto.rollback

# Rollback específico:
mix ecto.rollback --step 2
```

---

### 📖 Próximos Passos

1. **Explore a API** (seção anterior deste guia)
2. **Modifique a UI** - Editar templates em `lib/phoenix_pay_web/live/`
3. **Adicione campos** - Criar migration + atualizar Schema
4. **Escreva testes** - Em `test/` seguindo padrão Elixir
5. **Deploy** - Docker ou Heroku (instruções no README)

---

### 🎓 Aprender Mais

**Elixir Basics:**
- Pattern matching: https://elixirschool.com/pt/lessons/basics/pattern_matching/
- Pipes: https://elixirschool.com/pt/lessons/basics/pipe_operator/
- Structs: https://elixirschool.com/pt/lessons/basics/structs/

**Phoenix & Ecto:**
- Contexts: https://hexdocs.pm/phoenix/contexts.html
- Ecto Changesets: https://hexdocs.pm/ecto/Ecto.Changeset.html
- LiveView: https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html

**Este Projeto:**
- ARCHITECTURE.md (explicação completa)
- README.md (features + API)
- Código comentado em `lib/`

---

### ❓ Perguntas Comuns

**P: Por que Elixir?**
R: Concorrência massiva, tolerância a falhas, hot reload, REPL poderoso.

**P: Como conecta com Pix real?**
R: Integrar com API Bacen. Arquivo templates em `lib/phoenix_pay/payments/pix_service.ex` (A fazer).

**P: Por que Oban?**
R: Filas confiáveis mesmo com restart. Redis/PostgreSQL backed.

**P: Qual é o custo de deploy?**
R: Elixir é eficiente. 1 servidor para 100k+ conexões. Barato em produção.

---

**🎉 Divirta-se explorando o código!**
