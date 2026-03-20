using System.Net.Http.Json;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using System.Text.Json.Serialization;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;

namespace ForgeSquad.Core.Pipeline;

/// <summary>
/// Manages human-in-the-loop approval gates for pipeline checkpoints.
/// Supports two modes:
/// 1. Microsoft Teams Approvals (production) — sends Adaptive Card, waits for response
/// 2. Console/API mode (development) — waits for input via console or REST API
/// </summary>
public sealed class ApprovalGate
{
    private readonly HttpClient _httpClient;
    private readonly ApprovalGateOptions _options;
    private readonly ILogger<ApprovalGate> _logger;

    public ApprovalGate(
        HttpClient httpClient,
        IOptions<ApprovalGateOptions> options,
        ILogger<ApprovalGate> logger)
    {
        _httpClient = httpClient ?? throw new ArgumentNullException(nameof(httpClient));
        _options = options?.Value ?? throw new ArgumentNullException(nameof(options));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
    }

    /// <summary>
    /// Requests approval from designated approvers and waits for a decision.
    /// </summary>
    public async Task<ApprovalResult> RequestApprovalAsync(
        ApprovalRequest request,
        CancellationToken cancellationToken = default)
    {
        _logger.LogInformation(
            "Requesting approval for checkpoint {CP} (phase: {Phase}, run: {Run})",
            request.CheckpointNumber, request.PhaseName, request.RunId);

        // Validate artifact integrity
        var computedHash = ComputeSha256(request.ArtifactSummary);
        if (!string.Equals(computedHash, request.ArtifactHash, StringComparison.OrdinalIgnoreCase))
        {
            _logger.LogError("Artifact hash mismatch at checkpoint {CP}. Expected: {Expected}, Got: {Got}",
                request.CheckpointNumber, request.ArtifactHash, computedHash);

            return new ApprovalResult
            {
                Decision = ApprovalDecision.Rejected,
                DecidedBy = "System",
                Comments = "SECURITY: Artifact hash mismatch detected. Artifacts may have been tampered with.",
                DecidedAt = DateTimeOffset.UtcNow,
                ArtifactHash = computedHash
            };
        }

        return _options.Mode switch
        {
            ApprovalMode.Teams => await RequestTeamsApprovalAsync(request, cancellationToken),
            ApprovalMode.Console => await RequestConsoleApprovalAsync(request, cancellationToken),
            ApprovalMode.Api => await RequestApiApprovalAsync(request, cancellationToken),
            ApprovalMode.AutoApprove => CreateAutoApproval(request),
            _ => throw new InvalidOperationException($"Unknown approval mode: {_options.Mode}")
        };
    }

    /// <summary>
    /// Sends an approval request via Microsoft Teams Adaptive Card and waits for response.
    /// Uses the Teams Approvals API via Power Automate webhook.
    /// </summary>
    private async Task<ApprovalResult> RequestTeamsApprovalAsync(
        ApprovalRequest request,
        CancellationToken cancellationToken)
    {
        var adaptiveCard = BuildAdaptiveCard(request);

        // Create approval via Teams webhook (Power Automate)
        var payload = new
        {
            type = "AdaptiveCard",
            title = $"ForgeSquad Checkpoint {request.CheckpointNumber}: {request.PhaseName}",
            assignedTo = string.Join(";", request.Approvers),
            details = request.ArtifactSummary,
            adaptiveCard,
            runId = request.RunId,
            checkpointNumber = request.CheckpointNumber,
            artifactHash = request.ArtifactHash
        };

        _logger.LogInformation("Sending Teams approval request for checkpoint {CP}", request.CheckpointNumber);

        var response = await _httpClient.PostAsJsonAsync(
            _options.TeamsWebhookUrl, payload, cancellationToken);
        response.EnsureSuccessStatusCode();

        // Poll for approval response
        var timeout = TimeSpan.FromMinutes(request.TimeoutMinutes);
        var pollInterval = TimeSpan.FromSeconds(30);
        var deadline = DateTimeOffset.UtcNow + timeout;

        while (DateTimeOffset.UtcNow < deadline)
        {
            cancellationToken.ThrowIfCancellationRequested();

            var statusResponse = await _httpClient.GetAsync(
                $"{_options.ApprovalStatusUrl}?runId={request.RunId}&checkpoint={request.CheckpointNumber}",
                cancellationToken);

            if (statusResponse.IsSuccessStatusCode)
            {
                var status = await statusResponse.Content.ReadFromJsonAsync<ApprovalStatusResponse>(
                    cancellationToken: cancellationToken);

                if (status?.IsCompleted == true)
                {
                    _logger.LogInformation("Checkpoint {CP} decided: {Decision} by {Approver}",
                        request.CheckpointNumber, status.Decision, status.DecidedBy);

                    return new ApprovalResult
                    {
                        Decision = ParseDecision(status.Decision),
                        DecidedBy = status.DecidedBy ?? "Unknown",
                        Comments = status.Comments ?? string.Empty,
                        DecidedAt = DateTimeOffset.UtcNow,
                        ArtifactHash = request.ArtifactHash
                    };
                }
            }

            await Task.Delay(pollInterval, cancellationToken);
        }

        _logger.LogWarning("Checkpoint {CP} timed out after {Minutes} minutes",
            request.CheckpointNumber, request.TimeoutMinutes);

        return new ApprovalResult
        {
            Decision = ApprovalDecision.Rejected,
            DecidedBy = "System (Timeout)",
            Comments = $"Approval timed out after {request.TimeoutMinutes} minutes",
            DecidedAt = DateTimeOffset.UtcNow,
            ArtifactHash = request.ArtifactHash
        };
    }

