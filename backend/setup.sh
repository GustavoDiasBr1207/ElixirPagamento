#!/bin/bash
# 🚀 Setup Local rápido

set -e

echo "📦 Instalando dependências..."
mix deps.get

echo "🔨 Compilando dependências..."
mix deps.compile

echo "🗄️  Criando banco de dados..."
mix ecto.create

echo "📝 Executando migrações..."
mix ecto.migrate

echo "🌱 Carregando seeds..."
mix run priv/repo/seeds.exs

echo ""
echo "✅ Setup completo!"
echo ""
echo "🚀 Para rodar o servidor:"
echo "   mix phx.server"
echo ""
echo "📍 Acesse:"
echo "   Swagger UI: http://localhost:4000/api/docs"
echo "   App: http://localhost:4000"
