# 🔌 Supabase + Elixir - Cheat Sheet

## Variáveis de Ambiente

```env
# Obter em: Settings → Database → Connection String
DATABASE_URL=postgresql://postgres:PASSWORD@db.xxxxx.supabase.co:5432/postgres

# Ou separadas:
DATABASE_USER=postgres
DATABASE_PASSWORD=sua_senha_aqui
DATABASE_HOST=db.xxxxx.supabase.co
DATABASE_PORT=5432
DATABASE_NAME=postgres
DATABASE_SSL=true
```

## Comandos Rápidos

```bash
# Testar conexão
mix ecto.load

# Rodar migrations
mix ecto.migrate

# Rollback
mix ecto.rollback

# Ver status
mix ecto.migrations

# Carregar seeds
mix run priv/repo/seeds.exs

# Entrar no console com dados Supabase
iex -S mix
iex> PhoenixPay.Payments.list_user_payments("user_id")
```

## Verificar no Dashboard Supabase

1. Ir para https://app.supabase.com
2. Selecionar projeto
3. **SQL Editor** → rodar:

```sql
-- Ver tabelas
SELECT * FROM users LIMIT 5;
SELECT * FROM payments LIMIT 5;

-- Ver conexões ativas
SELECT * FROM pg_stat_activity;

-- Ver índices
SELECT * FROM pg_indexes WHERE tablename = 'payments';
```

## Troubleshooting

| Erro | Solução |
|------|---------|
| "Connection refused" | Verificar DATABASE_HOST, DATABASE_USER, DATABASE_PASSWORD |
| "SSL certificate error" | Garantir DATABASE_SSL=true |
| "Authentication failed" | Resetar senha em Supabase → Settings → Users |
| "Migrations not applying" | `mix ecto.rollback` → `mix ecto.migrate` |

## Supabase vs Local

| Aspecto | Supabase | Local Docker |
|--------|----------|-------------|
| Setup | 2 min | 5 min |
| Custo | Free | Free |
| Backup | Automático | Manual |
| SSL | Sempre | Opcional |
| Performance | ⭐⭐⭐⭐ | ⭐⭐⭐ |
| Escalabilidade | ⭐⭐⭐⭐⭐ | Limitada |
| Para apresentação | ✅ Melhor (live) | ✅ Bom (local) |

## Deployment Rápido

```bash
# Heroku (requer Heroku CLI)
heroku create seu-app-name
heroku config:set DATABASE_HOST=db.xxxxx.supabase.co
heroku config:set DATABASE_PASSWORD=sua_senha
heroku config:set DATABASE_USER=postgres
heroku config:set JWT_SECRET=$(openssl rand -base64 32)
git push heroku main
heroku run mix ecto.migrate

# Railway.app (recomendado)
npm i -g @railway/cli
railway init
railway variables DATABASE_HOST db.xxxxx.supabase.co
railway variables DATABASE_PASSWORD sua_senha
railway up
```

## Real-Time com Supabase (Bônus!)

Supabase oferece real-time subscriptions. Exemplo:

```elixir
{:ok, subscription} = Supabase.realtime_subscribe(
  channel: "payments:#{user_id}",
  event: "*"
)
```

Já implementado no projeto via **Phoenix PubSub**! 🎉

---

**Quer suporte?** Abrir issue no GitHub ou consultar [Supabase Docs](https://supabase.com/docs)