    /// <summary>
    /// Requests approval via console input (for development/testing).
    /// </summary>
    private async Task<ApprovalResult> RequestConsoleApprovalAsync(
        ApprovalRequest request,
        CancellationToken cancellationToken)
    {
        Console.WriteLine();
        Console.WriteLine("=".PadRight(60, '='));
        Console.WriteLine($"  CHECKPOINT {request.CheckpointNumber}: {request.PhaseName}");
        Console.WriteLine("=".PadRight(60, '='));
        Console.WriteLine();
        Console.WriteLine("Artifact Summary:");
        Console.WriteLine(request.ArtifactSummary[..Math.Min(1000, request.ArtifactSummary.Length)]);
        Console.WriteLine();
        Console.WriteLine($"Artifact Hash (SHA-256): {request.ArtifactHash}");
        Console.WriteLine();
        Console.WriteLine("Decision: [A]pprove / [R]eject / [M]odify");
        Console.Write("> ");

        var input = Console.ReadLine()?.Trim().ToUpperInvariant();
        var decision = input switch
        {
            "A" or "APPROVE" => ApprovalDecision.Approved,
            "R" or "REJECT" => ApprovalDecision.Rejected,
            "M" or "MODIFY" => ApprovalDecision.Modified,
            _ => ApprovalDecision.Approved // Default to approved in dev mode
        };

        Console.Write("Comments (optional): ");
        var comments = Console.ReadLine() ?? string.Empty;

        return new ApprovalResult
        {
            Decision = decision,
            DecidedBy = "Console User",
            Comments = comments,
            DecidedAt = DateTimeOffset.UtcNow,
            ArtifactHash = request.ArtifactHash
        };
    }

    /// <summary>
    /// Requests approval via REST API (for programmatic integration).
    /// Posts the request and polls for response.
    /// </summary>
    private async Task<ApprovalResult> RequestApiApprovalAsync(
        ApprovalRequest request,
        CancellationToken cancellationToken)
    {
        // Post approval request to external API
        var response = await _httpClient.PostAsJsonAsync(
            $"{_options.ApiBaseUrl}/approvals",
            new
            {
                runId = request.RunId,
                checkpointNumber = request.CheckpointNumber,
                phaseName = request.PhaseName,
                artifactSummary = request.ArtifactSummary,
                artifactHash = request.ArtifactHash,
                approvers = request.Approvers,
                timeoutMinutes = request.TimeoutMinutes
            },
            cancellationToken);

        response.EnsureSuccessStatusCode();

        // Poll for decision
        var timeout = TimeSpan.FromMinutes(request.TimeoutMinutes);
        var deadline = DateTimeOffset.UtcNow + timeout;

        while (DateTimeOffset.UtcNow < deadline)
        {
            cancellationToken.ThrowIfCancellationRequested();

            var statusResponse = await _httpClient.GetFromJsonAsync<ApprovalStatusResponse>(
                $"{_options.ApiBaseUrl}/approvals/{request.RunId}/{request.CheckpointNumber}",
                cancellationToken);

            if (statusResponse?.IsCompleted == true)
            {
                return new ApprovalResult
                {
                    Decision = ParseDecision(statusResponse.Decision),
                    DecidedBy = statusResponse.DecidedBy ?? "API User",
                    Comments = statusResponse.Comments ?? string.Empty,
                    DecidedAt = DateTimeOffset.UtcNow,
                    ArtifactHash = request.ArtifactHash
                };
            }

            await Task.Delay(TimeSpan.FromSeconds(10), cancellationToken);
        }

        return new ApprovalResult
        {
            Decision = ApprovalDecision.Rejected,
            DecidedBy = "System (Timeout)",
            Comments = "API approval timed out",
            DecidedAt = DateTimeOffset.UtcNow,
            ArtifactHash = request.ArtifactHash
        };
    }

