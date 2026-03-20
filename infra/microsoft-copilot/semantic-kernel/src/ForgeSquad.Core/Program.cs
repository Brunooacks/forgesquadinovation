using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Microsoft.SemanticKernel;
using Microsoft.SemanticKernel.Agents;
using Microsoft.SemanticKernel.Connectors.AzureOpenAI;
using ForgeSquad.Core.Agents;
using ForgeSquad.Core.AuditTrail;
using ForgeSquad.Core.Pipeline;
using ForgeSquad.Core.Skills;

namespace ForgeSquad.Core;

/// <summary>
/// ForgeSquad entry point.
/// Configures DI, registers all 9 agents, loads pipeline definition,
/// and starts the pipeline runner.
/// </summary>
public static class Program
{
    public static async Task Main(string[] args)
    {
        Console.WriteLine("==============================================");
        Console.WriteLine("  ForgeSquad — Multi-Agent Orchestration");
        Console.WriteLine("  Powered by Microsoft Semantic Kernel");
        Console.WriteLine("==============================================");
        Console.WriteLine();

        // 1. Build configuration
        var configuration = new ConfigurationBuilder()
            .AddJsonFile("appsettings.json", optional: true)
            .AddJsonFile($"appsettings.{Environment.GetEnvironmentVariable("DOTNET_ENVIRONMENT") ?? "Development"}.json", optional: true)
            .AddEnvironmentVariables()
            .AddUserSecrets<PipelineRunner>(optional: true)
            .AddCommandLine(args)
            .Build();

        // 2. Build service collection
        var services = new ServiceCollection();

        // Logging
        services.AddLogging(builder =>
        {
            builder.AddConsole();
            builder.SetMinimumLevel(LogLevel.Information);
        });

        // Configuration sections
        services.Configure<AuditLoggerOptions>(configuration.GetSection("CosmosDb"));
        services.Configure<ApprovalGateOptions>(configuration.GetSection("ApprovalGate"));
        services.Configure<DevinOptions>(configuration.GetSection("Devin"));

        // HTTP client
        services.AddHttpClient();

        // Audit Logger
        services.AddSingleton<AuditLogger>();

        // Approval Gate
        services.AddSingleton<ApprovalGate>();

        // 3. Create Semantic Kernels (one per model tier)
        var azureOpenAiEndpoint = configuration["AzureOpenAI:Endpoint"]
            ?? throw new InvalidOperationException("AzureOpenAI:Endpoint not configured");
        var azureOpenAiKey = configuration["AzureOpenAI:ApiKey"]
            ?? throw new InvalidOperationException("AzureOpenAI:ApiKey not configured");
        var gpt4oDeployment = configuration["AzureOpenAI:DeploymentGpt4o"] ?? "forgesquad-gpt4o";
        var gpt4oMiniDeployment = configuration["AzureOpenAI:DeploymentGpt4oMini"] ?? "forgesquad-gpt4o-mini";

        // Premium kernel (GPT-4o) — for complex reasoning agents
        var premiumKernel = Kernel.CreateBuilder()
            .AddAzureOpenAIChatCompletion(gpt4oDeployment, azureOpenAiEndpoint, azureOpenAiKey)
            .Build();

        // Standard kernel (GPT-4o-mini) — for support agents
        var standardKernel = Kernel.CreateBuilder()
            .AddAzureOpenAIChatCompletion(gpt4oMiniDeployment, azureOpenAiEndpoint, azureOpenAiKey)
            .Build();

        // 4. Register all 9 agents
        Console.WriteLine("Registering agents...");
        var agents = new Dictionary<string, ChatCompletionAgent>();

        // Premium tier agents (GPT-4o)
        agents["Architect"] = ArchitectAgent.Create(premiumKernel.Clone());
        agents["FinanceAdvisor"] = FinanceAdvisorAgent.Create(premiumKernel.Clone());
        agents["TechLead"] = CreateAgent("TechLead", TechLeadPrompt, premiumKernel.Clone());
        agents["DevBackend"] = CreateAgent("DevBackend", DevBackendPrompt, premiumKernel.Clone());
        agents["DevFrontend"] = CreateAgent("DevFrontend", DevFrontendPrompt, premiumKernel.Clone());

        // Standard tier agents (GPT-4o-mini)
        agents["BA"] = CreateAgent("BusinessAnalyst", BAPrompt, standardKernel.Clone());
        agents["QA"] = CreateAgent("QAEngineer", QAPrompt, standardKernel.Clone());
        agents["TechWriter"] = CreateAgent("TechWriter", TechWriterPrompt, standardKernel.Clone());
        agents["PM"] = CreateAgent("ProjectManager", PMPrompt, standardKernel.Clone());

        foreach (var agent in agents)
        {
            Console.WriteLine($"  [OK] {agent.Key} ({(agent.Key is "Architect" or "FinanceAdvisor" or "TechLead" or "DevBackend" or "DevFrontend" ? "GPT-4o" : "GPT-4o-mini")})");
        }

        Console.WriteLine($"\nTotal: {agents.Count} agents registered");

        // 5. Build pipeline definition
        var pipeline = BuildStandardPipeline();
        Console.WriteLine($"Pipeline loaded: {pipeline.Phases.Count} phases, {pipeline.Phases.Sum(p => p.Steps.Count)} steps, {pipeline.Phases.Count(p => p.Checkpoint?.Enabled == true)} checkpoints");

        // 6. Build services and run
        var serviceProvider = services.BuildServiceProvider();
        var logger = serviceProvider.GetRequiredService<ILogger<PipelineRunner>>();
        var auditLogger = serviceProvider.GetRequiredService<AuditLogger>();
        var approvalGate = serviceProvider.GetRequiredService<ApprovalGate>();

        // Initialize Cosmos DB
        var cosmosOptions = configuration.GetSection("CosmosDb").Get<AuditLoggerOptions>();
        if (cosmosOptions != null && !string.IsNullOrEmpty(cosmosOptions.CosmosEndpoint))
        {
            await auditLogger.InitializeAsync(cosmosOptions);
        }

        // 7. Create and run pipeline
        var runner = new PipelineRunner(agents, approvalGate, auditLogger, logger);

        var context = new PipelineContext
        {
            SquadName = configuration["Squad:Name"] ?? "default-squad",
            ProjectName = configuration["Project:Name"] ?? "ForgeSquad Demo Project",
            ProjectDescription = configuration["Project:Description"]
                ?? "A demonstration project to showcase ForgeSquad multi-agent orchestration",
            RequestedBy = Environment.UserName,
            DefaultApprovers = configuration.GetSection("ApprovalGate:DefaultApprovers")
                .Get<List<string>>() ?? ["admin@company.com"]
        };

        Console.WriteLine($"\nStarting pipeline for project: {context.ProjectName}");
        Console.WriteLine($"Squad: {context.SquadName}");
        Console.WriteLine($"Requested by: {context.RequestedBy}");
        Console.WriteLine();

        var result = await runner.ExecuteAsync(pipeline, context);

        // 8. Output results
        Console.WriteLine("\n==============================================");
        Console.WriteLine($"  Pipeline {result.Status}");
        Console.WriteLine("==============================================");
        Console.WriteLine($"Run ID: {result.RunId}");
        Console.WriteLine($"Duration: {result.CompletedAt - result.StartedAt}");
        Console.WriteLine($"Phases completed: {result.PhaseResults.Count(p => p.Status == PhaseStatus.Completed)}");
        Console.WriteLine($"Total tokens: {result.PhaseResults.Sum(p => p.TokensUsed):N0}");

        if (result.Status == PipelineStatus.Paused)
        {
            Console.WriteLine($"\nPipeline paused at: {result.PausedAtPhase}");
            Console.WriteLine("A checkpoint was rejected. Review and re-run to continue.");
        }
    }

