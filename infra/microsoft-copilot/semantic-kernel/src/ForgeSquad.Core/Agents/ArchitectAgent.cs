using System.ComponentModel;
using Microsoft.SemanticKernel;
using Microsoft.SemanticKernel.Agents;
using Microsoft.SemanticKernel.Connectors.AzureOpenAI;

namespace ForgeSquad.Core.Agents;

/// <summary>
/// The Architect agent is the most senior agent in the ForgeSquad.
/// It participates in ALL pipeline phases and is responsible for:
/// - System architecture design (C4 Model)
/// - Architecture Decision Records (ADRs)
/// - Non-functional requirements validation
/// - Technical governance and quality gates
/// - Technology stack governance via Tech Radar
/// </summary>
public static class ArchitectAgent
{
    public const string AgentName = "Architect";
    public const string ModelDeployment = "forgesquad-gpt4o"; // Premium tier

    private const string SystemPrompt = """
        You are the **Architect** of ForgeSquad, the most senior technical agent in the squad.

        ## Your Role
        You participate in EVERY phase of the pipeline — from Discovery to Retrospective.
        You are the guardian of technical quality and architectural coherence.

        ## Responsibilities
        1. **System Architecture Design**: Design solutions using patterns like Hexagonal,
           Clean Architecture, Microservices, Event-Driven, CQRS, Event Sourcing
        2. **Architecture Decision Records (ADRs)**: Document all important decisions
           in the ADR format with context, options, decision, and consequences
        3. **Technical Validation**: Review and validate artifacts from all other agents
        4. **Governance**: Ensure adherence to standards, policies, and regulations
        5. **Quality Gates**: Define and enforce quality criteria at each phase
        6. **Technology Stack**: Validate all technology choices against the company Tech Radar

        ## Decision Framework
        For every architectural decision:
        - **Context**: What is the problem or need?
        - **Options**: What alternatives were considered? (minimum 3)
        - **Decision**: What was chosen and why?
        - **Consequences**: What are the trade-offs?
        - **Status**: Proposed / Accepted / Deprecated / Superseded

        ## Output Format
        Always structure your responses with:
        - Clear sections with markdown headers
        - Diagrams in ASCII or Mermaid format when applicable
        - References to existing ADRs
        - Technical justification for each recommendation
        - Risk assessment with mitigation strategies

        ## Constraints
        - Never recommend technologies without justifying the trade-off
        - Always consider NFRs: performance, security, scalability, observability
        - Always validate compliance with applicable regulations (LGPD, Bacen, etc.)
        - Maintain consistency with previous decisions (consult ADRs)
        - When reviewing artifacts, use a structured checklist

        ## Interaction Protocol
        - With **Tech Lead**: Collaborate on implementation decisions
        - With **BA**: Validate that requirements are technically feasible
        - With **Finance Advisor**: Ensure regulatory compliance
        - With **QA**: Define architectural quality criteria
        - With **Dev Backend/Frontend**: Guide on patterns and best practices
        - When you reach a final decision, clearly state "DECIDED:" followed by the decision
        """;

    /// <summary>
    /// Creates the Architect ChatCompletionAgent with its plugins and configuration.
    /// </summary>
    public static ChatCompletionAgent Create(Kernel kernel)
    {
        // Register Architect-specific plugins
        KernelPlugin architectPlugins = KernelPluginFactory.CreateFromType<ArchitectPlugins>();
        kernel.Plugins.Add(architectPlugins);

        return new ChatCompletionAgent
        {
            Name = AgentName,
            Instructions = SystemPrompt,
            Kernel = kernel,
            Arguments = new KernelArguments(
                new AzureOpenAIPromptExecutionSettings
                {
                    Temperature = 0.2,
                    MaxTokens = 4096,
                    TopP = 0.9,
                    FrequencyPenalty = 0.1,
                    PresencePenalty = 0.1,
                    DeploymentName = ModelDeployment
                })
        };
    }
}

/// <summary>
/// Plugins (tools) available to the Architect agent.
/// These are automatically invoked by the agent when needed.
/// </summary>
public sealed class ArchitectPlugins
{
    [KernelFunction("generate_c4_diagram")]
    [Description("Generates a C4 Model diagram (Context, Container, Component, or Code level) from a system description")]
    public async Task<string> GenerateC4Diagram(
        [Description("Description of the system to diagram")] string systemDescription,
        [Description("C4 level: context, container, component, or code")] string level = "container")
    {
        // In production, this would call a diagram generation service
        // or use PlantUML/Mermaid rendering
        var mermaidTemplate = level.ToLowerInvariant() switch
        {
            "context" => GenerateContextDiagram(systemDescription),
            "container" => GenerateContainerDiagram(systemDescription),
            "component" => GenerateComponentDiagram(systemDescription),
            _ => GenerateContainerDiagram(systemDescription)
        };

        return $"""
            ## C4 Diagram - {level} Level

            ```mermaid
            {mermaidTemplate}
            ```

            *Generated for: {systemDescription[..Math.Min(100, systemDescription.Length)]}...*
            """;
    }

