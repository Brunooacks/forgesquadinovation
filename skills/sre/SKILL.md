---
name: "SRE Engineering"
description: "Site Reliability Engineering — monitoring, alerting, SLOs, incident response, capacity planning, chaos engineering"
type: prompt
version: "1.0.0"
category: operations
agents: [architect, dev-backend, qa-engineer, tech-lead]
---

# SRE Engineering — Site Reliability Skill

Provides Site Reliability Engineering knowledge and practices for building and operating reliable systems at scale.

## When to Use SRE

- **Service reliability design**: SLO/SLI/SLA definition, error budgets
- **Monitoring setup**: Observability strategy, dashboards, alerting
- **Incident management**: Runbooks, escalation, postmortems
- **Capacity planning**: Load forecasting, resource sizing, autoscaling
- **Chaos engineering**: Resilience testing, failure injection

## Monitoring & Observability

### Golden Signals (per Google SRE)
1. **Latency**: Time to serve a request (distinguish successful vs failed)
2. **Traffic**: Demand on the system (requests/sec, transactions/sec)
3. **Errors**: Rate of failed requests (HTTP 5xx, application exceptions)
4. **Saturation**: How "full" the system is (CPU, memory, disk, connections)

### Observability Pillars
- **Metrics**: Prometheus/CloudWatch/Datadog — aggregated numeric time series
- **Logs**: Structured JSON logs with correlation IDs, shipped to central store
- **Traces**: Distributed tracing (OpenTelemetry) for request flow across services

### Dashboard Design
- One dashboard per service (golden signals + business metrics)
- RED method for request-driven services: Rate, Errors, Duration
- USE method for resources: Utilization, Saturation, Errors
- Keep dashboards actionable — every panel should answer a specific question

## SLO/SLI/SLA Framework

### Definitions
- **SLI** (Service Level Indicator): Quantitative measure of service (e.g., p99 latency < 200ms)
- **SLO** (Service Level Objective): Target value for an SLI (e.g., 99.9% availability per month)
- **SLA** (Service Level Agreement): Contract with consequences for missing SLO

### Error Budget
```
Error Budget = 1 - SLO
Example: SLO 99.9% → Error Budget = 0.1% = 43.2 minutes/month downtime allowed
```

### Burn Rate Alerting
- **Fast burn**: 14.4x budget consumption → page immediately (will exhaust in 1 hour)
- **Slow burn**: 3x budget consumption → ticket (will exhaust in 10 hours)
- **Budget exhausted**: Freeze all non-reliability deployments

### SLO Template
```yaml
service: "{service_name}"
slos:
  - name: "Availability"
    sli: "Ratio of successful requests (non-5xx) to total requests"
    target: 99.9%
    window: 30 days
    measurement: "sum(rate(http_requests_total{status!~'5..'})) / sum(rate(http_requests_total))"

  - name: "Latency"
    sli: "Proportion of requests faster than threshold"
    target: 99% of requests < 200ms
    window: 30 days
    measurement: "histogram_quantile(0.99, rate(http_request_duration_seconds_bucket[5m]))"
```

## Incident Response

### Severity Classification
| Level | Impact | Response Time | Communication |
|-------|--------|--------------|---------------|
| SEV1 | Full outage, data loss risk | 15 min | Exec team, all-hands bridge |
| SEV2 | Major degradation | 30 min | Engineering leads, status page |
| SEV3 | Minor degradation | 2 hours | On-call team, internal chat |
| SEV4 | Cosmetic/low impact | Next business day | Ticket |

### Runbook Template
```markdown
# Runbook: {service_name} — {scenario}

## Detection
- Alert: {alert_name}
- Dashboard: {dashboard_link}
- Symptoms: {what_the_user_sees}

## Diagnosis
1. Check {metric/log/trace}
2. Verify {dependency/database/queue}
3. Look for {common_cause}

## Mitigation
1. Immediate: {rollback/restart/scale_up}
2. Verify recovery via {metric}
3. Communicate resolution

## Root Cause Analysis
- Follow up with postmortem if SEV1/SEV2
```

