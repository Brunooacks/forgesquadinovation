---
name: "Security Best Practices"
---

# Security Best Practices

## OWASP Top 10 Awareness

Every engineer should be familiar with the OWASP Top 10. The most critical risks to address:

1. **Broken Access Control** -- Enforce authorization on every endpoint and resource.
2. **Injection** -- Use parameterized queries; never concatenate user input into SQL, LDAP, or OS commands.
3. **Cryptographic Failures** -- Encrypt data at rest and in transit. Use strong algorithms (AES-256, TLS 1.2+).
4. **Security Misconfiguration** -- Harden defaults, disable unused features, remove debug endpoints.
5. **SSRF** -- Validate and allowlist outbound URLs.

Review the full list annually and incorporate into threat modeling sessions.

## Input Validation and Sanitization

- Validate **all** input on the server side, regardless of client-side validation.
- Use allowlists over denylists whenever possible.
- Validate data type, length, range, and format.
- Sanitize output to prevent XSS: encode HTML, JavaScript, and URL contexts.
- Reject unexpected fields in API payloads (strict schema validation).

## Authentication & Authorization

- Use **OAuth 2.0 / OpenID Connect** for authentication.
- Enforce **MFA** for privileged accounts and admin interfaces.
- Apply the **principle of least privilege** -- grant minimum required permissions.
- Use short-lived tokens (access tokens: 15-60 min; refresh tokens: hours to days).
- Implement account lockout after 5 failed login attempts.
- Log all authentication events (success and failure).

## Secrets Management

- **Never** commit secrets to source control.
- Use a secrets manager (e.g., HashiCorp Vault, AWS Secrets Manager, Azure Key Vault).
- Rotate secrets on a defined schedule (at least every 90 days).
- Inject secrets at runtime via environment variables or mounted volumes.
- Scan repositories for leaked secrets in CI (e.g., gitleaks, trufflehog).

## SAST / DAST Integration

| Tool Type | When                  | Purpose                                |
|-----------|-----------------------|----------------------------------------|
| SAST      | Every PR (CI)         | Find vulnerabilities in source code    |
| DAST      | Nightly / Pre-release | Find vulnerabilities in running app    |
| SCA       | Every PR (CI)         | Detect vulnerable dependencies         |

- Block merges on critical or high severity SAST findings.
- Triage DAST results within 48 hours.
- Maintain a suppression list for accepted risks with justification.

## Dependency Scanning

- Run dependency vulnerability scans on every build.
- Enable automatic dependency update PRs (e.g., Dependabot, Renovate).
- Review and merge dependency updates within **one week**.
- Pin dependency versions in production; use ranges only in libraries.
- Maintain a Software Bill of Materials (SBOM) for each service.

## Additional Guidelines

- Enable security headers: `Content-Security-Policy`, `Strict-Transport-Security`, `X-Content-Type-Options`.
- Implement rate limiting on authentication endpoints.
- Conduct threat modeling for every new feature involving sensitive data.
- Schedule penetration tests at least once per year.
