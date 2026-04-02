# 🐳 Executar com Docker (Recomendado)

## Por que usar Docker?

- ✅ Erlang/OTP pré-compilado e correto
- ✅ Sem problemas de dependências locais
- ✅ Ambiente consistente
- ✅ PostgreSQL e Redis já inclusos

## 🚀 Setup com Docker:

### 1. Criar arquivo `.env` (se não existir):

```bash
cd ~/projetosvscode/ElixirPagamento/backend
cp .env.example .env
```

Edite `.env` e defina:
```
JWT_SECRET=seu_secret_super_seguro_aqui_mude_em_producao
DATABASE_URL=ecto://postgres:postgres@postgres:5432/phoenix_pay_repo
REDIS_URL=redis://redis:6379
PORT=4000
```

### 2. Rode o Docker Compose:

```bash
cd ~/projetosvscode/ElixirPagamento/backend
docker-compose up
```

### 3. Em outro terminal, execute as migrações:

```bash
docker-compose exec app mix ecto.migrate
docker-compose exec app mix run priv/repo/seeds.exs
```

### 4. Acesse:

- **Swagger UI**: `http://localhost:4000/api/docs`
- **Spec OpenAPI**: `http://localhost:4000/api/openapi.json`
- **API**: `http://localhost:4000/api/v1`

## 🛑 Para parar:

```bash
docker-compose down
```

## 🧹 Para limpar tudo:

```bash
docker-compose down -v  # Remove volumes também
```

## 📝 Troubleshooting:

**Erro ao compilar?**
```bash
docker-compose build --no-cache
docker-compose up
```

**Banco de dados vazio?**
```bash
docker-compose exec app mix ecto.reset
```

**Rebuild rápido:**
```bash
docker-compose up --build
```

---
**Muito mais fácil que lidar com asdf! 🎉**
