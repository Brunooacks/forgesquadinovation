---
name: "Cryptography & Security"
description: "Encryption, key management, digital signatures, secrets management, zero trust patterns"
type: prompt
version: "1.0.0"
category: security
agents: [architect, dev-backend, qa-engineer, tech-lead]
---

# Cryptography & Security — Data Protection Skill

Provides cryptographic security knowledge for building systems that protect data at rest, in transit, and in use. Covers encryption, key management, secrets handling, digital signatures, and compliance patterns.

## When to Use Cryptography

- **Data protection**: Encrypting sensitive data at rest and in transit
- **Authentication**: Implementing secure auth flows (OAuth, JWT, mTLS)
- **Key management**: Designing key rotation and storage strategies
- **Compliance**: Meeting LGPD, GDPR, PCI-DSS, SOX requirements
- **Integrity**: Ensuring data hasn't been tampered with

## Encryption at Rest

### AES-256-GCM (Recommended)
- **Algorithm**: AES-256 in GCM mode (authenticated encryption)
- **Properties**: Provides confidentiality + integrity + authentication
- **IV**: 96-bit random IV per encryption operation (NEVER reuse)
- **Output**: Ciphertext + 128-bit authentication tag

### Envelope Encryption
```
┌─────────────────────────────────────────────────┐
│  KMS (AWS KMS / Azure Key Vault / HashiCorp)    │
│  Master Key (never leaves KMS)                  │
│  └── Encrypts/decrypts Data Encryption Keys     │
└─────────────────────┬───────────────────────────┘
                      │
         ┌────────────┴────────────┐
         │   Data Encryption Key   │
         │   (DEK) — generated     │
         │   per record/file       │
         └────────────┬────────────┘
                      │
              ┌───────┴────────┐
              │  Encrypted     │
              │  Data          │
              └────────────────┘
```
- Generate unique DEK per record/file
- Encrypt data with DEK (AES-256-GCM)
- Encrypt DEK with master key (KMS)
- Store encrypted DEK alongside encrypted data
- **Benefit**: Rotate master key without re-encrypting all data

### Field-Level Encryption
- Encrypt individual sensitive fields (SSN, credit card, PII)
- Different keys per field type
- Allows querying non-encrypted fields while protecting sensitive ones
- Required for PCI-DSS (cardholder data) and LGPD (personal data)

## Encryption in Transit

### TLS 1.3 Configuration
- **Minimum version**: TLS 1.3 (disable TLS 1.0, 1.1, 1.2 where possible)
- **Cipher suites**: TLS_AES_256_GCM_SHA384, TLS_CHACHA20_POLY1305_SHA256
- **Certificate**: RSA 2048+ or ECDSA P-256 (preferred — smaller, faster)
- **HSTS**: Enable with `max-age=31536000; includeSubDomains; preload`

### mTLS (Mutual TLS)
- Service-to-service authentication via client certificates
- Both sides verify each other's identity
- Use with service mesh (Istio, Linkerd) for automatic mTLS
- Certificate rotation: automated via cert-manager (90-day max lifetime)

### Certificate Management
```yaml
# cert-manager example
apiVersion: cert-manager.io/v1
kind: Certificate
spec:
  secretName: app-tls
  issuerRef:
    name: letsencrypt-prod
    kind: ClusterIssuer
  dnsNames:
    - api.example.com
  renewBefore: 720h  # 30 days before expiry
```

## Hashing & Integrity

### Password Hashing
| Algorithm | Use | Configuration |
|-----------|-----|--------------|
| **Argon2id** | Passwords (recommended) | m=65536, t=3, p=4 |
| **bcrypt** | Passwords (widely supported) | cost=12 |
| **scrypt** | Passwords (memory-hard) | N=2^15, r=8, p=1 |

**Rules**:
- NEVER use MD5, SHA-1, or SHA-256 alone for passwords
- ALWAYS use a unique random salt per password
- Store: `algorithm$parameters$salt$hash`