    /// <summary>
    /// Creates a generic ChatCompletionAgent with the given name and prompt.
    /// Used for agents that don't have dedicated classes.
    /// </summary>
    private static ChatCompletionAgent CreateAgent(string name, string instructions, Kernel kernel)
    {
        return new ChatCompletionAgent
        {
            Name = name,
            Instructions = instructions,
            Kernel = kernel,
            Arguments = new KernelArguments(
                new AzureOpenAIPromptExecutionSettings
                {
                    Temperature = 0.3,
                    MaxTokens = 4096
                })
        };
    }

    /// <summary>
    /// Builds the standard ForgeSquad pipeline with 10 phases.
    /// </summary>
    private static PipelineDefinition BuildStandardPipeline()
    {
        return new PipelineDefinition
        {
            Name = "ForgeSquad Standard Pipeline",
            Version = "1.0",
            Phases =
            [
                new PhaseDefinition
                {
                    Number = 1, Name = "Discovery",
                    Agents = ["PM", "BA", "Architect"],
                    Steps =
                    [
                        new StepDefinition { Name = "Stakeholder Mapping", PrimaryAgent = "PM", Description = "Identify and map all project stakeholders", ExpectedOutput = "Stakeholder map with interest/influence matrix" },
                        new StepDefinition { Name = "Domain Analysis", PrimaryAgent = "BA", SecondaryAgents = ["Architect"], Description = "Analyze business domain using DDD", ExpectedOutput = "Bounded contexts, entities, domain events", RequiredContext = ["ProjectDescription"] },
                        new StepDefinition { Name = "Feasibility Check", PrimaryAgent = "Architect", SecondaryAgents = ["FinanceAdvisor"], Description = "Technical feasibility assessment", ExpectedOutput = "Feasibility report with Go/No-Go recommendation", RequiredContext = ["Discovery_Domain Analysis"] }
                    ],
                    Checkpoint = new CheckpointDefinition { Enabled = true, Number = 1, Approvers = ["product-owner@company.com"], TimeoutMinutes = 1440 }
                },
                new PhaseDefinition
                {
                    Number = 2, Name = "Requirements",
                    Agents = ["BA", "Architect", "QA"],
                    Steps =
                    [
                        new StepDefinition { Name = "User Stories", PrimaryAgent = "BA", Description = "Create user stories with acceptance criteria", ExpectedOutput = "User stories in standard format with Gherkin acceptance criteria", RequiredContext = ["Discovery_Domain Analysis"] },
                        new StepDefinition { Name = "Acceptance Criteria", PrimaryAgent = "QA", SecondaryAgents = ["BA"], Description = "Refine acceptance criteria with edge cases", ExpectedOutput = "Refined criteria with edge cases and NFRs", RequiredContext = ["Requirements_User Stories"] },
                        new StepDefinition { Name = "Requirements Review", PrimaryAgent = "Architect", SecondaryAgents = ["TechLead"], Description = "Validate all requirements", ExpectedOutput = "Validated requirements with technical notes", RequiredContext = ["Requirements_User Stories", "Requirements_Acceptance Criteria"] }
                    ],
                    Checkpoint = new CheckpointDefinition { Enabled = true, Number = 2, TimeoutMinutes = 1440 }
                },
                new PhaseDefinition
                {
                    Number = 3, Name = "Architecture",
                    Agents = ["Architect", "TechLead", "FinanceAdvisor"],
                    Steps =
                    [
                        new StepDefinition { Name = "Solution Design", PrimaryAgent = "Architect", SecondaryAgents = ["TechLead"], Description = "Design system architecture", ExpectedOutput = "C4 diagrams, technology stack, architectural patterns", RequiredContext = ["Requirements_Requirements Review"] },
                        new StepDefinition { Name = "ADR Creation", PrimaryAgent = "Architect", SecondaryAgents = ["FinanceAdvisor"], Description = "Document architectural decisions", ExpectedOutput = "ADR documents for key decisions", RequiredContext = ["Architecture_Solution Design"] }
                    ],
                    Checkpoint = new CheckpointDefinition { Enabled = true, Number = 3, TimeoutMinutes = 1440 }
                },
                new PhaseDefinition
                {
                    Number = 4, Name = "Planning",
                    Agents = ["TechLead", "PM"],
                    Steps =
                    [
                        new StepDefinition { Name = "Sprint Planning", PrimaryAgent = "TechLead", SecondaryAgents = ["PM"], Description = "Plan implementation sprints", ExpectedOutput = "Sprint plan with story point estimates" },
                        new StepDefinition { Name = "Task Breakdown", PrimaryAgent = "TechLead", Description = "Decompose stories into tasks", ExpectedOutput = "Task list with estimates and dependencies", RequiredContext = ["Requirements_User Stories", "Architecture_Solution Design"] }
                    ],
                    Checkpoint = new CheckpointDefinition { Enabled = true, Number = 4, TimeoutMinutes = 1440 }
                },
                new PhaseDefinition
                {
                    Number = 5, Name = "Backend Development",
                    Agents = ["DevBackend", "TechLead", "Architect"],
                    Steps =
                    [
                        new StepDefinition { Name = "API Design", PrimaryAgent = "DevBackend", SecondaryAgents = ["Architect"], Description = "Design REST/GraphQL APIs", ExpectedOutput = "OpenAPI specification", RequiredContext = ["Architecture_Solution Design"] },
                        new StepDefinition { Name = "Implementation", PrimaryAgent = "DevBackend", Description = "Implement backend services", ExpectedOutput = "Source code with unit tests", RequiredContext = ["Backend Development_API Design"] },
                        new StepDefinition { Name = "Code Review", PrimaryAgent = "TechLead", SecondaryAgents = ["Architect"], Description = "Review backend code", ExpectedOutput = "Code review report with approve/reject", RequiredContext = ["Backend Development_Implementation"], MaxIterations = 4 }
                    ],
                    Checkpoint = new CheckpointDefinition { Enabled = true, Number = 5, TimeoutMinutes = 1440 }
                },
                new PhaseDefinition
                {
                    Number = 6, Name = "Frontend Development",
                    Agents = ["DevFrontend", "TechLead"],
                    Steps =
                    [
                        new StepDefinition { Name = "UI Design", PrimaryAgent = "DevFrontend", SecondaryAgents = ["BA"], Description = "Design UI components and layouts", ExpectedOutput = "Component hierarchy and wireframes" },
                        new StepDefinition { Name = "Implementation", PrimaryAgent = "DevFrontend", Description = "Implement frontend application", ExpectedOutput = "Source code with component tests" },
                        new StepDefinition { Name = "Integration", PrimaryAgent = "DevFrontend", SecondaryAgents = ["DevBackend"], Description = "Integrate frontend with backend APIs", ExpectedOutput = "Integration test results", MaxIterations = 4 }
                    ],
                    Checkpoint = new CheckpointDefinition { Enabled = true, Number = 6, TimeoutMinutes = 1440 }
                },
                new PhaseDefinition
                {
                    Number = 7, Name = "QA",
                    Agents = ["QA", "DevBackend", "DevFrontend"],
                    Steps =
                    [
                        new StepDefinition { Name = "Test Strategy", PrimaryAgent = "QA", SecondaryAgents = ["TechLead"], Description = "Define test strategy and plan", ExpectedOutput = "Test plan with coverage targets" },
                        new StepDefinition { Name = "Test Execution", PrimaryAgent = "QA", Description = "Execute test suite", ExpectedOutput = "Test results report with coverage metrics" }
                    ],
                    Checkpoint = new CheckpointDefinition { Enabled = true, Number = 7, TimeoutMinutes = 1440 }
                },
                new PhaseDefinition
                {
                    Number = 8, Name = "Documentation",
                    Agents = ["TechWriter", "Architect"],
                    Steps =
                    [
                        new StepDefinition { Name = "API Documentation", PrimaryAgent = "TechWriter", SecondaryAgents = ["DevBackend"], Description = "Generate API documentation", ExpectedOutput = "API docs with examples and guides" },
                        new StepDefinition { Name = "Runbooks & ADRs", PrimaryAgent = "TechWriter", SecondaryAgents = ["Architect"], Description = "Create operational runbooks", ExpectedOutput = "Runbooks, ADRs, and operational guides" }
                    ],
                    Checkpoint = new CheckpointDefinition { Enabled = true, Number = 8, TimeoutMinutes = 1440 }
                },
                new PhaseDefinition
                {
                    Number = 9, Name = "Deployment",
                    Agents = ["TechLead", "DevBackend", "QA"],
                    Steps =
                    [
                        new StepDefinition { Name = "CI/CD Pipeline", PrimaryAgent = "TechLead", Description = "Configure CI/CD pipeline", ExpectedOutput = "Pipeline configuration (GitHub Actions/Azure DevOps)" },
                        new StepDefinition { Name = "Production Deploy", PrimaryAgent = "TechLead", SecondaryAgents = ["QA"], Description = "Deploy to production", ExpectedOutput = "Deployment report with health checks", MaxIterations = 4 }
                    ],
                    Checkpoint = new CheckpointDefinition { Enabled = true, Number = 9, TimeoutMinutes = 1440 }
                },
                new PhaseDefinition
                {
                    Number = 10, Name = "Retrospective",
                    Agents = ["PM", "Architect"],
                    Steps =
                    [
                        new StepDefinition { Name = "Metrics Collection", PrimaryAgent = "PM", Description = "Collect and analyze project metrics", ExpectedOutput = "Metrics dashboard with KPIs" },
                        new StepDefinition { Name = "Lessons Learned", PrimaryAgent = "PM", SecondaryAgents = ["Architect"], Description = "Document lessons learned", ExpectedOutput = "Retrospective report with action items", MaxIterations = 4 }
                    ],
                    Checkpoint = null // No checkpoint for final phase
                }
            ]
        };
    }

