#!/bin/bash

# Production deployment script for Acquisition App
# This script starts the application in production mode with Neon Cloud Database

echo "🚀 Starting Acquisition App in Production Mode"
echo "==============================================="

# Check if .env.production exists
if [ ! -f .env.production ]; then
    echo "❌ Error: .env.production file not found!"
    echo "   Please create .env.production with your production environment variables."
    exit 1
fi

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    echo "❌ Error: Docker is not running!"
    echo "   Please start Docker and try again."
    exit 1
fi

echo "📦 Building and starting production container..."
echo "   - Using Neon Cloud Database (no local proxy)"
echo "   - Running in optimized production mode"
echo ""

# Start production environment
echo "📜 Building and starting production container..."
docker compose -f docker-compose.prod.yml up --build -d

# Wait for application to be ready
echo "⏳ Waiting for application to be ready..."
sleep 10

# Run migrations with Drizzle
echo "📜 Applying latest schema with Drizzle..."
docker compose -f docker-compose.prod.yml exec app npm run db:migrate

echo ""
echo "🎉 Production environment started!"
echo "   Application: http://localhost:3000"
echo "   Database: Neon Cloud (production)"
echo "   Container: acquisitions-app-prod"
echo ""
echo "Useful commands:"
echo "   View logs: docker compose -f docker-compose.prod.yml logs -f"
echo "   Stop app: docker compose -f docker-compose.prod.yml down"
echo "   Run migrations: docker compose -f docker-compose.prod.yml exec app npm run db:migrate"
echo "   Access container: docker compose -f docker-compose.prod.yml exec app sh"