### Data Integrity
- **SHA-256**: File/artifact integrity verification
- **SHA-3 (SHA3-256)**: Newer standard, use when SHA-2 family isn't required
- **HMAC-SHA256**: Message authentication (verify sender AND integrity)

### Integrity Verification Pattern
```
1. Compute hash of artifact: SHA-256(content) → hash
2. Sign hash with private key: Sign(hash, private_key) → signature
3. Distribute: content + signature + public_key
4. Verify: SHA-256(content) == Verify(signature, public_key)
```

## Key Management

### Key Lifecycle
```
Generate → Distribute → Store → Use → Rotate → Retire → Destroy
```

### Key Rotation Policy
| Key Type | Rotation Period | Strategy |
|----------|----------------|----------|
| Master keys (KMS) | Annual | KMS handles automatically |
| Data encryption keys | Per-record or quarterly | Re-encrypt with new DEK |
| API keys | 90 days | Issue new, deprecate old with grace period |
| TLS certificates | 90 days | Auto-renew via cert-manager |
| JWT signing keys | 90 days | Publish new key, keep old for validation window |

### Key Derivation (HKDF)
- Derive multiple keys from a single master secret
- Use for: session keys, per-purpose keys from master
- HKDF-SHA256 with unique info/context per derived key

### HSM Integration
- Hardware Security Modules for highest-security key storage
- Keys never leave the HSM boundary
- Use for: root CAs, master encryption keys, code signing
- Cloud HSMs: AWS CloudHSM, Azure Dedicated HSM

## Secrets Management

### Architecture
```
┌──────────────────────────────────────┐
│          Vault / Secret Manager       │
│  ┌─────────┐  ┌─────────┐           │
│  │  Static  │  │ Dynamic │           │
│  │ Secrets  │  │ Secrets │           │
│  └─────────┘  └─────────┘           │
│       │              │               │
│  API keys,      DB credentials,      │
│  tokens,        cloud creds          │
│  passwords      (short-lived)        │
└──────────────────┬───────────────────┘
                   │
        ┌──────────┴──────────┐
        │   Application       │
        │   (pulls at startup │
        │    or via sidecar)  │
        └─────────────────────┘
```

### Secret Injection Patterns
1. **Environment variables**: Simple but visible in process listings. Use for non-critical config.
2. **Mounted volumes**: Vault Agent / CSI Driver mounts secrets as files. Auto-rotated.
3. **API call at startup**: Application fetches from Vault/SM on init. Caches in memory.
4. **Sidecar proxy**: Vault Agent Injector handles lifecycle transparently.

### Anti-Patterns (NEVER do)
- Hardcode secrets in source code
- Commit secrets to git (even private repos)
- Store secrets in environment variables in CI/CD logs
- Share secrets via Slack/email
- Use the same secret across environments

## Digital Signatures

### JWT Best Practices
- **Algorithm**: RS256 (RSA) or ES256 (ECDSA, preferred — smaller tokens)
- **Expiration**: Access tokens: 15 minutes. Refresh tokens: 7 days.
- **Claims**: Minimal — id, roles, expiry. NO sensitive data in payload.
- **Storage**: HttpOnly + Secure + SameSite=Strict cookies (NOT localStorage)
- **Rotation**: Publish new signing key, keep old for validation grace period (JWKS rotation)

### Code Signing
- Sign all release artifacts (Docker images, binaries, packages)
- Verify signatures before deployment
- Use: cosign (containers), GPG (packages), sigstore (SLSA)
- Chain of trust: signing key → trusted keyserver/registry

### Audit Trail Integrity
ForgeSquad already uses SHA-256 chaining for audit trail entries:
```
entry.hash = SHA-256(entry.data + previous_entry.hash)
```
This creates a tamper-evident chain — any modification breaks the chain.

## API Security

