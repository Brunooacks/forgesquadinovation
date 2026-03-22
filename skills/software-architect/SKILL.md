---
name: "Software Architect"
description: "Design patterns, enterprise architecture, DDD, SOLID, refactoring — inspired by Martin Fowler's principles"
type: prompt
version: "1.0.0"
category: architecture
agents: [architect, tech-lead, dev-backend, dev-frontend]
---

# Software Architect — Design Patterns & Architecture Skill

Provides deep software architecture knowledge inspired by Martin Fowler's work on patterns, refactoring, enterprise application architecture, and evolutionary design. Guides agents toward clean, maintainable, and scalable solutions.

## When to Use Software Architect

- **System design**: Choosing architecture patterns for new projects
- **Code quality**: Identifying code smells and applying refactorings
- **Design decisions**: Selecting appropriate design patterns
- **Domain modeling**: Applying DDD tactical and strategic patterns
- **Technical debt**: Planning incremental architecture improvements

## Design Patterns (Gang of Four)

### Creational Patterns

**Factory Method**: Define interface for creating objects, let subclasses decide which class to instantiate. Use when the exact type depends on runtime configuration or input.

**Abstract Factory**: Provide interface for creating families of related objects. Use for cross-platform UIs or multi-database support.

**Builder**: Separate construction of complex objects from their representation. Use when constructors have many optional parameters.

**Singleton**: Ensure a class has only one instance. Use sparingly — prefer dependency injection. Valid for: connection pools, config stores, thread pools.

### Structural Patterns

**Adapter**: Convert interface of a class into another interface clients expect. Use when integrating with third-party libraries or legacy systems.

**Facade**: Provide simplified interface to a complex subsystem. Use to reduce coupling between layers.

**Decorator**: Attach additional responsibilities to objects dynamically. Use for cross-cutting concerns (logging, caching, retry) without modifying original class.

**Proxy**: Provide surrogate for another object to control access. Use for: lazy loading, access control, caching, remote calls.

**Composite**: Compose objects into tree structures. Use for hierarchical data (menus, org charts, file systems).

### Behavioral Patterns

**Strategy**: Define family of algorithms, make them interchangeable. Use when multiple approaches exist for the same operation (sorting, pricing, validation).

**Observer**: Define one-to-many dependency between objects. Use for event systems, reactive UIs, notification services.

**Command**: Encapsulate request as an object. Use for undo/redo, task queues, audit logging.

**Chain of Responsibility**: Pass request along a chain of handlers. Use for middleware pipelines, validation chains, approval workflows.

**Template Method**: Define skeleton of algorithm in base class, let subclasses fill in steps. Use for standardized workflows with variable steps.

**State**: Allow object to alter behavior when internal state changes. Use for order processing, workflow engines, UI state machines.

## Enterprise Application Patterns (PoEAA)

### Domain Logic Patterns

**Domain Model**: Rich object model with data AND behavior. Use for complex business logic with many rules and variations.

**Transaction Script**: Organize logic by procedures, each handling a single request. Use for simple CRUD operations with straightforward business rules.

**Service Layer**: Define application boundary with a set of available operations. Coordinates domain logic and transactions.

### Data Source Patterns

**Repository**: Mediate between domain and data mapping layers. Provide collection-like interface for accessing domain objects.
```
interface UserRepository {
  findById(id: string): User
  findByEmail(email: string): User
  save(user: User): void
  delete(user: User): void
}
```

**Data Mapper**: Map objects to database records and back. Keep domain model ignorant of database schema.

**Unit of Work**: Maintain a list of objects affected by a business transaction. Coordinate writing out changes and resolving concurrency.

**Active Record**: Object that wraps a database row, adds domain logic, and handles persistence. Use for simple CRUD — avoid for complex domains.

### Presentation Patterns

**MVC/MVP/MVVM**: Separate UI concerns from business logic. Choose based on platform and framework conventions.

## Architecture Patterns