### Escalation Flow
```
On-call engineer (15 min) → Team lead (30 min) → Engineering manager (1 hour) → VP/CTO (2 hours)
```

## Postmortem Template

```markdown
# Postmortem: {incident_title}
Date: {date} | Duration: {duration} | Severity: {SEV}

## Summary
{1-2 sentence description of what happened}

## Impact
- Users affected: {count/percentage}
- Revenue impact: {estimated}
- Data impact: {none/partial/full}

## Timeline (UTC)
| Time | Event |
|------|-------|
| HH:MM | {first_alert_or_report} |
| HH:MM | {diagnosis_step} |
| HH:MM | {mitigation_applied} |
| HH:MM | {recovery_confirmed} |

## Root Cause
{Technical root cause — use 5 Whys}
1. Why? ...
2. Why? ...
3. Why? ...
4. Why? ...
5. Why? → {root cause}

## Action Items
| Action | Owner | Priority | Due Date |
|--------|-------|----------|----------|
| {preventive_action} | {name} | P1 | {date} |
| {detective_action} | {name} | P2 | {date} |

## Lessons Learned
- What went well: {detection_speed, communication, etc.}
- What went poorly: {gap_in_monitoring, slow_diagnosis, etc.}
- Where we got lucky: {it_could_have_been_worse_because}
```

## Capacity Planning

### Load Estimation
- **Current baseline**: Measure p50, p95, p99 for all resources during peak
- **Growth projection**: Extrapolate based on user/traffic growth rate
- **Safety margin**: Plan for 2x current peak (handle spikes without degradation)
- **Scaling triggers**: CPU > 70%, Memory > 80%, Queue depth > threshold

### Autoscaling Configuration
```yaml
# HPA example
minReplicas: 2
maxReplicas: 20
metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Pods
    pods:
      metric:
        name: http_requests_per_second
      target:
        type: AverageValue
        averageValue: 100
behavior:
  scaleUp:
    stabilizationWindowSeconds: 60
  scaleDown:
    stabilizationWindowSeconds: 300
```

### Right-sizing
- Review resource utilization monthly (CPU, memory, storage)
- Identify over-provisioned services (< 30% average utilization)
- Identify under-provisioned services (> 80% peak utilization)
- Use reserved instances / savings plans for baseline, spot/preemptible for burst

## Chaos Engineering

### Experiment Design Template
```markdown
# Chaos Experiment: {name}

## Hypothesis
Under {condition}, when {fault_injected}, the system should {expected_behavior}.

## Steady State
- Metric: {key_metric} = {baseline_value}
- Measurement: {how_to_measure}

## Experiment
- Fault type: {latency_injection / pod_kill / network_partition / disk_fill}
- Blast radius: {single_pod / single_AZ / percentage_of_traffic}
- Duration: {time}
- Abort conditions: {if_metric_exceeds_threshold, stop}

## Observations
- Steady state maintained: {yes/no}
- Recovery time: {duration}
- Unexpected behavior: {description}

## Actions
- {fix_discovered_weakness}
```

### Progressive Approach
1. **Start small**: Kill single pod, verify restart
2. **Network**: Inject latency (100ms → 500ms → 1s)
3. **Dependencies**: Kill external service, verify circuit breaker
4. **Zone/Region**: Simulate AZ failure
5. **Game days**: Full incident simulation with team

## Alerting Best Practices

- **Every alert must be actionable** — if no human action needed, it's noise
- **Symptom-based, not cause-based** — alert on user impact, not CPU spike
- **Two thresholds**: warning (ticket) and critical (page)
- **Include runbook link in every alert**
- **Review alert fatigue monthly** — if on-call acknowledges without acting, remove it
- **De-duplicate**: One alert per incident, not per symptom

## Limitations

- SRE practices must be adapted to the project's scale — not every service needs SLOs
- Chaos engineering requires a mature testing/staging environment first
- Incident response processes need team buy-in and regular drills to be effective
