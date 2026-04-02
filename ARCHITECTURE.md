⚙️ ARQUITETURA DO PHOENIXPAY

## 1. Estrutura em Camadas

```
                    ┌─────────────────────┐
                    │   Clients/Frontend  │
                    └──────────┬──────────┘
                               │
                    ┌──────────▼──────────┐
                    │    Phoenix Router   │
                    │  (phoenix_pay_web)  │
                    └──────────┬──────────┘
                               │
        ┌──────────────────────┼──────────────────────┐
        │                      │                      │
    ┌───▼────┐          ┌──────▼──────┐          ┌──▼────┐
    │Browser │          │   API REST  │          │WebJob │
    │ Pages  │          │ + LiveView  │          │Worker │
    └─────┬──┘          └──────┬──────┘          └──┬────┘
          │                    │                    │
    ┌─────▼─────────────────────▼────────────────────▼───┐
    │         Phoenix Plugs & Controllers                │
    │         phx_pay_web/controllers/*                  │
    └─────────────┬──────────────────────────────────────┘
                  │
    ┌─────────────▼──────────────────────────────────┐
    │        Contexts (Business Logic)               │
    │  lib/phoenix_pay/{accounts,payments,webhooks}  │
    └──────────┬──────────────────────┬──────────────┘
               │                      │
        ┌──────▼──────┐      ┌────────▼────────┐
        │   Schemas   │      │   Repositories  │
        │   (Ecto)    │      │   (Queries)     │
        └──────┬──────┘      └────────┬────────┘
               │                      │
               └──────────┬───────────┘
                          │
               ┌──────────▼──────────┐
               │    PostgreSQL DB    │
               │    (Persistent)     │
               └─────────────────────┘

               ┌──────────────────────┐
               │    Oban Job Queue    │
               │    (Redis/DB)        │
               └──────────────────────┘
```

## 2. Contextos (Business Logic)

### Accounts Context (User Management)
```
PhoenixPay.Accounts
├── create_user/1              # Criar novo usuário
├── authenticate/2             # Login (email + password)
├── get_user!/1               # Obter usuário por ID
├── get_user_by_email/1       # Obter por email
├── update_user/2             # Atualizar perfil
├── list_users/0              # Listar todos
└── count_active_users/0      # Contar ativos

Schemas:
└── User (email, name, password_hash, cpf, phone, status)
```

### Payments Context (Core Business)
```
PhoenixPay.Payments
├── create_payment/1          # Criar cobrança
├── get_payment!/1            # Obter por ID
├── get_payment_by_reference/1 # Obter por reference_id
├── list_user_payments/1      # Listar pagamentos do usuário
├── confirm_payment/1         # Confirmar pagamento (PAID)
├── fail_payment/1            # Marcar como FAILED
├── get_payment_stats/1       # Stats por usuário
├── get_dashboard_stats/0     # Stats globais
├── create_transaction/1      # Criar transação
├── confirm_transaction/2     # Marcar transação como SUCCESS
└── fail_transaction/2        # Marcar como FAILED

Schemas:
├── Payment      (reference_id, amount, status, payment_method, metadata)
└── Transaction  (type, amount, status, external_id)

Real-Time:
└── PubSub: "payments:#{user_id}" → broadcast updates
```

### Webhooks Context (Event Dispatch)
```
PhoenixPay.Webhooks
├── create_webhook/1         # Criar novo webhook
├── get_webhook!/1           # Obter por ID
├── list_user_webhooks/1     # Listar webhooks do usuário
├── update_webhook/2         # Atualizar (URL, events, active)
├── delete_webhook/1         # Deletar
├── create_webhook_log/1     # Logar tentativa
├── list_webhook_logs/2      # Histórico de tentativas
└── find_webhooks_for_event/2 # Encontrar webhooks para evento

Schemas:
├── Webhook    (url, events, active, secret, retry_count)
└── WebhookLog (event, status_code, success, attempt, response_body)
```

## 3. Controllers (Web Interface)