### OAuth 2.0 + PKCE
- Always use PKCE for public clients (SPAs, mobile apps)
- Authorization Code flow (NOT implicit flow — deprecated)
- Token endpoint: mTLS or private_key_jwt for confidential clients
- Scopes: minimum necessary (principle of least privilege)

### API Key Security
- Hash API keys before storage (SHA-256 + salt)
- Show full key only once at creation (like GitHub tokens)
- Scope keys to specific endpoints/operations
- Rate limit per key
- Include key prefix for identification without exposing the hash

### Rate Limiting
```
Tiers:
  - Anonymous: 60 req/min
  - Authenticated: 600 req/min
  - Premium: 6000 req/min

Strategy: Token bucket or sliding window
Headers: X-RateLimit-Limit, X-RateLimit-Remaining, X-RateLimit-Reset
Response: 429 Too Many Requests with Retry-After header
```

## Data Protection & Compliance

### LGPD / GDPR Compliance Patterns
- **Data minimization**: Collect only what's necessary
- **Purpose limitation**: Use data only for stated purpose
- **Consent management**: Record when/what/how consent was given
- **Right to erasure**: Implement hard delete (not just soft delete) for PII
- **Data portability**: Export user data in machine-readable format
- **Breach notification**: Automated detection + 72-hour notification workflow

### PCI-DSS Patterns
- Cardholder data encrypted at rest (AES-256)
- Network segmentation (cardholder data environment isolated)
- Access logging with tamper-evident audit trail
- Key management procedures documented and followed
- Regular vulnerability scans and penetration tests

### Tokenization
- Replace sensitive data with non-sensitive tokens
- Mapping stored in separate, secured token vault
- Tokens are meaningless outside the system
- Use for: credit card numbers, SSNs, account numbers

### Data Masking
```
Full:     4111-1111-1111-1234  →  ****-****-****-1234
Email:    user@example.com     →  u***@example.com
Phone:    +55 11 98765-4321   →  +55 11 9****-4321
```

## Zero Trust Architecture

### Principles
1. **Never trust, always verify**: Every request is authenticated and authorized
2. **Least privilege access**: Minimum permissions for minimum time
3. **Assume breach**: Design as if the network is already compromised

### Implementation
- **Identity**: Strong authentication (MFA) for all users and services
- **Device**: Verify device health before granting access
- **Network**: Microsegmentation, no implicit trust zones
- **Application**: Per-request authorization, API gateway enforcement
- **Data**: Classify, encrypt, monitor access patterns

### Service Mesh Encryption
- Istio/Linkerd: Automatic mTLS between all services
- No plaintext communication within the mesh
- Certificate rotation handled by the mesh control plane

## Crypto Anti-Patterns (NEVER do)

| Anti-Pattern | Risk | Correct Approach |
|-------------|------|-----------------|
| MD5 or SHA-1 for security | Broken, collision attacks exist | SHA-256+ or SHA-3 |
| ECB mode for block ciphers | Pattern preservation, data leakage | GCM or CTR mode |
| Hardcoded encryption keys | Key compromise = all data compromised | KMS + envelope encryption |
| Homegrown crypto algorithms | Almost certainly broken | Use vetted libraries (libsodium, OpenSSL) |
| Predictable IVs/nonces | Enables known-plaintext attacks | Cryptographic random generation |
| Encrypting without authenticating | Vulnerable to bit-flipping | Use authenticated encryption (GCM, ChaCha20-Poly1305) |
| Same key for encrypt + sign | Weakens both operations | Separate keys per purpose |
| Storing passwords with reversible encryption | One breach exposes all | One-way hash (Argon2id, bcrypt) |

## Limitations

- Cryptography is complex — prefer well-tested libraries over custom implementations
- Key management is often the weakest link, not the algorithm
- Compliance requirements vary by jurisdiction — consult legal for specific regulations
- Performance impact of encryption should be benchmarked for high-throughput systems
