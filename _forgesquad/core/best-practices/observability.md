---
name: "Observability & Monitoring"
---

# Observability & Monitoring

## Three Pillars

| Pillar  | Purpose                               | Tools (examples)               |
|---------|---------------------------------------|--------------------------------|
| Logs    | Record discrete events                | ELK, Loki, CloudWatch Logs    |
| Metrics | Measure system behavior over time     | Prometheus, Datadog, CloudWatch|
| Traces  | Track requests across services        | Jaeger, Zipkin, OpenTelemetry  |

All three pillars must be implemented for production services. Use **OpenTelemetry** as the standard instrumentation framework to unify collection.

## Structured Logging Standards

- Log in **JSON format** with consistent field names.
- Required fields per log entry:

```json
{
  "timestamp": "2025-06-15T10:30:00Z",
  "level": "INFO",
  "service": "order-service",
  "traceId": "abc123",
  "spanId": "def456",
  "message": "Order created successfully",
  "orderId": "ORD-789",
  "userId": "USR-012"
}
```

- Use log levels consistently: `DEBUG` for development, `INFO` for normal operations, `WARN` for recoverable issues, `ERROR` for failures requiring attention.
- **Never** log sensitive data (passwords, tokens, PII). Mask or redact when necessary.
- Include correlation IDs (traceId) in every log entry for cross-service tracing.

## Alert Thresholds and SLIs/SLOs

### Service Level Indicators (SLIs)

| SLI                | Measurement                               |
|--------------------|-------------------------------------------|
| Availability       | % of successful requests (non-5xx)        |
| Latency            | p50, p95, p99 response time               |
| Error Rate         | % of requests returning errors            |
| Throughput         | Requests per second                       |

### Service Level Objectives (SLOs)

| SLO                | Target          | Window   |
|--------------------|-----------------|----------|
| Availability       | 99.9%           | 30 days  |
| Latency (p95)      | < 300 ms        | 30 days  |
| Error Rate         | < 0.1%          | 30 days  |

### Alerting Rules

- Alert on **SLO burn rate**, not on individual threshold breaches.
- Use multi-window alerting (fast burn = page, slow burn = ticket).
- Every alert must have a linked runbook.
- Review and tune alerts quarterly to reduce noise.

## Health Check Endpoints

Every service must expose:

- `GET /health` -- Returns `200 OK` if the service is running.
- `GET /health/ready` -- Returns `200 OK` only when the service can handle traffic (DB connected, dependencies reachable).

Health checks must:
- Respond within 2 seconds.
- Not trigger side effects or heavy computations.
- Be used by load balancers and orchestrators for routing decisions.

## Dashboard Guidelines

- Create a **service dashboard** for each production service with:
  - Request rate, error rate, latency (RED metrics).
  - Resource utilization (CPU, memory, disk, connections).
  - Dependency health status.
- Create a **team dashboard** summarizing SLO compliance across all services.
- Use consistent naming: `[team]-[service]-overview`.
- Dashboards must be version-controlled (Grafana as code, Terraform).
- Review dashboards monthly to remove stale panels and add missing signals.
