# Coding Standards — TokenOps Platform

## TypeScript

- Strict mode enabled (`"strict": true` in tsconfig)
- No usage of `any` — use `unknown` or proper types
- Interfaces for all DTOs and API contracts
- Enums for constants and status codes
- Utility types (`Partial`, `Pick`, `Omit`) over manual redefinition
- Explicit return types on public methods
- Readonly properties where mutation is not needed

## NestJS (Backend)

- Modular architecture: one module per bounded context
- Controllers are thin — delegate to services immediately
- Services contain all business logic
- Repositories handle data access (TypeORM for PostgreSQL, custom for ClickHouse)
- Use decorators for validation (`class-validator`, `class-transformer`)
- DTOs for all request/response payloads — never expose entities directly
- Dependency injection for all cross-module communication
- Guards for authentication, Interceptors for logging/transformation
- Pipes for input validation and transformation

## Next.js (Frontend)

- App Router (`/app` directory) — no Pages Router
- Server Components by default for data fetching and static content
- Client Components explicit with `"use client"` directive only when needed (interactivity, hooks, browser APIs)
- Dynamic imports (`next/dynamic`) for heavy components (charts, editors, code blocks)
- Route groups for layout organization
- Loading and error states via `loading.tsx` and `error.tsx` conventions
- Metadata API for SEO on public pages

## React

- Functional components only — no class components
- Custom hooks for reusable logic (`useTokenUsage`, `useEstimation`, `useOrganization`)
- React Query (TanStack Query) for all server state and data fetching
- No prop drilling — use React Context or composition patterns
- Memoization (`useMemo`, `useCallback`) only when profiling shows need
- Component composition over inheritance
- Co-locate components with their styles, tests, and hooks

## Tailwind CSS

- Utility-first approach — avoid custom CSS unless absolutely necessary
- Custom theme tokens in `tailwind.config.ts` for brand colors, spacing, typography
- Dark mode support via `dark:` variant (class strategy)
- Responsive design with mobile-first breakpoints (`sm`, `md`, `lg`, `xl`)
- Component extraction via Tailwind `@apply` only for highly reused patterns
- Design tokens: `--color-primary`, `--color-secondary`, `--color-accent`, `--color-danger`

## Naming Conventions

| Element | Convention | Example |
|---------|-----------|---------|
| Variables, functions | camelCase | `tokenCount`, `calculateCost()` |
| Classes, components, types, interfaces | PascalCase | `TokenEstimator`, `UsageDTO` |
| Constants | UPPER_SNAKE_CASE | `MAX_TOKENS_PER_REQUEST`, `DEFAULT_MODEL` |
| Files and directories | kebab-case | `token-estimator.service.ts`, `usage-dto.ts` |
| Database tables | snake_case | `token_usage_logs`, `api_keys` |
| Environment variables | UPPER_SNAKE_CASE | `DATABASE_URL`, `CLICKHOUSE_HOST` |
| API endpoints | kebab-case | `/api/v1/token-usage`, `/api/v1/cost-estimation` |

## Git Workflow

- Conventional commits: `feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`, `perf:`
- Feature branches from `main`: `feat/TOK-123-add-cost-estimation`
- Squash merge to `main` — clean linear history
- PR title matches conventional commit format
- Branch protection: require review, require CI pass, no force push to `main`
- Commit messages reference ticket: `feat(estimator): add GPT-4o cost model (TOK-123)`

## Error Handling

### Backend (NestJS)
- Custom exception filters extending `ExceptionFilter`
- Domain-specific exceptions: `TokenEstimationException`, `ProviderUnavailableException`, `RateLimitExceededException`
- Structured error responses: `{ statusCode, message, error, timestamp, path }`
- Log all errors with correlation ID (OpenTelemetry trace ID)
- Never expose internal stack traces in production responses

### Frontend (React/Next.js)
- Error boundaries at route and feature level
- Fallback UI for error states — never blank screens
- Toast notifications for transient errors (network, rate limit)
- Retry logic with exponential backoff for API calls (via React Query)
- Form validation errors displayed inline next to fields
