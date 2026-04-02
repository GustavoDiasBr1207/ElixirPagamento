# 🎤 ENTREVISTA - Como Apresentar Este Projeto

## 📝 Script Sugerido (2-3 minutos)

### Abertura

"Desenvolvi um **sistema de pagamentos em tempo real** chamado **PhoenixPay** que foi especificamente desenhado para demonstrar exatamente o que vocês estavam procurando na vaga."

### O Problema (context)

"Fintechs precisam de três coisas críticas:
1. **Processamento de cash in confiável** - cobranças que funcionam
2. **Tempo real** - sem lag, atualizações instantâneas
3. **Conversão** - entender o funil de pagamentos

Peguei essas três coisas e criei um projeto que passa por todas."

### A Solução (tech)

"Uso **Elixir com Phoenix Framework** porque:
- Concorrência massiva (Erlang VM)
- Tolerância a falhas automática
- Hot reload (desenvolvimento mais rápido)

A arquitetura segue o padrão de **Contexts**, que separa:
- **Accounts** - gestão de usuários
- **Payments** - processamento de cobranças
- **Webhooks** - eventos em tempo real"

### Core Features

**1. Criar Cobrança**
```bash
POST /api/v1/payments
{
  "amount": 150.00,
  "description": "Produto X"
}
```

Sistema gera um **reference_id** immutável (PIX_...) e retorna status `pending`.

**2. Processamento Assíncrono**
"Use **Oban** - fila de jobs confiável. Quando o usuário confirma o pagamento:
- Enfileira job com **idempotency_key** (evita duplicação)
- Delay simulado de 1-3 segundos (realismo)
- 95% sucesso → `PAID`
- 5% falha → `FAILED` (teste resiliência)"

**3. Dashboard em Tempo Real**
"O dashboard usa **Phoenix LiveView** - não é um SPA.

Quando um pagamento é confirmado:
1. Backend publica evento via **PubSub**
2. LiveView recebe (via WebSocket)
3. Dashboard re-renderiza (sem reload)
4. Métrica de conversão atualiza em tempo real"

**4. Webhooks Inteligentes**
"Quando pagamento confirma, dispara webhook para URL customizada:
- **HMAC-SHA256** signature (segurança)
- **Retry automático** (5 tentativas, backoff)
- **Logs completos** (auditoria)"

### O Diferencial

"Três pontos te destacam aqui:

1. **Elixir correto**
   - Não é só uma linguagem 'cool'
   - Usei padrões do Phoenix (Contexts, Changesets)
   - Processamento assíncrono robusto

2. **Real-Time Thinking**
   - LiveView (não React/Vue)
   - PubSub (broadcast entre conexões)
   - User vê atualizações sem F5

3. **Production Mindset**
   - Idempotência (não é 'nice-to-have')
   - Retry logic
   - Auditoria completa
   - Migrations versionadas"

### Demo Ao Vivo

Se tiver tempo/permissão:

```bash
# 1. Registrar usuário
curl -X POST http://localhost:4000/api/v1/register \
  -H "Content-Type: application/json" \
  -d '{"email":"demo@test.com","name":"Demo","password":"pass123"}'

# 2. Copiar token da resposta

# 3. Criar pagamento
curl -X POST http://localhost:4000/api/v1/payments \
  -H "Authorization: Bearer <TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"amount":"100.00","description":"Test"}'

# 4. Abrir dashboard em http://localhost:4000/dashboard
# (Login com credenciais acima)

# 5. Confirmar pagamento via API
curl -X POST http://localhost:4000/api/v1/payments/<ID>/confirm \
  -H "Authorization: Bearer <TOKEN>"

# 6. Observar dashboard
# - Taxa de conversão atualiza
# - Métricas mudam em tempo real
# - Sem refresh!
```

### Stack (prepare-se para pergunta)

