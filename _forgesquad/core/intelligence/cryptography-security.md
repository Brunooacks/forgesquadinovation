---
name: Cryptography & Security Intelligence
type: embedded-intelligence
injected_into: [architect, dev_backend, qa_engineer]
auto_inject: true
description: "Encryption, key management, zero trust, compliance — injected automatically into security-sensitive agents"
---

# Cryptography & Security Intelligence

## Encryption Standards

- **AES-256-GCM** — default for symmetric encryption. Provides confidentiality + integrity (authenticated encryption). Never use ECB mode.
- **Envelope Encryption** — encrypt data with a DEK (Data Encryption Key), encrypt DEK with a KEK (Key Encryption Key). Rotate KEK without re-encrypting all data.
- **Field-Level Encryption** — encrypt sensitive fields (PII, financial data) individually. Allows querying non-sensitive fields while protecting sensitive ones.
- **At Rest** — encrypt databases, backups, logs containing PII. Use cloud-native encryption (AWS KMS, GCP CMEK, Azure Key Vault).
- **In Transit** — TLS 1.3 everywhere. No exceptions.
- **RSA-OAEP / ECIES** — asymmetric encryption for key exchange and small payloads only. Never encrypt bulk data with asymmetric.

## Transport Security

- **TLS 1.3** — mandatory for all external and internal communication. Disable TLS 1.0/1.1 entirely.
- **mTLS** — mutual TLS for service-to-service. Both sides present certificates. Use with service mesh (Istio, Linkerd) or cert manager.
- **Certificate Management** — automate rotation (cert-manager, ACME/Let's Encrypt). Alert 30 days before expiry. Pin certificates for mobile apps (but plan for rotation).
- **HSTS** — enable with long max-age. Include subdomains. Preload.

## Password & Credential Hashing

- **Argon2id** — preferred. Memory-hard, resistant to GPU/ASIC attacks. Tune: 64MB memory, 3 iterations, 1 parallelism minimum.
- **bcrypt** — acceptable alternative. Cost factor 12+. Max 72 bytes input.
- **NEVER** — MD5, SHA1, SHA256 for passwords. No plain hashing. No custom schemes.
- **Pepper** — application-level secret added before hashing. Store separately from hashes.
- **Credential Stuffing Defense** — rate limit, CAPTCHA after failures, breached password check (HaveIBeenPwned API).

## Key Management

- **Rotation** — rotate encryption keys on schedule (90 days recommended). Automate. Support key versioning for decryption of old data.
- **KMS** — use cloud KMS (AWS KMS, GCP KMS, Azure Key Vault) for key generation and storage. Never generate keys in application code.
- **HSM** — Hardware Security Modules for highest security (financial, government). FIPS 140-2 Level 3+.
- **Key Hierarchy** — Master Key (HSM/KMS) > Key Encryption Key > Data Encryption Key. Principle of least privilege at each level.

## Secrets Management

- **Vault Pattern** — centralized secrets store (HashiCorp Vault, AWS Secrets Manager, GCP Secret Manager). Dynamic secrets preferred.
- **NEVER hardcode** — no secrets in code, config files, environment variables in repos, or Docker images. Scan with tools (gitleaks, trufflehog).
- **Dynamic Secrets** — short-lived, generated on demand (DB credentials, cloud tokens). Revoke on lease expiry.
- **Injection** — inject secrets at runtime via sidecar, init container, or SDK. Never bake into artifacts.

## Authentication Tokens

- **JWT** — use RS256 (RSA) or ES256 (ECDSA) for signing. NEVER HS256 with shared secrets in distributed systems.
- **Short-Lived** — access tokens: 15 minutes max. Refresh tokens: hours/days with rotation.
- **Storage** — HttpOnly + Secure + SameSite=Strict cookies for web. Never localStorage for auth tokens (XSS vulnerable).
- **Claims** — minimal payload. No sensitive data in JWT (it's base64, not encrypted). Include: sub, exp, iat, iss, aud, scope.
- **Revocation** — maintain denylist for compromised tokens or use short expiry + refresh rotation.

## API Security

- **OAuth 2.0 + PKCE** — mandatory for public clients (SPAs, mobile). Authorization Code flow with PKCE. Never Implicit flow.
- **Rate Limiting** — per-user, per-IP, per-endpoint. Use token bucket or sliding window. Return 429 with Retry-After header.
- **Input Validation** — validate all inputs at API boundary. Whitelist, not blacklist. Use schema validation (JSON Schema, Zod, Joi).
- **API Gateway** — centralize auth, rate limiting, request transformation, logging. Don't re-implement in each service.
- **CORS** — restrictive origins. Never `Access-Control-Allow-Origin: *` with credentials.

## Data Protection & Compliance

- **LGPD / GDPR** — data minimization, purpose limitation, consent management, right to deletion, data portability, breach notification (72h).
- **Tokenization** — replace sensitive data with non-reversible tokens. Use for PCI DSS (card numbers), PII storage. Tokenization service separate from application.
- **Data Masking** — mask PII in logs, lower environments, analytics. Show only last 4 digits of CPF/SSN, mask email user.
- **Audit Trail** — log all access to sensitive data. Who, what, when, from where. Immutable logs. Retain per regulation.
- **Data Classification** — Public, Internal, Confidential, Restricted. Apply controls by classification level.

## Zero Trust Architecture

- **Verify Always** — never trust network location. Authenticate and authorize every request, even internal.
- **Least Privilege** — minimum permissions needed. Time-bound access. Regular access reviews.
- **Microsegmentation** — network policies per service. Default deny. Allow only explicit paths.
- **Assume Breach** — design systems assuming attackers are already inside. Limit blast radius. Encrypt internal traffic.
- **Device Trust** — verify device health and identity, not just user identity.

## Anti-Patterns: What NOT to Do

| Anti-Pattern | Why It's Dangerous | What to Do Instead |
|--------------|-------------------|-------------------|
| MD5/SHA1 for passwords | Crackable in seconds with rainbow tables | Argon2id or bcrypt |
| Secrets in env vars / code | Leaked via logs, process listing, repo history | Vault / Secrets Manager |
| JWT in localStorage | XSS can steal tokens | HttpOnly Secure cookies |
| HS256 JWT shared secret | Any service can forge tokens | RS256/ES256 asymmetric |
| TLS 1.0/1.1 | Known vulnerabilities (POODLE, BEAST) | TLS 1.3 only |
| `SELECT *` with PII | Over-fetching sensitive data | Select only needed fields, mask PII |
| Logging PII | Compliance violation, breach amplification | Mask/redact before logging |
| Rolling your own crypto | Guaranteed vulnerabilities | Use vetted libraries (libsodium, BoringSSL) |
| Long-lived API keys | No rotation = permanent breach if leaked | Short-lived tokens, automatic rotation |
| Permissive CORS | Cross-site attacks | Explicit allow-list of origins |
