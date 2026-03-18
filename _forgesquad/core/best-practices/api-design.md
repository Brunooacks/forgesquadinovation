---
name: "API Design Best Practices"
---

# API Design Best Practices

## REST Naming Conventions

- Use **nouns** for resources: `/users`, `/orders`, `/products`.
- Use plural names consistently.
- Nest sub-resources to express relationships: `/users/{id}/orders`.
- Use kebab-case for multi-word resources: `/order-items`.
- Avoid verbs in URLs; let HTTP methods convey the action.

## HTTP Methods

| Method | Purpose              | Idempotent |
|--------|----------------------|------------|
| GET    | Retrieve resource(s) | Yes        |
| POST   | Create a resource    | No         |
| PUT    | Full update          | Yes        |
| PATCH  | Partial update       | No         |
| DELETE | Remove a resource    | Yes        |

## Status Codes

- **200** OK, **201** Created, **204** No Content.
- **400** Bad Request, **401** Unauthorized, **403** Forbidden, **404** Not Found, **409** Conflict.
- **422** Unprocessable Entity for validation errors.
- **500** Internal Server Error (never expose stack traces).

## Versioning Strategy

- Prefer **URL-based versioning** (`/v1/users`) for simplicity.
- Use header-based versioning (`Accept: application/vnd.api+json;version=2`) only when URL versioning is impractical.
- Support at most two active versions concurrently; deprecate with a sunset header.

## Pagination, Filtering & Sorting

- Use **cursor-based pagination** for large datasets: `?cursor=abc&limit=25`.
- Offset pagination is acceptable for small datasets: `?page=1&size=20`.
- Filtering: `?status=active&created_after=2025-01-01`.
- Sorting: `?sort=created_at:desc,name:asc`.
- Always return pagination metadata (`total`, `next_cursor`, `has_more`).

## Error Response Format (RFC 7807)

```json
{
  "type": "https://api.example.com/errors/validation",
  "title": "Validation Error",
  "status": 422,
  "detail": "Field 'email' must be a valid email address.",
  "instance": "/users/signup"
}
```

## OpenAPI Spec-First Approach

- Write the OpenAPI 3.x spec **before** writing code.
- Generate server stubs and client SDKs from the spec.
- Validate requests and responses against the spec in CI.
- Host interactive docs via Swagger UI or Redoc.

## Authentication & Authorization

- Use **OAuth 2.0 / OIDC** for user-facing APIs.
- Use **API keys** only for server-to-server calls; rotate regularly.
- Pass tokens in the `Authorization: Bearer <token>` header.
- Enforce least-privilege scopes per endpoint.

## Rate Limiting

- Apply rate limits per client/API key.
- Return `429 Too Many Requests` with `Retry-After` header.
- Use sliding window or token bucket algorithms.
- Communicate limits via headers: `X-RateLimit-Limit`, `X-RateLimit-Remaining`, `X-RateLimit-Reset`.