    /// <summary>
    /// Auto-approves (for testing/CI pipelines).
    /// </summary>
    private static ApprovalResult CreateAutoApproval(ApprovalRequest request)
    {
        return new ApprovalResult
        {
            Decision = ApprovalDecision.Approved,
            DecidedBy = "AutoApprove (Test Mode)",
            Comments = "Automatically approved in test mode",
            DecidedAt = DateTimeOffset.UtcNow,
            ArtifactHash = request.ArtifactHash
        };
    }

    /// <summary>
    /// Builds a Teams Adaptive Card for the approval request.
    /// </summary>
    private static object BuildAdaptiveCard(ApprovalRequest request)
    {
        return new
        {
            type = "AdaptiveCard",
            version = "1.5",
            body = new object[]
            {
                new
                {
                    type = "TextBlock",
                    text = $"ForgeSquad Checkpoint {request.CheckpointNumber}",
                    weight = "Bolder",
                    size = "Large"
                },
                new
                {
                    type = "TextBlock",
                    text = $"Phase: {request.PhaseName}",
                    weight = "Bolder"
                },
                new
                {
                    type = "TextBlock",
                    text = $"Run ID: {request.RunId}",
                    isSubtle = true
                },
                new
                {
                    type = "TextBlock",
                    text = "Artifact Summary:",
                    weight = "Bolder",
                    separator = true
                },
                new
                {
                    type = "TextBlock",
                    text = request.ArtifactSummary.Length > 500
                        ? request.ArtifactSummary[..500] + "..."
                        : request.ArtifactSummary,
                    wrap = true
                },
                new
                {
                    type = "FactSet",
                    facts = new[]
                    {
                        new { title = "Artifact Hash", value = request.ArtifactHash[..16] + "..." },
                        new { title = "Timeout", value = $"{request.TimeoutMinutes} minutes" }
                    }
                }
            },
            actions = new object[]
            {
                new
                {
                    type = "Action.Submit",
                    title = "Approve",
                    style = "positive",
                    data = new { decision = "Approved", checkpointNumber = request.CheckpointNumber }
                },
                new
                {
                    type = "Action.Submit",
                    title = "Reject",
                    style = "destructive",
                    data = new { decision = "Rejected", checkpointNumber = request.CheckpointNumber }
                },
                new
                {
                    type = "Action.Submit",
                    title = "Request Changes",
                    data = new { decision = "Modified", checkpointNumber = request.CheckpointNumber }
                }
            }
        };
    }

    private static string ComputeSha256(string content)
    {
        var bytes = SHA256.HashData(Encoding.UTF8.GetBytes(content));
        return Convert.ToHexString(bytes).ToLowerInvariant();
    }

    private static ApprovalDecision ParseDecision(string? decision)
    {
        return decision?.ToLowerInvariant() switch
        {
            "approved" or "approve" => ApprovalDecision.Approved,
            "rejected" or "reject" => ApprovalDecision.Rejected,
            "modified" or "modify" or "request changes" => ApprovalDecision.Modified,
            _ => ApprovalDecision.Rejected
        };
    }
}

// --- Data models ---

public sealed class ApprovalRequest
{
    public required string RunId { get; init; }
    public required int CheckpointNumber { get; init; }
    public required string PhaseName { get; init; }
    public required string ArtifactSummary { get; init; }
    public required string ArtifactHash { get; init; }
    public required List<string> Approvers { get; init; }
    public int TimeoutMinutes { get; init; } = 1440; // 24 hours default
}

public sealed class ApprovalResult
{
    public ApprovalDecision Decision { get; init; }
    public string DecidedBy { get; init; } = string.Empty;
    public string Comments { get; init; } = string.Empty;
    public DateTimeOffset DecidedAt { get; init; }
    public string ArtifactHash { get; init; } = string.Empty;
}

public sealed class ApprovalStatusResponse
{
    [JsonPropertyName("isCompleted")]
    public bool IsCompleted { get; set; }

    [JsonPropertyName("decision")]
    public string? Decision { get; set; }

    [JsonPropertyName("decidedBy")]
    public string? DecidedBy { get; set; }

    [JsonPropertyName("comments")]
    public string? Comments { get; set; }
}

public sealed class ApprovalGateOptions
{
    public ApprovalMode Mode { get; set; } = ApprovalMode.Console;
    public string? TeamsWebhookUrl { get; set; }
    public string? ApprovalStatusUrl { get; set; }
    public string? ApiBaseUrl { get; set; }
}

public enum ApprovalMode
{
    Teams,
    Console,
    Api,
    AutoApprove
}

public enum ApprovalDecision
{
    Approved,
    Rejected,
    Modified
}
