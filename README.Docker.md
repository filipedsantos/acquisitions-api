# Docker Setup Guide

This guide explains how to run the Acquisitions API using Docker with different configurations for development and production environments.

## Overview

- **Development**: Uses Neon Local via Docker for database operations with ephemeral branches
- **Production**: Uses Neon Cloud Database directly from the cloud

## Prerequisites

- Docker and Docker Compose installed
- Neon account with API access
- Node.js 18+ (for local development without Docker)

## Quick Start

### Development Environment

1. **Set up environment variables**:
   ```bash
   # Copy the example environment file
   cp .env.example .env.development
   
   # Edit .env.development with your Neon credentials
   # Get your API key from: https://console.neon.tech/app/settings/api-keys
   # Get your project ID from your Neon dashboard
   ```

2. **Start development environment**:
   ```bash
   npm run dev:docker
   # OR manually:
   # chmod +x scripts/dev.sh && ./scripts/dev.sh
   ```

3. **Access your application**:
   - Application: http://localhost:3000
   - Database: Available through Neon Local proxy at localhost:5432

### Production Environment

1. **Set up environment variables**:
   ```bash
   # Copy and configure production environment
   cp .env.example .env.production
   
   # Edit .env.production with your production values
   # Make sure to use your actual Neon Cloud database URL
   # Set a strong JWT secret
   ```

2. **Start production environment**:
   ```bash
   npm run prod:docker
   # OR manually:
   # chmod +x scripts/prod.sh && ./scripts/prod.sh
   ```

## Environment Configuration

### Development (.env.development)

```bash
# Server Configuration
PORT=3000
NODE_ENV=development
LOG_LEVEL=debug

# Database Configuration - Neon Local
DATABASE_URL=postgresql://neondb_owner:npg_WcH25DkTdMhE@neon-local:5432/neondb

# Neon Local Configuration
NEON_API_KEY=your_neon_api_key_here
NEON_PROJECT_ID=your_neon_project_id_here
# BRANCH_ID=your_branch_id_here  # Optional: connect to specific branch

# JWT Secret for development
JWT_SECRET=dev-jwt-secret-change-in-production

# Arcjet (Optional)
ARCJET_KEY=your_arcjet_key_here
```

### Production (.env.production)

```bash
# Server Configuration
PORT=3000
NODE_ENV=production
LOG_LEVEL=info

# Database Configuration - Neon Cloud
DATABASE_URL=your_neon_cloud_connection_string_here

# JWT Secret - CHANGE THIS IN PRODUCTION
JWT_SECRET=your-super-secure-jwt-secret-here

# Arcjet (Optional)
ARCJET_KEY=your_arcjet_key_here
```

## Architecture

### Development Architecture
```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Developer     │    │   Docker Host    │    │   Neon Cloud    │
│                 │    │                  │    │                 │
│ http://localhost│───▶│  App Container   │    │                 │
│     :3000       │    │  ┌─────────────┐ │    │                 │
│                 │    │  │ Node.js App │ │    │                 │
│                 │    │  └─────────────┘ │    │                 │
│                 │    │         │        │    │                 │
│                 │    │         ▼        │    │                 │
│                 │    │ ┌─────────────┐  │    │                 │
│                 │    │ │ Neon Local  │◀─┼────┼─ Ephemeral     │
│                 │    │ │   Proxy     │  │    │   Branch        │
│                 │    │ └─────────────┘  │    │                 │
│                 │    │   localhost:5432 │    │                 │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

### Production Architecture
```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Client        │    │   Docker Host    │    │   Neon Cloud    │
│                 │    │                  │    │                 │
│ https://yourapp │───▶│  App Container   │    │                 │
│     .com        │    │  ┌─────────────┐ │    │                 │
│                 │    │  │ Node.js App │◀┼────┼─ Production     │
│                 │    │  └─────────────┘ │    │   Database      │
│                 │    │                  │    │                 │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

## How It Works

### Development with Neon Local

