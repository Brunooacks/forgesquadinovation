---
name: "Testing Best Practices"
---

# Testing Best Practices

## Test Pyramid

Follow the test pyramid to balance speed, confidence, and cost:

```
        /  E2E  \        ~5% of tests
       / Integration \   ~15% of tests
      /    Unit Tests   \ ~80% of tests
```

- **Unit tests**: Fast, isolated, test a single function or class.
- **Integration tests**: Verify interactions between components (DB, APIs, queues).
- **E2E tests**: Validate critical user journeys through the full stack.

## Coverage Targets

| Layer       | Minimum Coverage | Notes                              |
|-------------|------------------|------------------------------------|
| Unit        | 80%              | Focus on business logic            |
| Integration | 60%              | Cover happy path + key error paths |
| E2E         | Critical paths   | Top 5-10 user journeys             |

- Coverage is a guideline, not a goal. Do not write meaningless tests to hit a number.
- Measure **branch coverage**, not just line coverage.

## Test Naming Conventions

Use a descriptive pattern that reads as a specification:

```
should_[expected behavior]_when_[condition]
```

Examples:
- `should_return_404_when_user_not_found`
- `should_calculate_discount_when_cart_exceeds_threshold`

## Mocking Strategy

- Mock **external dependencies** (HTTP clients, databases, message brokers).
- Do **not** mock the class under test or its internal methods.
- Prefer **fakes** (in-memory DB, stub server) over mocks for integration tests.
- Limit mock assertions to **one or two interactions** per test.
- Reset mocks between tests to avoid shared state.

## Test Data Management

- Use **factories or builders** to create test data programmatically.
- Avoid shared fixtures that create coupling between tests.
- Each test should set up its own data and clean up after itself.
- For integration tests, use database transactions that roll back after each test.
- Never rely on data from other tests or environments.

## Performance Testing Thresholds

| Metric                | Target          |
|-----------------------|-----------------|
| API p95 response time | < 300 ms        |
| API p99 response time | < 1 s           |
| Throughput            | Per SLA         |
| Error rate under load | < 0.1%          |

- Run performance tests in CI on a schedule (nightly or pre-release).
- Use baseline comparison to detect regressions (> 10% degradation = failure).
- Test with realistic data volumes and concurrency patterns.

## General Principles

- Tests must be **deterministic** -- no flaky tests in CI.
- Tests must be **independent** -- runnable in any order.
- Fix or quarantine flaky tests within 24 hours.
- Treat test code with the same quality standards as production code.
