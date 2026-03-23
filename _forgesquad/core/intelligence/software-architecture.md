---
name: Software Architecture Intelligence
type: embedded-intelligence
injected_into: [architect, tech_lead]
auto_inject: true
description: "Design patterns, DDD, SOLID, clean architecture — injected automatically into architecture agents"
---

# Software Architecture Intelligence

## Design Patterns (GoF)

### Creational
- **Singleton** — shared resource (config, connection pool). Avoid for testability unless necessary.
- **Factory Method** — defer object creation to subclasses. Use when type is determined at runtime.
- **Abstract Factory** — families of related objects (UI themes, DB drivers).
- **Builder** — complex objects with many optional params. Prefer over telescoping constructors.
- **Prototype** — clone expensive-to-create objects. Useful for caching templates.

### Structural
- **Adapter** — bridge incompatible interfaces (legacy integration, third-party SDKs).
- **Facade** — simplified interface to complex subsystem. Every microservice API is a facade.
- **Decorator** — add behavior without modifying class (logging, caching, auth middleware).
- **Composite** — tree structures (menus, org charts, file systems).
- **Proxy** — control access (lazy loading, caching proxy, circuit breaker).

### Behavioral
- **Strategy** — swappable algorithms at runtime (payment methods, sorting, validation rules).
- **Observer** — event-driven decoupling (pub/sub, webhooks, domain events).
- **Command** — encapsulate actions as objects (undo/redo, job queues, CQRS commands).
- **Template Method** — define skeleton, let subclasses override steps (ETL pipelines).
- **Chain of Responsibility** — pass request through handlers (middleware chains, validation pipes).
- **State** — object behavior changes with internal state (order status, workflow engines).

## Enterprise Patterns (PoEAA)

- **Repository** — collection-like interface for data access. Abstracts persistence from domain logic.
- **Unit of Work** — tracks changes across multiple entities, commits as one transaction. Use with Repository.
- **Service Layer** — orchestrates use cases. Thin layer between controllers and domain. No business logic here — delegate to domain.
- **Data Mapper** — separates domain objects from DB schema (ORMs like Hibernate, SQLAlchemy).
- **Domain Model** — rich objects with behavior, not anemic DTOs. Business rules live here.
- **Identity Map** — ensure one object per DB row per transaction. Prevents inconsistencies.

## Architecture Patterns

### Hexagonal (Ports & Adapters)
Domain at center. Ports define interfaces. Adapters implement infrastructure. Direction: outside depends on inside, never reversed. Test domain without infrastructure.

### Clean Architecture
Layers: Entities > Use Cases > Interface Adapters > Frameworks. Dependency Rule: inner layers never know about outer layers.

### CQRS (Command Query Responsibility Segregation)
Separate read and write models. Write model enforces invariants; read model optimized for queries. Consider when read/write patterns diverge significantly. Adds complexity — don't use by default.

### Event Sourcing
Store events, not state. Rebuild state by replaying events. Enables full audit trail, temporal queries, and event-driven architecture. Combine with CQRS. Warning: eventual consistency is hard — use only when audit/replay is a real requirement.

### Microservices vs Monolith
Start with modular monolith. Extract services only when: (1) independent scaling needed, (2) different deployment cadences, (3) team autonomy required. Distributed monolith is the worst outcome — if services can't deploy independently, you have one.

### Event-Driven Architecture
Services communicate via events (async). Patterns: Event Notification (fire-and-forget), Event-Carried State Transfer (data in event), Event Sourcing. Use message brokers (Kafka, RabbitMQ, SQS). Handle idempotency.

## Domain-Driven Design (DDD)

- **Bounded Context** — explicit boundary where a model applies. One team per context. Context Map defines relationships (Upstream/Downstream, ACL, Shared Kernel).
- **Aggregates** — cluster of entities with a root. Transactional consistency boundary. Keep small. Reference other aggregates by ID, not object.
- **Value Objects** — immutable, no identity (Money, Email, Address). Prefer over primitives.
- **Domain Events** — something that happened in the domain. Past tense (OrderPlaced, PaymentReceived). Use for cross-aggregate communication.
- **Ubiquitous Language** — domain experts and developers use the same terms in code, docs, and conversation. If the code says "createOrder" but business says "place order," fix the code.

## SOLID + Key Principles

- **S** — Single Responsibility: one reason to change.
- **O** — Open/Closed: extend behavior without modifying existing code.
- **L** — Liskov Substitution: subtypes must be substitutable for base types.
- **I** — Interface Segregation: many small interfaces > one fat interface.
- **D** — Dependency Inversion: depend on abstractions, not concretions.
- **DRY** — Don't Repeat Yourself. But duplication is better than wrong abstraction.
- **KISS** — Simplest solution that works. Complexity is a cost.
- **YAGNI** — Don't build it until you need it. Speculative generality kills projects.
- **Composition over Inheritance** — favor object composition. Inheritance creates coupling.
- **Fail Fast** — validate inputs at boundaries. Return errors early.
- **Principle of Least Astonishment** — APIs should behave as users expect.

## Code Smells & Refactoring

| Smell | Signal | Refactoring |
|-------|--------|-------------|
| God Class | Class with 500+ lines, 10+ dependencies | Extract classes by responsibility |
| Feature Envy | Method uses another class's data more than its own | Move method to the class it envies |
| Primitive Obsession | Strings/ints for domain concepts (email, money) | Introduce Value Objects |
| Long Parameter List | 4+ params in a method | Introduce Parameter Object or Builder |
| Shotgun Surgery | One change requires edits in 10 files | Consolidate into cohesive module |
| Divergent Change | One class changed for multiple unrelated reasons | Split by responsibility |
| Data Clumps | Same group of fields appears in multiple places | Extract class |
| Switch Statements | Type-checking switches everywhere | Replace with Strategy or Polymorphism |

## Evolutionary Architecture

- **Fitness Functions** — automated checks that protect architectural qualities (e.g., no cyclic dependencies, response time < 200ms, test coverage > 80%). Run in CI.
- **ADRs (Architecture Decision Records)** — document every significant decision. Format: Context, Decision, Status, Consequences. Never delete — supersede with new ADR.
- **Last Responsible Moment** — defer decisions until you have enough information. Premature architecture is as bad as premature optimization.
- **Sacrificial Architecture** — build knowing you'll replace it. First version teaches you what you actually need.

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
|--------------|---------|-----|
| Big Ball of Mud | No structure, everything depends on everything | Identify boundaries, extract modules, establish contracts |
| God Class / God Service | One component does everything | Decompose by single responsibility |
| Premature Optimization | Optimizing before measuring | Profile first, optimize bottlenecks only |
| Distributed Monolith | Microservices that can't deploy independently | Enforce service boundaries, async communication |
| Golden Hammer | Using one tech for everything | Choose tools based on problem characteristics |
| Cargo Cult Architecture | Copying Netflix/Google without their scale problems | Design for YOUR requirements, not someone else's |
| Anemic Domain Model | Domain objects are just data bags, all logic in services | Push behavior into domain objects |
| NIH Syndrome | Rebuilding what exists (auth, logging, queuing) | Use proven libraries/services for commodity problems |
