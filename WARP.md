# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Development Commands

### Essential Commands

```bash
# Start development server with auto-reload
npm run dev

# Linting and formatting
npm run lint          # Check code style issues
npm run lint:fix       # Auto-fix linting issues
npm run format         # Format code with Prettier
npm run format:check   # Check if code is formatted

# Database operations
npm run db:generate    # Generate Drizzle migrations from schema changes
npm run db:migrate     # Run pending migrations
npm run db:studio      # Open Drizzle Studio for database inspection
```

### Running Single Tests

This project doesn't have a test framework configured yet. When implementing tests, add test scripts to package.json.

## Architecture Overview

### Technology Stack

- **Runtime**: Node.js with ES modules
- **Framework**: Express.js 5.x
- **Database**: PostgreSQL with Drizzle ORM
- **Database Provider**: Neon (serverless PostgreSQL)
- **Authentication**: JWT with bcrypt password hashing
- **Logging**: Winston with file and console transports
- **Validation**: Zod schemas
- **Code Quality**: ESLint + Prettier

### Project Structure

```
src/
├── config/          # Configuration modules (database, logger)
├── controllers/     # Request handlers and business logic
├── middleware/      # Custom Express middleware
├── models/          # Drizzle database schemas
├── routes/          # Express route definitions
├── services/        # Business logic and external integrations
├── utils/           # Utility functions (JWT, cookies, formatting)
├── validations/     # Zod validation schemas
├── app.js          # Express app configuration
├── server.js       # Server startup
└── index.js        # Entry point
```

### Key Architectural Patterns

**Import Path Mapping**: The project uses Node.js subpath imports for clean imports:

- `#src/*` → `./src/*`
- `#config/*` → `./src/config/*`
- `#controllers/*` → `./src/controllers/*`
- And so on for all major directories

**Layered Architecture**:

- **Routes** → **Controllers** → **Services** → **Database Models**
- Controllers handle HTTP concerns (validation, responses)
- Services contain business logic
- Models define database schemas using Drizzle ORM

**Authentication Flow**:

- JWT tokens stored in HTTP-only cookies
- Password hashing with bcrypt (12 rounds)
- User sessions managed through cookie-based tokens
- Authentication endpoints: `/api/auth/sign-up`, `/api/auth/sign-in`, `/api/auth/sign-out`

**Database Management**:

- Drizzle ORM with Neon PostgreSQL adapter
- Schema-first approach with migrations in `/drizzle`
- Database configuration in `src/config/database.js`

**Error Handling & Logging**:

- Centralized Winston logging with file rotation
- Structured error responses with validation details
- Environment-aware logging (console in dev, files in production)

## Database Schema

Current tables:

- **users**: Core user authentication with roles (user/admin)

## Environment Configuration

Required environment variables:

```bash
PORT=3000
NODE_ENV=development
LOG_LEVEL=info
DATABASE_URL=your_neon_database_url
JWT_SECRET=your_jwt_secret_key
```

## Security Considerations

- JWT secrets should be strong and unique per environment
- Passwords are hashed with bcrypt (12 rounds)
- HTTP-only cookies prevent XSS attacks
- CORS and Helmet middleware provide additional security
- Input validation using Zod schemas on all endpoints
