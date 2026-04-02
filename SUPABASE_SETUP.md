# 🚀 Setup com Supabase

Este guia explica como configurar o **PhoenixPay** com **Supabase** em vez de PostgreSQL local.

## ✅ Por que Supabase?

- ✅ PostgreSQL na nuvem (sem gerenciar)
- ✅ Real-time subscriptions (bonus!)
- ✅ Authentication (JWT integrado)
- ✅ SSL automático
- ✅ Backups automáticos
- ✅ Dashboard web
- ✅ Free tier generoso

## 🔧 Setup Supabase (5 minutos)

### 1. Criar Projeto Supabase

1. Ir para https://app.supabase.com
2. Clicar em "New Project"
3. Preencher:
   - **Name**: `PhoenixPay`
   - **Database Password**: Salvar em local seguro
   - **Region**: Próximo de vocês
4. Aguardar ~2 min (cria PostgreSQL)

### 2. Obter Connection String

1. Após criar, abrir **Settings** → **Database** → **Connection String**
2. Selecionar **Postgres** (not psql)
3. Copiar URL:
   ```
   postgresql://postgres:[PASSWORD]@db.xxxxx.supabase.co:5432/postgres
   ```

### 3. Extrair Valores

Da string `postgresql://postgres:PASS@db.xxxxx.supabase.co:5432/postgres`:

- **DATABASE_USER**: `postgres`
- **DATABASE_PASSWORD**: `PASS`
- **DATABASE_HOST**: `db.xxxxx.supabase.co`
- **DATABASE_PORT**: `5432`
- **DATABASE_NAME**: `postgres`
- **DATABASE_SSL**: `true`

### 4. Configurar .env

```bash
cp .env.example .env
```

Editar `.env`:

```env
# Supabase
DATABASE_USER=postgres
DATABASE_PASSWORD=sua_senha_supabase_aqui
DATABASE_HOST=db.xxxxx.supabase.co
DATABASE_PORT=5432
DATABASE_NAME=postgres
DATABASE_SSL=true

# Elixir
MIX_ENV=dev
PHX_PORT=4000
PHX_HOST=localhost

# JWT
JWT_SECRET=sua_jwt_secret_mudada_em_prod
```

## 🗂️ Deploy Migrations

### Verificar Conexão

```bash
# Testar conexão (deve retornar "ping pong")
mix ecto.load
```

Se der erro, verificar `.env`

### Criar Tabelas

```bash
# Rodar migrations no Supabase
mix ecto.migrate
```

**Output esperado:**
```
[info] Migrations compiled in 234ms
[info] Migrated 20260401000001 in 0.15s - create_users
[info] Migrated 20260401000002 in 0.18s - create_payments
...
```

### Verificar no Dashboard Supabase

1. Acesar https://app.supabase.com
2. Selecionar projeto
3. Ir em **SQL Editor**
4. Rodar:
   ```sql
   SELECT * FROM users;
   SELECT * FROM payments;
   ```

Deve retornar tabelas vazias ✓

### Carregar Dados de Demo

```bash
# ⚠️ Supabase: editar seeds.exs com URL do Supabase
mix run priv/repo/seeds.exs
```

## ▶️ Rodar Localmente com Supabase

```bash
# Terminal 1: Servidor Phoenix
mix phx.server

# Terminal 2: Iex (opcional)
iex -S mix
```

Acesse:
- 🏠 http://localhost:4000
- 📊 http://localhost:4000/dashboard
- 📡 http://localhost:4000/api/v1/stats

## 🌐 Deploy em Produção

### Opção A: Heroku

```bash
# 1. Criar app
heroku create your-app-name

# 2. Configurar variáveis
heroku config:set DATABASE_USER=postgres
heroku config:set DATABASE_PASSWORD=sua_senha_supabase
heroku config:set DATABASE_HOST=db.xxxxx.supabase.co
heroku config:set DATABASE_PORT=5432
heroku config:set DATABASE_NAME=postgres
heroku config:set DATABASE_SSL=true
heroku config:set SECRET_KEY_BASE=$(mix phx.gen.secret)
heroku config:set JWT_SECRET=$(openssl rand -base64 32)

# 3. Deploy
git push heroku main

# 4. Rodar migrations
heroku run mix ecto.migrate

# 5. Ver logs
heroku logs --tail
```

