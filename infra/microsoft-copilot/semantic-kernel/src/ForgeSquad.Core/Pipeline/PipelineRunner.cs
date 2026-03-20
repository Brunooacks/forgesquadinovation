using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using Microsoft.Extensions.Logging;
using Microsoft.SemanticKernel;
using Microsoft.SemanticKernel.Agents;
using Microsoft.SemanticKernel.Agents.Chat;
using Microsoft.SemanticKernel.ChatCompletion;
using ForgeSquad.Core.AuditTrail;

namespace ForgeSquad.Core.Pipeline;

/// <summary>
/// Orchestrates the ForgeSquad pipeline through 10 phases, 24 steps,
/// and 9 human checkpoints. Each phase activates specific agents,
/// executes steps sequentially, and optionally pauses for human approval.
/// </summary>
public sealed class PipelineRunner
{
    private readonly Dictionary<string, ChatCompletionAgent> _agents;
    private readonly ApprovalGate _approvalGate;
    private readonly AuditLogger _auditLogger;
    private readonly ILogger<PipelineRunner> _logger;

    public PipelineRunner(
        Dictionary<string, ChatCompletionAgent> agents,
        ApprovalGate approvalGate,
        AuditLogger auditLogger,
        ILogger<PipelineRunner> logger)
    {
        _agents = agents ?? throw new ArgumentNullException(nameof(agents));
        _approvalGate = approvalGate ?? throw new ArgumentNullException(nameof(approvalGate));
        _auditLogger = auditLogger ?? throw new ArgumentNullException(nameof(auditLogger));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
    }

    /// <summary>
    /// Executes the full pipeline for a given squad configuration.
    /// </summary>
    public async Task<PipelineResult> ExecuteAsync(
        PipelineDefinition pipeline,
        PipelineContext context,
        CancellationToken cancellationToken = default)
    {
        var runId = Guid.NewGuid().ToString();
        var result = new PipelineResult
        {
            RunId = runId,
            SquadName = context.SquadName,
            ProjectName = context.ProjectName,
            StartedAt = DateTimeOffset.UtcNow,
            Status = PipelineStatus.Running
        };

        await _auditLogger.LogAsync(new AuditEvent
        {
            RunId = runId,
            EventType = "PipelineStarted",
            Phase = "N/A",
            Agent = "PipelineRunner",
            Message = $"Pipeline started for squad '{context.SquadName}', project '{context.ProjectName}'",
            Timestamp = DateTimeOffset.UtcNow,
            Data = JsonSerializer.Serialize(context)
        });

        _logger.LogInformation("Pipeline {RunId} started for squad {Squad}, project {Project}",
            runId, context.SquadName, context.ProjectName);

        try
        {
            // Accumulate context across phases (output of one phase feeds into the next)
            var accumulatedContext = new Dictionary<string, string>
            {
                ["ProjectName"] = context.ProjectName,
                ["ProjectDescription"] = context.ProjectDescription
            };

            foreach (var phase in pipeline.Phases)
            {
                if (context.SkipPhases?.Contains(phase.Number) == true)
                {
                    _logger.LogInformation("Skipping phase {Phase} as configured", phase.Name);
                    continue;
                }

                var phaseResult = await ExecutePhaseAsync(
                    runId, phase, accumulatedContext, context, cancellationToken);

                result.PhaseResults.Add(phaseResult);

                if (phaseResult.Status == PhaseStatus.Rejected)
                {
                    _logger.LogWarning("Pipeline paused at phase {Phase} — checkpoint rejected", phase.Name);
                    result.Status = PipelineStatus.Paused;
                    result.PausedAtPhase = phase.Name;
                    result.CompletedAt = DateTimeOffset.UtcNow;

                    await _auditLogger.LogAsync(new AuditEvent
                    {
                        RunId = runId,
                        EventType = "PipelinePaused",
                        Phase = phase.Name,
                        Agent = "PipelineRunner",
                        Message = $"Pipeline paused — checkpoint {phase.Checkpoint?.Number} rejected",
                        Timestamp = DateTimeOffset.UtcNow
                    });

                    return result;
                }

                // Add phase output to accumulated context for next phases
                foreach (var artifact in phaseResult.Artifacts)
                {
                    accumulatedContext[$"{phase.Name}_{artifact.Key}"] = artifact.Value;
                }
            }

            result.Status = PipelineStatus.Completed;
            result.CompletedAt = DateTimeOffset.UtcNow;

            await _auditLogger.LogAsync(new AuditEvent
            {
                RunId = runId,
                EventType = "PipelineCompleted",
                Phase = "N/A",
                Agent = "PipelineRunner",
                Message = "Pipeline completed successfully",
                Timestamp = DateTimeOffset.UtcNow,
                Data = JsonSerializer.Serialize(new
                {
                    TotalPhases = result.PhaseResults.Count,
                    TotalTokens = result.PhaseResults.Sum(p => p.TokensUsed),
                    Duration = result.CompletedAt - result.StartedAt
                })
            });

            _logger.LogInformation("Pipeline {RunId} completed successfully in {Duration}",
                runId, result.CompletedAt - result.StartedAt);
        }
        catch (Exception ex)
        {
            result.Status = PipelineStatus.Failed;
            result.CompletedAt = DateTimeOffset.UtcNow;
            result.ErrorMessage = ex.Message;

            await _auditLogger.LogAsync(new AuditEvent
            {
                RunId = runId,
                EventType = "PipelineFailed",
                Phase = "Unknown",
                Agent = "PipelineRunner",
                Message = $"Pipeline failed: {ex.Message}",
                Timestamp = DateTimeOffset.UtcNow,
                Data = ex.ToString()
            });

            _logger.LogError(ex, "Pipeline {RunId} failed", runId);
            throw;
        }

        return result;
    }