    [KernelFunction("create_adr")]
    [Description("Creates an Architecture Decision Record (ADR) with structured format")]
    public async Task<string> CreateAdr(
        [Description("Title of the architectural decision")] string title,
        [Description("Context explaining why this decision is needed")] string context,
        [Description("The chosen option and justification")] string decision,
        [Description("Positive and negative consequences")] string consequences,
        [Description("Status: Proposed, Accepted, Deprecated, Superseded")] string status = "Proposed")
    {
        var adrNumber = DateTimeOffset.UtcNow.ToString("yyyyMMddHHmm");

        return $"""
            # ADR-{adrNumber}: {title}

            **Date:** {DateTime.UtcNow:yyyy-MM-dd}
            **Status:** {status}
            **Deciders:** Architect, Tech Lead

            ## Context
            {context}

            ## Decision
            {decision}

            ## Consequences

            ### Positive
            {consequences}

            ### Risks & Mitigations
            *To be detailed during implementation phase.*

            ---
            *Generated by ForgeSquad Architect Agent*
            """;
    }

    [KernelFunction("validate_architecture")]
    [Description("Validates an architecture artifact against a quality checklist (security, performance, scalability, compliance)")]
    public async Task<string> ValidateArchitecture(
        [Description("Architecture description or artifact content to validate")] string architectureDescription,
        [Description("Checklist type: security, performance, scalability, compliance, or full")] string checklistType = "full")
    {
        var checklist = checklistType.ToLowerInvariant() switch
        {
            "security" => GetSecurityChecklist(),
            "performance" => GetPerformanceChecklist(),
            "scalability" => GetScalabilityChecklist(),
            "compliance" => GetComplianceChecklist(),
            _ => GetFullChecklist()
        };

        return $"""
            ## Architecture Validation Report
            **Type:** {checklistType}
            **Date:** {DateTime.UtcNow:yyyy-MM-dd HH:mm}

            ### Checklist Applied
            {checklist}

            ### Input Analyzed
            {architectureDescription[..Math.Min(500, architectureDescription.Length)]}...

            *Note: Complete validation requires manual review of each checklist item against the architecture.*
            *The Architect agent will analyze each item and provide a score.*
            """;
    }

    [KernelFunction("check_tech_radar")]
    [Description("Checks if a technology is approved in the company's Tech Radar")]
    public async Task<string> CheckTechRadar(
        [Description("Name of the technology to check")] string technologyName)
    {
        // In production, this queries Dataverse or an API
        // Here we simulate a Tech Radar lookup
        var knownTech = new Dictionary<string, (string Status, string Ring, string Notes)>
        {
            ["C#"] = ("Approved", "Adopt", "Primary backend language"),
            [".NET"] = ("Approved", "Adopt", "Primary framework"),
            ["PostgreSQL"] = ("Approved", "Adopt", "Primary relational database"),
            ["MongoDB"] = ("Approved", "Trial", "For document-oriented workloads"),
            ["Redis"] = ("Approved", "Adopt", "Caching and session management"),
            ["Kafka"] = ("Approved", "Adopt", "Event streaming platform"),
            ["RabbitMQ"] = ("Approved", "Trial", "Message queuing for simpler scenarios"),
            ["React"] = ("Approved", "Adopt", "Primary frontend framework"),
            ["Angular"] = ("Approved", "Hold", "Legacy support only"),
            ["Vue.js"] = ("Approved", "Assess", "Under evaluation"),
            ["Kubernetes"] = ("Approved", "Adopt", "Container orchestration"),
            ["Terraform"] = ("Approved", "Adopt", "Infrastructure as Code"),
            ["GraphQL"] = ("Approved", "Trial", "For specific BFF scenarios"),
        };

        if (knownTech.TryGetValue(technologyName, out var tech))
        {
            return $"""
                ## Tech Radar Check: {technologyName}
                - **Status:** {tech.Status}
                - **Ring:** {tech.Ring}
                - **Notes:** {tech.Notes}
                - **Recommendation:** {"Can be used in production" + (tech.Ring == "Adopt" ? " (recommended)" : tech.Ring == "Hold" ? " (discouraged for new projects)" : "")}
                """;
        }

        return $"""
            ## Tech Radar Check: {technologyName}
            - **Status:** Not Found
            - **Recommendation:** Technology not in Tech Radar. Requires Architecture Board approval before use.
            - **Action Required:** Submit tech assessment request to architecture-board@company.com
            """;
    }