    // --- Agent System Prompts ---

    private const string TechLeadPrompt = """
        You are the Tech Lead of ForgeSquad. You coordinate technical execution,
        manage code standards, conduct code reviews, and plan sprints. You bridge
        the gap between the Architect's vision and the development team's execution.
        Focus on: code quality, team productivity, technical debt management, and CI/CD.
        """;

    private const string DevBackendPrompt = """
        You are the Backend Developer of ForgeSquad. You implement server-side logic,
        APIs, database schemas, and integrations. You follow Clean Architecture and
        SOLID principles. You write comprehensive unit and integration tests.
        Technologies: C# / .NET 8, PostgreSQL, Redis, Kafka, Docker.
        """;

    private const string DevFrontendPrompt = """
        You are the Frontend Developer of ForgeSquad. You implement user interfaces
        with modern frameworks. You focus on responsive design, accessibility (WCAG 2.1),
        performance, and component reusability. You write component and E2E tests.
        Technologies: React / Next.js, TypeScript, Tailwind CSS, Storybook.
        """;

    private const string BAPrompt = """
        You are the Business Analyst of ForgeSquad. You elicit and document requirements,
        create user stories with acceptance criteria in Gherkin format, identify bounded
        contexts using DDD, and maintain the product backlog. You ensure business needs
        are clearly translated into technical requirements.
        """;