1. **Neon Local Proxy**: A container that acts as a local Postgres interface to your Neon cloud database
2. **Ephemeral Branches**: By default, creates a new database branch when container starts and deletes it when stopped
3. **Branch Persistence**: Optionally connect to specific branches using `BRANCH_ID`
4. **Local Connection**: Your app connects to `neon-local:5432` instead of cloud URL

### Production with Neon Cloud

1. **Direct Connection**: App connects directly to Neon cloud database
2. **Production Optimizations**: Uses production Docker image with optimized settings
3. **Resource Limits**: Container has memory and CPU limits set
4. **Health Checks**: Built-in health monitoring

## Available Commands

### Development Commands

```bash
# Start development environment
npm run dev:docker

# View development logs
docker compose -f docker-compose.dev.yml logs -f

# Stop development environment
docker compose -f docker-compose.dev.yml down

# Run migrations in development
docker compose -f docker-compose.dev.yml exec app npm run db:migrate

# Access development database
docker compose -f docker-compose.dev.yml exec neon-local psql -U neondb_owner -d neondb

# Access app container shell
docker compose -f docker-compose.dev.yml exec app sh
```

### Production Commands

```bash
# Start production environment
npm run prod:docker

# View production logs
docker compose -f docker-compose.prod.yml logs -f

# Stop production environment
docker compose -f docker-compose.prod.yml down

# Run migrations in production
docker compose -f docker-compose.prod.yml exec app npm run db:migrate

# Access app container shell
docker compose -f docker-compose.prod.yml exec app sh
```

### Database Management

```bash
# Generate new migration from schema changes
npm run db:generate

# Apply pending migrations
npm run db:migrate

# Open Drizzle Studio (database GUI)
npm run db:studio
```

## Troubleshooting

### Common Issues

1. **"NEON_API_KEY not set" error**
   - Ensure you've added your Neon API key to `.env.development`
   - Get your API key from: https://console.neon.tech/app/settings/api-keys

2. **"Cannot connect to database" error**
   - For development: Check if Neon Local container is healthy
   - For production: Verify your Neon Cloud connection string

3. **"Port already in use" error**
   - Stop any running containers: `docker compose down`
   - Check for other services using port 3000 or 5432

4. **Migration failures**
   - Ensure database is accessible before running migrations
   - Check database credentials and connection string

### Debugging

```bash
# Check container status
docker compose -f docker-compose.dev.yml ps

# View container logs
docker compose -f docker-compose.dev.yml logs neon-local
docker compose -f docker-compose.dev.yml logs app

# Test database connection
docker compose -f docker-compose.dev.yml exec neon-local pg_isready -h localhost -p 5432

# Connect to database manually
docker compose -f docker-compose.dev.yml exec neon-local psql -U neondb_owner -d neondb
```

## Security Considerations

### Development
- Uses development JWT secret (not for production)
- Neon Local proxy provides isolated branch environment
- Debug logging enabled for troubleshooting

### Production
- Strong JWT secrets required
- Production logging levels
- Resource limits and health checks
- Direct encrypted connection to Neon Cloud

## Performance Notes

### Development
- Hot reload enabled for faster development
- Debug logging may impact performance
- Ephemeral branches are created/destroyed as needed

### Production
- Optimized Node.js production build
- Memory and CPU limits prevent resource exhaustion
- Connection pooling via Neon's built-in pooler

## Next Steps

1. **Environment Variables**: Update `.env.development` and `.env.production` with your actual values
2. **Database Schema**: Run `npm run db:generate` to create your initial database schema
3. **Testing**: Implement tests and add test scripts to package.json
4. **CI/CD**: Set up automated deployment pipelines using the production Docker setup
5. **Monitoring**: Add application monitoring and logging services

## Learn More

- [Neon Local Documentation](https://neon.com/docs/local/neon-local)
- [Neon Branching Guide](https://neon.com/docs/get-started-with-neon/create-a-branch)
- [Drizzle ORM Documentation](https://orm.drizzle.team)
- [Docker Compose Documentation](https://docs.docker.com/compose/)