    [KernelFunction("evaluate_nfrs")]
    [Description("Evaluates how well an architecture addresses non-functional requirements")]
    public async Task<string> EvaluateNfrs(
        [Description("Architecture description")] string architectureDescription,
        [Description("Comma-separated list of NFRs to evaluate")] string nfrs = "performance,security,scalability,availability,observability")
    {
        var nfrList = nfrs.Split(',', StringSplitOptions.TrimEntries);

        var evaluation = "## NFR Evaluation Report\n\n";
        evaluation += $"**Date:** {DateTime.UtcNow:yyyy-MM-dd}\n\n";
        evaluation += "| NFR | Status | Score | Notes |\n";
        evaluation += "|-----|--------|-------|-------|\n";

        foreach (var nfr in nfrList)
        {
            evaluation += $"| {nfr} | Pending Review | -/10 | Requires analysis against architecture |\n";
        }

        evaluation += "\n*The Architect agent will score each NFR based on the architecture description.*\n";
        return evaluation;
    }

    // Helper methods for diagram generation
    private static string GenerateContextDiagram(string description)
    {
        return """
            C4Context
                title System Context Diagram
                Person(user, "User", "System user")
                System(system, "Target System", "System under design")
                System_Ext(ext1, "External System 1", "Integration point")
                System_Ext(ext2, "External System 2", "Integration point")
                Rel(user, system, "Uses")
                Rel(system, ext1, "Integrates with")
                Rel(system, ext2, "Sends data to")
            """;
    }

    private static string GenerateContainerDiagram(string description)
    {
        return """
            C4Container
                title Container Diagram
                Person(user, "User")
                Container_Boundary(system, "System") {
                    Container(web, "Web App", "React", "Frontend SPA")
                    Container(api, "API", "C# / .NET 8", "REST API")
                    Container(worker, "Worker", "C# / .NET 8", "Background processing")
                    ContainerDb(db, "Database", "PostgreSQL", "Primary data store")
                    ContainerDb(cache, "Cache", "Redis", "Session and caching")
                    Container(queue, "Message Queue", "Kafka", "Event streaming")
                }
                Rel(user, web, "Uses", "HTTPS")
                Rel(web, api, "Calls", "HTTPS/JSON")
                Rel(api, db, "Reads/Writes")
                Rel(api, cache, "Reads/Writes")
                Rel(api, queue, "Publishes")
                Rel(worker, queue, "Consumes")
                Rel(worker, db, "Reads/Writes")
            """;
    }

    private static string GenerateComponentDiagram(string description)
    {
        return """
            C4Component
                title Component Diagram - API
                Container_Boundary(api, "API") {
                    Component(controllers, "Controllers", "C#", "REST endpoints")
                    Component(services, "Application Services", "C#", "Business logic")
                    Component(domain, "Domain Model", "C#", "Entities and value objects")
                    Component(repos, "Repositories", "C#", "Data access")
                    Component(events, "Event Publishers", "C#", "Domain events")
                }
                Rel(controllers, services, "Calls")
                Rel(services, domain, "Uses")
                Rel(services, repos, "Uses")
                Rel(services, events, "Publishes")
            """;
    }

    private static string GetSecurityChecklist()
    {
        return """
            - [ ] Authentication mechanism defined (OAuth2/OIDC)
            - [ ] Authorization model defined (RBAC/ABAC)
            - [ ] Data encryption at rest (AES-256)
            - [ ] Data encryption in transit (TLS 1.3)
            - [ ] Input validation strategy
            - [ ] OWASP Top 10 mitigations
            - [ ] Secrets management (Key Vault)
            - [ ] API rate limiting
            - [ ] Audit logging for security events
            - [ ] Vulnerability scanning in CI/CD
            """;
    }

    private static string GetPerformanceChecklist()
    {
        return """
            - [ ] Response time SLOs defined
            - [ ] Throughput requirements specified
            - [ ] Caching strategy defined
            - [ ] Database indexing strategy
            - [ ] Connection pooling configured
            - [ ] Async processing for heavy operations
            - [ ] CDN for static assets
            - [ ] Load testing plan
            """;
    }

    private static string GetScalabilityChecklist()
    {
        return """
            - [ ] Horizontal scaling strategy
            - [ ] Stateless services design
            - [ ] Database sharding/partitioning plan
            - [ ] Auto-scaling rules defined
            - [ ] Message queue for decoupling
            - [ ] Circuit breaker pattern
            - [ ] Capacity planning documented
            """;
    }

    private static string GetComplianceChecklist()
    {
        return """
            - [ ] LGPD data classification
            - [ ] Consent management
            - [ ] Data retention policies
            - [ ] Right to erasure implementation
            - [ ] Bacen 4893 security controls
            - [ ] Bacen 4658 cloud requirements
            - [ ] Audit trail for all operations
            - [ ] Data residency requirements
            """;
    }

    private static string GetFullChecklist()
    {
        return $"""
            ### Security
            {GetSecurityChecklist()}

            ### Performance
            {GetPerformanceChecklist()}

            ### Scalability
            {GetScalabilityChecklist()}

            ### Compliance
            {GetComplianceChecklist()}
            """;
    }
}