    /// <summary>
    /// Executes a single phase of the pipeline, including all steps and checkpoint.
    /// </summary>
    private async Task<PhaseResult> ExecutePhaseAsync(
        string runId,
        PhaseDefinition phase,
        Dictionary<string, string> accumulatedContext,
        PipelineContext pipelineContext,
        CancellationToken cancellationToken)
    {
        _logger.LogInformation("Starting phase {Phase} ({Number}/10)", phase.Name, phase.Number);

        var phaseResult = new PhaseResult
        {
            PhaseName = phase.Name,
            PhaseNumber = phase.Number,
            StartedAt = DateTimeOffset.UtcNow,
            Status = PhaseStatus.Running
        };

        await _auditLogger.LogAsync(new AuditEvent
        {
            RunId = runId,
            EventType = "PhaseStarted",
            Phase = phase.Name,
            Agent = string.Join(", ", phase.Agents),
            Message = $"Phase {phase.Number}: {phase.Name} started",
            Timestamp = DateTimeOffset.UtcNow
        });

        // Execute each step in the phase
        foreach (var step in phase.Steps)
        {
            var stepResult = await ExecuteStepAsync(
                runId, phase, step, accumulatedContext, cancellationToken);

            phaseResult.StepResults.Add(stepResult);
            phaseResult.TokensUsed += stepResult.TokensUsed;

            // Store step output for subsequent steps
            accumulatedContext[$"{phase.Name}_{step.Name}"] = stepResult.Output;
        }

        // Handle checkpoint if defined
        if (phase.Checkpoint is { Enabled: true })
        {
            _logger.LogInformation("Checkpoint {CP} reached for phase {Phase}",
                phase.Checkpoint.Number, phase.Name);

            var artifactSummary = string.Join("\n",
                phaseResult.StepResults.Select(s => $"- {s.StepName}: {s.Output[..Math.Min(200, s.Output.Length)]}..."));

            var artifactHash = ComputeSha256(artifactSummary);

            await _auditLogger.LogAsync(new AuditEvent
            {
                RunId = runId,
                EventType = "CheckpointRequested",
                Phase = phase.Name,
                Agent = "PipelineRunner",
                Message = $"Checkpoint {phase.Checkpoint.Number} — awaiting approval",
                Timestamp = DateTimeOffset.UtcNow,
                ArtifactHash = artifactHash
            });

            var approvalResult = await _approvalGate.RequestApprovalAsync(
                new ApprovalRequest
                {
                    RunId = runId,
                    CheckpointNumber = phase.Checkpoint.Number,
                    PhaseName = phase.Name,
                    ArtifactSummary = artifactSummary,
                    ArtifactHash = artifactHash,
                    Approvers = phase.Checkpoint.Approvers ??
                                pipelineContext.DefaultApprovers,
                    TimeoutMinutes = phase.Checkpoint.TimeoutMinutes
                },
                cancellationToken);

            phaseResult.ApprovalDecision = approvalResult.Decision;

            await _auditLogger.LogAsync(new AuditEvent
            {
                RunId = runId,
                EventType = "CheckpointDecided",
                Phase = phase.Name,
                Agent = approvalResult.DecidedBy,
                Message = $"Checkpoint {phase.Checkpoint.Number} — {approvalResult.Decision}",
                Timestamp = DateTimeOffset.UtcNow,
                Data = JsonSerializer.Serialize(approvalResult)
            });

            if (approvalResult.Decision == ApprovalDecision.Rejected)
            {
                phaseResult.Status = PhaseStatus.Rejected;
                phaseResult.CompletedAt = DateTimeOffset.UtcNow;
                return phaseResult;
            }
        }

        // Collect artifacts
        foreach (var step in phaseResult.StepResults)
        {
            phaseResult.Artifacts[step.StepName] = step.Output;
        }

        phaseResult.Status = PhaseStatus.Completed;
        phaseResult.CompletedAt = DateTimeOffset.UtcNow;

        _logger.LogInformation("Phase {Phase} completed. Tokens used: {Tokens}",
            phase.Name, phaseResult.TokensUsed);

        return phaseResult;
    }