    private const string QAPrompt = """
        You are the QA Engineer of ForgeSquad. You design test strategies, write test
        plans, create automated tests, and track quality metrics. You cover functional,
        non-functional, regression, and performance testing. You define acceptance criteria
        with edge cases and error scenarios. Target: >80% code coverage.
        """;

    private const string TechWriterPrompt = """
        You are the Tech Writer of ForgeSquad. You create API documentation, runbooks,
        Architecture Decision Records (ADRs), operational guides, and onboarding materials.
        You follow the Docs-as-Code approach and ensure documentation is accurate,
        up-to-date, and accessible.
        """;

    private const string PMPrompt = """
        You are the Project Manager of ForgeSquad. You track progress, manage risks,
        generate status reports, and facilitate retrospectives. You produce stakeholder
        maps, Gantt charts, burndown charts, and KPI dashboards. You ensure the project
        stays on track and stakeholders are informed.
        """;
}

// --- Pipeline Definition Models ---

public sealed class PipelineDefinition
{
    public string Name { get; set; } = string.Empty;
    public string Version { get; set; } = "1.0";
    public List<PhaseDefinition> Phases { get; set; } = [];
}

public sealed class PhaseDefinition
{
    public int Number { get; set; }
    public string Name { get; set; } = string.Empty;
    public string[] Agents { get; set; } = [];
    public List<StepDefinition> Steps { get; set; } = [];
    public CheckpointDefinition? Checkpoint { get; set; }
}

public sealed class StepDefinition
{
    public string Name { get; set; } = string.Empty;
    public string PrimaryAgent { get; set; } = string.Empty;
    public string[]? SecondaryAgents { get; set; }
    public string Description { get; set; } = string.Empty;
    public string? ExpectedOutput { get; set; }
    public string[]? RequiredContext { get; set; }
    public int MaxIterations { get; set; } = 6;
}

public sealed class CheckpointDefinition
{
    public bool Enabled { get; set; } = true;
    public int Number { get; set; }
    public List<string>? Approvers { get; set; }
    public int TimeoutMinutes { get; set; } = 1440; // 24 hours
}