### API Controllers
```
PhoenixPayWeb.API
├── AuthController
│   ├── register/2          # POST /api/v1/register
│   └── login/2             # POST /api/v1/login
│
├── PaymentController
│   ├── index/2             # GET /api/v1/payments
│   ├── create/2            # POST /api/v1/payments
│   ├── show/2              # GET /api/v1/payments/:id
│   ├── confirm/2           # POST /api/v1/payments/:id/confirm
│   └── status/2            # GET /api/v1/payments/:id/status
│
├── TransactionController
│   ├── index/2             # GET /api/v1/transactions
│   └── show/2              # GET /api/v1/transactions/:id
│
├── WebhookController
│   ├── index/2             # GET /api/v1/webhooks
│   ├── create/2            # POST /api/v1/webhooks
│   ├── update/2            # PUT /api/v1/webhooks/:id
│   ├── delete/2            # DELETE /api/v1/webhooks/:id
│   └── logs/2              # GET /api/v1/webhooks/:id/logs
│
└── StatsController
    ├── index/2             # GET /api/v1/stats (globais)
    └── user_stats/2        # GET /api/v1/stats/user
```

## 4. LiveView (Real-Time UI)

```
PhoenixPayWeb.Live
├── DashboardLive.Index
│   ├── mount/3            # Conectar e inscrever em eventos
│   ├── handle_info/2      # Receber atualizações PubSub
│   └── render/1           # HTML template
│
├── PaymentsLive.Index
│   ├── mount/3
│   ├── handle_info/2
│   ├── handle_event/3     # Criar pagamento (form submit)
│   └── render/1
│
└── WebhooksLive.Index
    ├── mount/3
    ├── handle_info/2
    └── render/1

Integração:
└── PubSub: inscreve em "payments:#{user_id}"
   └── Recebe: {:payment_updated, payment}
   └── Auto-render com novos dados
```

## 5. Workers (Async Processing)

### Oban Job Queue
```
PhoenixPayWeb.Workers

PaymentConfirmationWorker
└── enqueue(payment_id)
    └── Dispara PaymentSimulationWorker
        └── Delay: 1-3 segundos
        └── 95% success → confirm_payment + create_transaction
        └── 5% fail → fail_payment
        └── Ambos: enqueue WebhookDispatchWorker

WebhookDispatchWorker (max_attempts: 5)
└── Busca webhooks para evento
└── Para cada webhook:
    ├── Monta payload JSON
    ├── Gera HMAC-SHA256 signature
    ├── POST com headers (X-Webhook-Signature, X-Webhook-Event)
    └── Log tentativa (success/error)
└── Se falha: reschedule em 60s
└── Até 5 tentativas = resiliente ✓
```

## 6. Fluxo de Autenticação

```
┌─────────────────────┐
│ POST /api/v1/login  │
│ {email, password}   │
└──────────┬──────────┘
           │
    ┌──────▼──────────────┐
    │ AuthController      │
    │ accounts.authenticate│
    └──────┬──────────────┘
           │
    ┌──────▼──────────────────┐
    │ Bcrypt.verify_pass      │
    │ (compara password_hash) │
    └──────┬──────────────────┘
           │
      ┌────▼─────┐
      │ JWT Encode│ → Payload: {"sub": user_id, "iat": ..., "exp": ...}
      └────┬─────┘
           │
    ┌──────▼─────────────────┐
    │ Response               │
    │ {user_id, token, ...}  │
    └────────────────────────┘

┌────────────────────────────┐
│ Requisição com Token       │
│ GET /api/v1/payments       │
│ Authorization: Bearer XXX  │
└──────────┬─────────────────┘
           │
    ┌──────▼────────────────┐
    │ APIAuthPlug           │
    │ JWT.decode(token)     │
    └──────┬─────────────────┘
           │
    ┌──────▼──────────────────┐
    │ assign(:current_user_id)│
    │ Passa para action       │
    └────────────────────────┘
```

## 7. Real-Time Update Flow