### Hexagonal Architecture (Ports & Adapters)
```
┌──────────────────────────────────────────────┐
│                  Adapters (outer)              │
│  ┌─────────┐  ┌──────────┐  ┌────────────┐   │
│  │  REST    │  │ Database │  │  Message    │   │
│  │  API     │  │ Adapter  │  │  Queue      │   │
│  └────┬─────┘  └────┬─────┘  └─────┬──────┘   │
│       │              │              │           │
│  ─────┼──────────────┼──────────────┼────────── │
│       │         Ports (interface)   │           │
│  ─────┼──────────────┼──────────────┼────────── │
│       │              │              │           │
│  ┌────┴──────────────┴──────────────┴──────┐   │
│  │           Domain Core (inner)            │   │
│  │    Entities, Value Objects, Services     │   │
│  │    Pure business logic, no dependencies  │   │
│  └──────────────────────────────────────────┘   │
└──────────────────────────────────────────────────┘
```
- **Core rule**: Domain core has ZERO dependencies on infrastructure
- **Ports**: Interfaces defined by the domain (what it needs)
- **Adapters**: Implementations that satisfy ports (how it's provided)

### Clean Architecture
Same principle as hexagonal: dependency rule flows inward.
```
Entities (innermost) → Use Cases → Interface Adapters → Frameworks (outermost)
```

### CQRS (Command Query Responsibility Segregation)
- Separate read models from write models
- Commands mutate state (validated, audited)
- Queries return data (optimized, denormalized)
- Use when read/write patterns differ significantly

### Event Sourcing
- Store sequence of events, not current state
- Rebuild state by replaying events
- Perfect audit trail (every change recorded)
- Use for: financial systems, audit-critical domains, temporal queries
- Combine with CQRS for read-optimized projections

### Microservices vs Monolith
**Start with Monolith** (Martin Fowler's recommendation):
- Begin monolithic, split when boundaries are clear
- Premature decomposition is worse than a well-structured monolith
- "Monolith First" — extract services only when you understand the domain

**Strangler Fig Pattern** (for migration):
1. Identify bounded context to extract
2. Build new service alongside monolith
3. Route traffic incrementally to new service
4. Remove old code when fully migrated

## Domain-Driven Design (DDD)

### Strategic Patterns

**Bounded Context**: Explicit boundary within which a domain model applies. Each context has its own ubiquitous language.

**Context Map**: Visual representation of relationships between bounded contexts:
- **Shared Kernel**: Two contexts share a subset of the model
- **Customer-Supplier**: One context depends on another
- **Anti-Corruption Layer**: Translate between incompatible models
- **Published Language**: Standard protocol for inter-context communication

### Tactical Patterns

**Entity**: Object defined by identity (not attributes). Has lifecycle.
```
class Order {
  readonly id: OrderId          // Identity
  private items: OrderItem[]    // State
  private status: OrderStatus   // State

  addItem(product, qty): void   // Behavior
  submit(): void                // Behavior with rules
}
```

**Value Object**: Object defined by attributes (not identity). Immutable.
```
class Money {
  constructor(readonly amount: number, readonly currency: string) {}
  add(other: Money): Money { /* validate same currency, return new */ }
}
```

**Aggregate**: Cluster of entities/value objects with a single root entity. All external references go through the root. Transactional consistency boundary.

**Domain Event**: Something that happened in the domain that domain experts care about.
```
class OrderSubmitted {
  constructor(readonly orderId, readonly items, readonly timestamp) {}
}
```

**Domain Service**: Operation that doesn't belong to any entity/value object. Stateless.

## Code Smells & Refactoring

### Critical Code Smells

| Smell | Symptom | Refactoring |
|-------|---------|-------------|
| **Long Method** | Method > 20 lines | Extract Method |
| **Feature Envy** | Method uses another class's data more than its own | Move Method |
| **Shotgun Surgery** | One change requires editing many classes | Move Method, Inline Class |
| **Divergent Change** | One class changed for different reasons | Extract Class |
| **Primitive Obsession** | Using primitives instead of small objects | Replace Primitive with Value Object |
| **Data Clumps** | Same group of data appears together repeatedly | Introduce Parameter Object |
| **Switch Statements** | Long switch/if-else on type | Replace Conditional with Polymorphism |
| **Refused Bequest** | Subclass doesn't use parent's methods | Replace Inheritance with Delegation |

### Key Refactorings
- **Extract Method**: Turn code fragment into a method with intent-revealing name
- **Introduce Parameter Object**: Replace group of parameters with a single object
- **Replace Temp with Query**: Turn temporary variable into a method call
- **Compose Method**: Transform method into sequence of steps at the same abstraction level
- **Replace Conditional with Polymorphism**: Turn type-based conditionals into subclass behavior

## SOLID Principles

1. **S — Single Responsibility**: A class should have one reason to change
2. **O — Open/Closed**: Open for extension, closed for modification (use interfaces/abstractions)
3. **L — Liskov Substitution**: Subtypes must be substitutable for their base types
4. **I — Interface Segregation**: Many specific interfaces > one general interface
5. **D — Dependency Inversion**: Depend on abstractions, not concretions

## Additional Principles

- **DRY** (Don't Repeat Yourself): Extract duplication, but only when the duplicated code changes for the same reason
- **KISS** (Keep It Simple): Simplest solution that works. Complexity is a cost.
- **YAGNI** (You Aren't Gonna Need It): Don't build for hypothetical futures
- **Tell, Don't Ask**: Tell objects what to do, don't ask for their data and decide for them
- **Law of Demeter**: Only talk to your immediate friends (avoid `a.b.c.doThing()`)
- **Composition over Inheritance**: Favor object composition for code reuse
- **Separation of Concerns**: Each module addresses a distinct concern

## Evolutionary Architecture

### Fitness Functions
Automated checks that verify architectural characteristics are maintained:
- **Performance**: p99 latency < 200ms (tested in CI)
- **Coupling**: No circular dependencies between modules
- **Security**: No known CVEs in dependencies
- **Testability**: Coverage > 80% per module

### Incremental Change
- Make architecture decisions reversible where possible
- Use feature flags to experiment with new approaches
- Measure before and after with fitness functions
- ADRs (Architecture Decision Records) for every significant decision

### ADR Template
```markdown
# ADR-{number}: {title}
Date: {date} | Status: {proposed/accepted/deprecated/superseded}

## Context
{What forces are at play?}

## Decision
{What was decided?}

## Consequences
{What are the trade-offs?}
```

## Testing Architecture

### Test Pyramid
```
         /\
        /  \        E2E (5%)
       /────\       Smoke tests, critical paths
      /      \
     /────────\     Integration (15%)
    /          \    API contracts, DB queries
   /────────────\
  /              \  Unit (80%)
 /________________\ Pure logic, fast, isolated
```

### Test Doubles
- **Stub**: Returns canned answers (use for queries)
- **Mock**: Verifies interactions (use for commands, sparingly)
- **Fake**: Working implementation with shortcuts (in-memory DB)
- **Spy**: Records calls for later verification

### Contract Testing
- Consumer-Driven Contracts: Consumer defines expectations, provider verifies
- Tools: Pact, Spring Cloud Contract
- Use between microservices to prevent integration breakage

## Limitations

- Design patterns are tools, not rules — don't force patterns where they don't fit
- Over-engineering with patterns is as harmful as no patterns
- DDD is overkill for simple CRUD applications
- Architecture should evolve with understanding — don't design everything upfront
