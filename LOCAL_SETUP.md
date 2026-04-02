# 💻 Setup Local (sem Docker)

## ✅ Pré-requisitos instalados:

1. **Erlang 25.3.2.4+** ✅ (você está instalando)
2. **Elixir 1.16.2** ✅ (já tem)
3. **PostgreSQL 15** (ou similar)
4. **Redis 7** (opcional, para Oban)

## 🚀 Passos de Setup:

### 1. Esperar Erlang compilar completamente

Deixe `asdf install erlang 25.3.2.4` terminar (pode levar 5-15 minutos).

Quando terminar, você verá:
```
[asdf-erlang] ✨ Build succeeded!
```

### 2. Verificar instalação:

```bash
erl -version
# Deve mostrar: Erlang/OTP 25

elixir --version
# Deve mostrar: Elixir 1.16.2 (compiled with Erlang/OTP 24)
```

### 3. Verificar PostgreSQL:

```bash
# Se no Ubuntu/Debian:
sudo service postgresql status
sudo service postgresql start

# Se no Mac:
brew services start postgresql

# Testar conexão:
psql -U postgres -c "SELECT version();"
```

### 4. Preparar ambiente:

```bash
cd ~/projetosvscode/ElixirPagamento/backend

# Copiar variáveis de ambiente
cp .env.local .env

# OU manual:
# export DATABASE_URL="ecto://postgres:postgres@localhost:5432/phoenix_pay_repo"
# export JWT_SECRET="your_secret_here"
```

### 5. Instalar dependências:

```bash
cd ~/projetosvscode/ElixirPagamento/backend

rm -rf mix.lock mix.exs.lock deps/

mix deps.get --only dev

# Se travar, force:
mix deps.get --force
```

### 6. Preparar banco de dados:

```bash
# Criar banco
mix ecto.create

# Migrar
mix ecto.migrate

# Seed (dados iniciais)
mix run priv/repo/seeds.exs
```

### 7. Rodar servidor:

```bash
mix phx.server
```

Deve mostrar:
```
[info] Running PhoenixPayWeb.Endpoint with cowboy 2.14.2
[info] Access PhoenixPayWeb.Endpoint at http://localhost:4000
```

### 8. Acessar:

- **Swagger UI**: `http://localhost:4000/api/docs` 📚
- **App**: `http://localhost:4000` 🌐
- **Dashboard**: `http://localhost:4000/dashboard` 📊 (dev only)

---

## 🐛 Troubleshooting:

### Erro: "No such directory /var/run/postgresql"

```bash
# Criar diretório
sudo mkdir -p /var/run/postgresql
sudo chown postgres:postgres /var/run/postgresql
sudo service postgresql restart
```

### Erro: "mix compile" fails

```bash
# Limpar e tentar novamente
rm -rf _build deps mix.exs.lock
mix clean
mix deps.get --force
mix deps.compile
```

### Erlang compilation error (parsetools)

```bash
# Significa que o Erlang não foi compilado corretamente
# Solução: use a versão mais recente
asdf uninstall erlang 25.3.2.4
asdf install erlang 25.3.2.21
asdf global erlang 25.3.2.21
```

### Redis connection refused

```bash
# Se não precisa de Redis, comentar em .env:
# OBAN_QUEUES_REDIS_URL=redis://localhost:6379

# OU instalar e rodar Redis:
brew install redis  # Mac
sudo apt install redis-server  # Ubuntu
redis-server
```

---

## ⚡ Guia rápido (próximas vezes):

```bash
cd ~/projetosvscode/ElixirPagamento/backend

# Terminal 1: Servidor
mix phx.server

# Terminal 2: IEx (console)
iex -S mix phx.server

# Terminal 3: Mix tasks
mix ecto.migrate
mix run priv/repo/seeds.exs
```

---

## 📝 Verificação rápida:

```bash
# Tudo funcionando?
curl http://localhost:4000/api/docs
echo "Se abrir a UI do Swagger, está OK! ✅"
```

---

**Próximos passos quando o Erlang terminar de compilar: execute o passo 3 acima! 🚀**