### Opção B: Railway.app (Recomendado)

```bash
# 1. Instalar CLI
npm install -g @railway/cli

# 2. Login
railway login

# 3. Criar projeto
railway init

# 4. Linkar Supabase
railway link

# 5. Settings → Variables (adicionar Environment Vars)
# DATABASE_USER, DATABASE_PASSWORD, etc

# 6. Deploy
railway up
```

### Opção C: Fly.io

```bash
# 1. Instalar CLI
curl -L https://fly.io/install.sh | sh

# 2. Login
fly auth login

# 3. Criar app
fly launch

# 4. Configurar secrets
fly secrets set DATABASE_USER=postgres
fly secrets set DATABASE_PASSWORD=sua_senha
# ... resto das variáveis

# 5. Deploy
fly deploy
```

## 🐛 Troubleshooting Supabase

### ❌ "Connection refused"

```bash
# Verificar credenciais
echo $DATABASE_HOST
echo $DATABASE_USER
echo $DATABASE_PASSWORD

# Testar conexão
psql -h db.xxxxx.supabase.co \
     -U postgres \
     -d postgres \
     -c "SELECT 1"
```

### ❌ "SSL certificate problem"

Supabase usa SSL. Se erro de SSL:

```elixir
# config/config.exs
ssl_opts: [verify: :verify_none]  # ⚠️ Apenas dev!
```

Em produção, usar:
```elixir
ssl_opts: [
  verify: :verify_peer,
  cacerts: :public_key.cacerts_get()
]
```

### ❌ "Connection pool exhausted"

Aumentar pool size em `config/prod.exs`:

```elixir
config :phoenix_pay, PhoenixPay.Repo,
  pool_size: 20  # Aumentar de 10 para 20
```

### ❌ "Migrations not applying"

```bash
# Ver status
mix ecto.migrations

# Rollback last
mix ecto.rollback

# Reapply
mix ecto.migrate
```

## 📊 Monitorar com Supabase

### Via Dashboard

1. Abrir https://app.supabase.com
2. Projeto → **Database** → **Browser**
3. Ver tabelas, dados, queries

### Via pgAdmin (Supabase)

1. Projeto → **SQL Editor**
2. Rodar queries diretamente
3. Ver planos de execução

### Logs da App

```bash
# Heroku
heroku logs --tail

# Railway
railway logs

# Fly
fly logs
```

## 🔐 Segurança com Supabase

### 1. RLS (Row-Level Security)

Supabase suporta RLS! Exemplo:

```sql
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can only see own payments"
ON payments FOR SELECT
USING (auth.uid() = user_id::uuid);
```

### 2. Secrets Management

**Nunca comitar `.env`!**

```bash
# .gitignore
.env
.env.local
.env.*.local
```

Usar:
- Heroku: `heroku config:set VAR=value`
- Railway: UI Settings
- Fly: `fly secrets set VAR=value`

### 3. JWT Secret

```bash
# Gerar novo
openssl rand -base64 32

# Adicionar a config
export JWT_SECRET="seu_novo_secret"
```

## 📈 Performance com Supabase

### Índices Importantes

Já criados em migrations, mas verificar:

```sql
-- Ver índices
\d+ payments
\d+ webhooks
```

### Connection Pooling

Supabase tem limit de 40 conexões (free tier).

Se exceder, usar **PgBouncer**:

```sh
# Supabase → Settings → Database → Connection Pooling
Mode: Transaction
```

Depois usar URL de pooling (mudará o hostname).

## 🚀 Próximos Passos

- [ ] Criar projeto Supabase
- [ ] Copiar connection string
- [ ] Atualizar `.env`
- [ ] Rodar migrations (`mix ecto.migrate`)
- [ ] Testar API
- [ ] Deploy em produção

---

## 📚 Referências

- [Supabase Docs](https://supabase.com/docs)
- [Supabase+Elixir](https://supabase.com/docs/guides/getting-started/tutorials/with-elixir)
- [Ecto Repo Config](https://hexdocs.pm/ecto_sql/Ecto.Adapters.Postgres.html)
- [Heroku Deploy](https://devcenter.heroku.com/articles/deploying-phoenix)

---

**Conta gratuita Supabase = suficiente para MVP!** 🎉
