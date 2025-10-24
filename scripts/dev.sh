#!/bin/bash

# Development startup script for Acquisition App with Neon Local
# This script starts the application in development mode with Neon Local

echo "🚀 Starting Acquisition App in Development Mode"
echo "================================================"

# Check if .env.development exists
if [ ! -f .env.development ]; then
    echo "❌ Error: .env.development file not found!"
    echo "   Please copy .env.example to .env.development and update with your Neon credentials."
    exit 1
fi

# Check if Neon API key is set
if ! grep -q "NEON_API_KEY=." .env.development; then
    echo "❌ Error: NEON_API_KEY not set in .env.development!"
    echo "   Please add your Neon API key to .env.development"
    echo "   Get your API key from: https://console.neon.tech/app/settings/api-keys"
    exit 1
fi

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    echo "❌ Error: Docker is not running!"
    echo "   Please start Docker Desktop and try again."
    exit 1
fi

# Create .neon_local directory if it doesn't exist
mkdir -p .neon_local

# Add .neon_local to .gitignore if not already present
if ! grep -q ".neon_local/" .gitignore 2>/dev/null; then
    echo ".neon_local/" >> .gitignore
    echo "✅ Added .neon_local/ to .gitignore"
fi

echo "📦 Building and starting development containers..."
echo "   - Neon Local proxy will create an ephemeral database branch"
echo "   - Application will run with hot reload enabled"
echo ""

# Run migrations with Drizzle
# Start development environment
echo "📜 Starting containers and waiting for services..."
docker compose -f docker-compose.dev.yml up --build -d

# Wait for Neon Local to be ready
echo "⏳ Waiting for Neon Local to be ready..."
while ! docker compose -f docker-compose.dev.yml exec neon-local pg_isready -h localhost -p 5432 -U neondb_owner >/dev/null 2>&1; do
  echo "   Still waiting for Neon Local..."
  sleep 3
done

# Run migrations with Drizzle
echo "📜 Applying latest schema with Drizzle..."
docker compose -f docker-compose.dev.yml exec app npm run db:migrate

# Show logs
echo ""
echo "🎉 Development environment started!"
echo "   Application: http://localhost:3000"
echo "   Database: Neon Local (ephemeral branch)"
echo ""
echo "Useful commands:"
echo "   View logs: docker compose -f docker-compose.dev.yml logs -f"
echo "   Stop environment: docker compose -f docker-compose.dev.yml down"
echo "   Run migrations: docker compose -f docker-compose.dev.yml exec app npm run db:migrate"
echo "   Access database: docker compose -f docker-compose.dev.yml exec neon-local psql -U neondb_owner -d neondb"
echo ""
echo "Following application logs (Ctrl+C to exit):"
docker compose -f docker-compose.dev.yml logs -f app