    /// <summary>
    /// Executes a single step within a phase. If the step requires multiple agents,
    /// creates an AgentGroupChat for collaboration.
    /// </summary>
    private async Task<StepResult> ExecuteStepAsync(
        string runId,
        PhaseDefinition phase,
        StepDefinition step,
        Dictionary<string, string> accumulatedContext,
        CancellationToken cancellationToken)
    {
        _logger.LogInformation("Executing step {Step} (agent: {Agent})", step.Name, step.PrimaryAgent);

        var stepResult = new StepResult
        {
            StepName = step.Name,
            AgentName = step.PrimaryAgent,
            StartedAt = DateTimeOffset.UtcNow
        };

        // Build the prompt with accumulated context
        var contextPrompt = BuildContextPrompt(step, accumulatedContext);

        if (step.SecondaryAgents?.Length > 0)
        {
            // Multi-agent collaboration via AgentGroupChat
            stepResult.Output = await ExecuteMultiAgentStepAsync(
                step, contextPrompt, cancellationToken);
        }
        else
        {
            // Single agent execution
            stepResult.Output = await ExecuteSingleAgentStepAsync(
                step.PrimaryAgent, contextPrompt, cancellationToken);
        }

        stepResult.TokensUsed = EstimateTokens(contextPrompt, stepResult.Output);
        stepResult.OutputHash = ComputeSha256(stepResult.Output);
        stepResult.CompletedAt = DateTimeOffset.UtcNow;

        await _auditLogger.LogAsync(new AuditEvent
        {
            RunId = runId,
            EventType = "StepExecuted",
            Phase = phase.Name,
            Agent = step.PrimaryAgent,
            Message = $"Step '{step.Name}' completed by {step.PrimaryAgent}",
            Timestamp = DateTimeOffset.UtcNow,
            ArtifactHash = stepResult.OutputHash,
            TokensUsed = stepResult.TokensUsed
        });

        return stepResult;
    }

    /// <summary>
    /// Executes a step using a single agent.
    /// </summary>
    private async Task<string> ExecuteSingleAgentStepAsync(
        string agentName,
        string prompt,
        CancellationToken cancellationToken)
    {
        if (!_agents.TryGetValue(agentName, out var agent))
        {
            throw new InvalidOperationException($"Agent '{agentName}' not found in registered agents");
        }

        var chatHistory = new ChatHistory();
        chatHistory.AddUserMessage(prompt);

        var response = new StringBuilder();
        await foreach (var message in agent.InvokeAsync(chatHistory, cancellationToken: cancellationToken))
        {
            response.Append(message.Content);
        }

        return response.ToString();
    }

    /// <summary>
    /// Executes a step using multiple agents in a group chat.
    /// Agents collaborate until the primary agent signals completion.
    /// </summary>
    private async Task<string> ExecuteMultiAgentStepAsync(
        StepDefinition step,
        string prompt,
        CancellationToken cancellationToken)
    {
        var agents = new List<ChatCompletionAgent>();

        // Primary agent first
        if (_agents.TryGetValue(step.PrimaryAgent, out var primaryAgent))
        {
            agents.Add(primaryAgent);
        }

        // Add secondary agents
        foreach (var secondaryName in step.SecondaryAgents!)
        {
            if (_agents.TryGetValue(secondaryName, out var secondaryAgent))
            {
                agents.Add(secondaryAgent);
            }
        }

        if (agents.Count == 0)
        {
            throw new InvalidOperationException("No agents available for multi-agent step");
        }

        var chat = new AgentGroupChat(agents.ToArray())
        {
            ExecutionSettings = new()
            {
                TerminationStrategy = new MaxIterationTerminationStrategy(step.MaxIterations),
                SelectionStrategy = new SequentialSelectionStrategy()
            }
        };

        chat.AddChatMessage(new ChatMessageContent(AuthorRole.User, prompt));

        var output = new StringBuilder();
        await foreach (var message in chat.InvokeAsync(cancellationToken))
        {
            output.AppendLine($"**{message.AuthorName}:** {message.Content}");
            output.AppendLine();
        }

        return output.ToString();
    }