```
1. Browser conecta ao LiveView
   └──> mount/3 (subscribe PubSub)
   └──> "payments:user_123"

2. API confirma pagamento
   └──> POST /api/v1/payments/:id/confirm
   └──> Payments.confirm_payment/1
   └──> PhoenixPay.PubSub.broadcast(
         "payments:user_123",
         {:payment_updated, updated_payment}
       )

3. LiveView recebe evento
   └──> handle_info/2
   └──> Recarrega dados (get_dashboard_stats/0)
   └──> render/1 renderiza HTML novo
   └──> Envia diff para browser (não complet refresh)

4. Browser atualiza DOM
   └──> Sem F5 ✓
   └──> Sem blink ✓
   └──> Experiência suave ✓
```

## 8. Banco de Dados Schema

```
users
├── id (UUID)
├── email (unique)
├── name
├── password_hash
├── cpf
├── phone
└── status (enum)

payments
├── id (UUID)
├── user_id (FK)
├── reference_id (unique)    ← Imutável!
├── amount
├── description
├── status (enum: pending, processing, paid, failed, ...)
├── payment_method (enum: pix, boleto, card)
├── idempotency_key (unique) ← Evita duplicação
├── paid_at
├── metadata (JSONB)
└── created_at

transactions
├── id (UUID)
├── user_id (FK)
├── payment_id (FK)
├── type (enum: debit, credit, transfer, refund)
├── amount
├── status (enum: success, pending, failed)
├── external_id
└── metadata

webhooks
├── id (UUID)
├── user_id (FK)
├── url
├── events (array)
├── active (boolean)
├── secret           ← Para HMAC signature
├── retry_count
└── last_triggered_at

webhook_logs
├── id (UUID)
├── webhook_id (FK)
├── payment_id (FK)
├── event
├── status_code
├── response_body
├── attempt
├── success
└── created_at
```

## 9. Configuração por Ambiente

```
config/config.exs (base)
├── Oban job queues
├── Gettext
├── General settings

config/dev.exs
├── Localhost
├── Debug logs
├── Live reload

config/prod.exs
├── HTTPS
├── SSL
├── Performance tuning

config/test.exs
├── SQLite/Sandbox
├── Logging desligado
```

## 10. Segurança - Camadas

```
Layer 1: Plugs
└── RequireAuth → verifica session ou JWT
└── APIAuth → valida JWT token

Layer 2: Contextos
└── Validação em changesets
└── Password hash com bcrypt
└── Unique constraints em DB

Layer 3: Database
└── Foreign keys + constraints
└── Unique indexes
└── Transactions

Layer 4: Webhooks
└── HMAC-SHA256 signature
└── Retry logic
└── Request logging
```

## 11. Performance Considerations

- **N+1 Queries**: Uso de `preload/1` em Ecto
- **Idempotência**: Evita pagamentos duplicados
- **Async**: Oban para jobs pesados
- **Caching**: PubSub para broadcast (não refetch)
- **Indexing**: Índices em foreign keys + status

## 12. Testing Strategy (A vir)

```
Unit Tests
└── Contexts (Accounts, Payments, Webhooks)
    ├── create_user/1
    ├── authenticate/2
    ├── confirm_payment/1
    └── webhook dispatch

Controller Tests
└── API endpoints
    ├── auth (login, register)
    ├── payments (CRUD)
    └── webhooks (create, update, delete)

LiveView Tests
└── Dashboard
    ├── mount
    ├── handle_info
    └── rendering

Integration Tests
└── Full flow
    ├── Register → Login → Create Payment → Confirm
    ├── Webhook dispatch
    └── Real-time updates
```

---

**Padrões Utilisados:**

✅ **Clean Architecture** - Separação clara de responsabilidades
✅ **Hexagonal Architecture** - Adapters/Controllers separados da lógica
✅ **Domain-Driven Design** - Contexts representam domínio
✅ **Event Sourcing** - PubSub para comunicação entre camadas
✅ **Repository Pattern** - Ecto queries abstraídas
✅ **Factory Pattern** - Changesets para criar objetos válidos