"Tech stack é:
- **Elixir 1.14+** - Linguagem
- **Phoenix 1.7** - Web framework
- **Phoenix LiveView** - UI tempo real
- **Ecto** - ORM + validação
- **PostgreSQL** - Persistência
- **Oban** - Job queue
- **Bcrypt** - Password hashing
- **JWT** - Autenticação
- **HMAC-SHA256** - Webhook signatures"

### Respostas para Perguntas Comuns

**P: Por que Elixir e não Node?**
R: "Elixir é melhor para sistemas que precisam processar muito concorrentemente e recuperar de falhas. A Erlang VM é batida no mercado para isso. Além disso, o Phoenix LiveView é imbatível em real-time sem JavaScript."

**P: Escalabilidade?**
R: "Uma instância Elixir roda 100k+ conexões simultâneas. PostgreSQL em multitenant pode crescer. Oban persiste jobs mesmo com restart."

**P: Por que não usar framework X?**
R: "Escolhi Elixir porque cumpre o brief: cash in + tempo real + conversão. Node é mais populoso mas não é tão bom em resiliência. Go é rápido mas menos expressivo."

**P: Quanto tempo levou?**
R: "Projeto completo ~8 horas (estrutura + código + testes + docs). Código está documentado e limpo."

### Fechamento

"Este projeto não é apenas um CRUD. Demonstra:
- Compreensão de arquitetura real (Contexts, Workers)
- Processamento confiável (idempotência, retry)
- Real-time thinking (LiveView, PubSub)
- Production mindset (migrations, logs, auditoria)

E mais importante: **resolve exatamente os problemas que vocês mencionaram na vaga**."

---

## 🎬 Roteiro Visual (se apresentar tela)

### Slide 1: Visão Geral
```
PhoenixPay
├── 🏦 Pagamentos em Tempo Real
├── 📊 Dashboard com Métricas
├── 🔄 Webhooks Confiáveis
└── ⚡ Processamento Assíncrono
```

### Slide 2: Stack
```
Frontend: LiveView (Phoenix)
Backend: Elixir + Phoenix
Database: PostgreSQL
Jobs: Oban
Auth: JWT + Bcrypt
```

### Slide 3: Fluxo
```
1. User cria pagamento → reference_id PIX_*
2. User confirma → enfileira job
3. Job espera 1-3s → confirma/nega
4. Dashboard atualiza via WebSocket
5. Webhook dispara com retry
```

### Slide 4: Código Exemplo
```elixir
def create_payment(attrs) do
  %Payment{}
  |> Payment.changeset(attrs)    # Validação
  |> Repo.insert()               # Salva
  |> broadcast_change()          # PubSub!
end
```

---

## ✅ Checklist Antes da Entrevista

- [ ] Servidor rodando (mix phx.server)
- [ ] PostgreSQL + Redis disponíveis
- [ ] Seeds executados (mix run priv/repo/seeds.exs)
- [ ] API testada com curl (pelo menos login + create payment)
- [ ] Dashboard acessível (http://localhost:4000/dashboard)
- [ ] Terminal limpo para mostrar código
- [ ] VS Code sem abas aleatórias abertas
- [ ] Wi-Fi testado (se será remoto)
- [ ] Câmera + áudio funcionando
- [ ] Documentação impressa ou em segundo monitor

---

## 🎯 Pontos Finais

1. **Seja conciso** - 2-3 minutos de pitch, resto é Q&A
2. **Foco na vaga** - Sempre voltar ao "Cash In + Tempo Real + Conversão"
3. **Code over talk** - Mostre código, não só diagramas
4. **Humble but confident** - "Construí isto" não "Construí isto perfeito"
5. **Prepare respostas** - Não "não sei", diga "boa pergunta, deixa eu pensar..."

---

## 💬 Frases que Funcionam

- "Decidi usar Oban porque..."
- "O LiveView aqui particular resolve X"
- "Pensamos em idempotência desde o início"
- "A vaga pedia time real, então..."
- "Para production, eu adicionaria..."

---

**🚀 Boa sorte! Você tem um projeto MUITO forte aqui.**