    /// <summary>
    /// Builds a context-rich prompt for the step, including accumulated context from prior phases.
    /// </summary>
    private static string BuildContextPrompt(
        StepDefinition step,
        Dictionary<string, string> accumulatedContext)
    {
        var prompt = new StringBuilder();
        prompt.AppendLine($"## Task: {step.Name}");
        prompt.AppendLine($"**Description:** {step.Description}");
        prompt.AppendLine();

        // Include relevant accumulated context
        if (step.RequiredContext?.Length > 0)
        {
            prompt.AppendLine("## Context from Previous Phases");
            foreach (var contextKey in step.RequiredContext)
            {
                if (accumulatedContext.TryGetValue(contextKey, out var contextValue))
                {
                    prompt.AppendLine($"### {contextKey}");
                    // Truncate very long context to avoid token limits
                    var truncated = contextValue.Length > 3000
                        ? contextValue[..3000] + "\n... (truncated)"
                        : contextValue;
                    prompt.AppendLine(truncated);
                    prompt.AppendLine();
                }
            }
        }

        // Always include project info
        if (accumulatedContext.TryGetValue("ProjectName", out var projectName))
        {
            prompt.AppendLine($"**Project:** {projectName}");
        }
        if (accumulatedContext.TryGetValue("ProjectDescription", out var projectDesc))
        {
            prompt.AppendLine($"**Description:** {projectDesc}");
        }

        prompt.AppendLine();
        prompt.AppendLine("## Expected Output");
        prompt.AppendLine(step.ExpectedOutput ?? "Provide a comprehensive response following your role's guidelines.");

        return prompt.ToString();
    }

    /// <summary>
    /// Computes SHA-256 hash of content for audit trail integrity.
    /// </summary>
    private static string ComputeSha256(string content)
    {
        var bytes = SHA256.HashData(Encoding.UTF8.GetBytes(content));
        return Convert.ToHexString(bytes).ToLowerInvariant();
    }

    /// <summary>
    /// Estimates token count (rough approximation: ~4 chars per token).
    /// </summary>
    private static int EstimateTokens(string input, string output)
    {
        return (input.Length + output.Length) / 4;
    }
}

/// <summary>
/// Termination strategy that stops after N iterations.
/// </summary>
public sealed class MaxIterationTerminationStrategy : TerminationStrategy
{
    private readonly int _maxIterations;
    private int _currentIteration;

    public MaxIterationTerminationStrategy(int maxIterations = 6)
    {
        _maxIterations = maxIterations;
        MaximumIterations = maxIterations;
    }

    protected override Task<bool> ShouldAgentTerminateAsync(
        Agent agent,
        IReadOnlyList<ChatMessageContent> history,
        CancellationToken cancellationToken = default)
    {
        _currentIteration++;
        return Task.FromResult(_currentIteration >= _maxIterations);
    }
}

// --- Data models ---

public sealed class PipelineContext
{
    public required string SquadName { get; init; }
    public required string ProjectName { get; init; }
    public required string ProjectDescription { get; init; }
    public string RequestedBy { get; init; } = "system";
    public List<int>? SkipPhases { get; init; }
    public List<string> DefaultApprovers { get; init; } = [];
}

public sealed class PipelineResult
{
    public string RunId { get; set; } = string.Empty;
    public string SquadName { get; set; } = string.Empty;
    public string ProjectName { get; set; } = string.Empty;
    public PipelineStatus Status { get; set; }
    public string? PausedAtPhase { get; set; }
    public string? ErrorMessage { get; set; }
    public DateTimeOffset StartedAt { get; set; }
    public DateTimeOffset? CompletedAt { get; set; }
    public List<PhaseResult> PhaseResults { get; set; } = [];
}

public sealed class PhaseResult
{
    public string PhaseName { get; set; } = string.Empty;
    public int PhaseNumber { get; set; }
    public PhaseStatus Status { get; set; }
    public ApprovalDecision? ApprovalDecision { get; set; }
    public DateTimeOffset StartedAt { get; set; }
    public DateTimeOffset? CompletedAt { get; set; }
    public int TokensUsed { get; set; }
    public List<StepResult> StepResults { get; set; } = [];
    public Dictionary<string, string> Artifacts { get; set; } = [];
}

public sealed class StepResult
{
    public string StepName { get; set; } = string.Empty;
    public string AgentName { get; set; } = string.Empty;
    public string Output { get; set; } = string.Empty;
    public string OutputHash { get; set; } = string.Empty;
    public int TokensUsed { get; set; }
    public DateTimeOffset StartedAt { get; set; }
    public DateTimeOffset? CompletedAt { get; set; }
}

public enum PipelineStatus
{
    NotStarted,
    Running,
    Paused,
    Completed,
    Failed
}

public enum PhaseStatus
{
    Pending,
    Running,
    Completed,
    Rejected,
    Failed
}
