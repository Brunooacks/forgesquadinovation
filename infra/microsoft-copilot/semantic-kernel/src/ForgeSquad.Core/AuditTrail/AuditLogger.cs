using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using System.Text.Json.Serialization;
using Microsoft.Azure.Cosmos;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;

namespace ForgeSquad.Core.AuditTrail;

/// <summary>
/// Append-only audit logger using Event Sourcing pattern.
/// Stores all pipeline events in Azure Cosmos DB with SHA-256
/// integrity hashing. Each event's hash includes the previous
/// event's hash, forming an immutable chain.
/// </summary>
public sealed class AuditLogger : IAsyncDisposable
{
    private readonly CosmosClient _cosmosClient;
    private readonly Container _container;
    private readonly ILogger<AuditLogger> _logger;
    private string _lastEventHash = "genesis";

    public AuditLogger(
        IOptions<AuditLoggerOptions> options,
        ILogger<AuditLogger> logger)
    {
        var opts = options?.Value ?? throw new ArgumentNullException(nameof(options));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));

        _cosmosClient = new CosmosClient(opts.CosmosEndpoint, opts.CosmosKey,
            new CosmosClientOptions
            {
                SerializerOptions = new CosmosSerializationOptions
                {
                    PropertyNamingPolicy = CosmosPropertyNamingPolicy.CamelCase
                }
            });

        _container = _cosmosClient.GetContainer(opts.DatabaseName, opts.ContainerName);
    }

    /// <summary>
    /// Logs an audit event to Cosmos DB with integrity hashing.
    /// Events are append-only and form a hash chain.
    /// </summary>
    public async Task LogAsync(AuditEvent auditEvent)
    {
        // Compute event hash including previous hash for chain integrity
        auditEvent.PreviousEventHash = _lastEventHash;
        auditEvent.EventHash = ComputeEventHash(auditEvent);
        auditEvent.Id = Guid.NewGuid().ToString();

        try
        {
            await _container.CreateItemAsync(
                auditEvent,
                new PartitionKey(auditEvent.RunId));

            _lastEventHash = auditEvent.EventHash;

            _logger.LogDebug(
                "Audit event logged: {EventType} for run {RunId}, phase {Phase}",
                auditEvent.EventType, auditEvent.RunId, auditEvent.Phase);
        }
        catch (CosmosException ex)
        {
            _logger.LogError(ex,
                "Failed to log audit event {EventType} for run {RunId}",
                auditEvent.EventType, auditEvent.RunId);

            // Audit logging failure should not block pipeline execution.
            // In production, consider a dead-letter queue for failed events.
        }
    }

    /// <summary>
    /// Retrieves the full audit trail for a pipeline run.
    /// </summary>
    public async Task<List<AuditEvent>> GetAuditTrailAsync(string runId)
    {
        var query = new QueryDefinition(
            "SELECT * FROM c WHERE c.runId = @runId ORDER BY c.timestamp ASC")
            .WithParameter("@runId", runId);

        var events = new List<AuditEvent>();

        using var iterator = _container.GetItemQueryIterator<AuditEvent>(query);
        while (iterator.HasMoreResults)
        {
            var response = await iterator.ReadNextAsync();
            events.AddRange(response);
        }

        return events;
    }

    /// <summary>
    /// Verifies the integrity of an audit trail by checking the hash chain.
    /// Returns true if all hashes are valid and the chain is unbroken.
    /// </summary>
    public async Task<AuditIntegrityResult> VerifyIntegrityAsync(string runId)
    {
        var events = await GetAuditTrailAsync(runId);

        if (events.Count == 0)
        {
            return new AuditIntegrityResult
            {
                IsValid = false,
                Message = "No events found for this run"
            };
        }

        var expectedPreviousHash = "genesis";
        var invalidEvents = new List<string>();

        foreach (var evt in events)
        {
            // Verify previous hash chain
            if (evt.PreviousEventHash != expectedPreviousHash)
            {
                invalidEvents.Add(
                    $"Event {evt.Id}: previous hash mismatch (expected {expectedPreviousHash[..8]}..., got {evt.PreviousEventHash?[..8]}...)");
            }

            // Verify event hash
            var computedHash = ComputeEventHash(evt);
            if (evt.EventHash != computedHash)
            {
                invalidEvents.Add(
                    $"Event {evt.Id}: event hash mismatch (stored {evt.EventHash?[..8]}..., computed {computedHash[..8]}...)");
            }

            expectedPreviousHash = evt.EventHash ?? string.Empty;
        }

        return new AuditIntegrityResult
        {
            IsValid = invalidEvents.Count == 0,
            TotalEvents = events.Count,
            InvalidEvents = invalidEvents,
            Message = invalidEvents.Count == 0
                ? "Audit trail integrity verified — all hashes valid"
                : $"Audit trail COMPROMISED — {invalidEvents.Count} invalid events detected"
        };
    }

    /// <summary>
    /// Gets a summary of audit events by type for a run.
    /// Useful for generating status reports.
    /// </summary>
    public async Task<Dictionary<string, int>> GetEventSummaryAsync(string runId)
    {
        var query = new QueryDefinition(
            "SELECT c.eventType, COUNT(1) as count FROM c WHERE c.runId = @runId GROUP BY c.eventType")
            .WithParameter("@runId", runId);

        var summary = new Dictionary<string, int>();

        using var iterator = _container.GetItemQueryIterator<JsonElement>(query);
        while (iterator.HasMoreResults)
        {
            var response = await iterator.ReadNextAsync();
            foreach (var item in response)
            {
                var eventType = item.GetProperty("eventType").GetString() ?? "unknown";
                var count = item.GetProperty("count").GetInt32();
                summary[eventType] = count;
            }
        }

        return summary;
    }

    /// <summary>
    /// Computes SHA-256 hash of an audit event, including the previous event's hash
    /// to form an immutable chain (similar to blockchain).
    /// </summary>
    private static string ComputeEventHash(AuditEvent evt)
    {
        var content = $"{evt.RunId}|{evt.EventType}|{evt.Phase}|{evt.Agent}|" +
                      $"{evt.Message}|{evt.Timestamp:O}|{evt.ArtifactHash}|" +
                      $"{evt.TokensUsed}|{evt.PreviousEventHash}";

        var bytes = SHA256.HashData(Encoding.UTF8.GetBytes(content));
        return Convert.ToHexString(bytes).ToLowerInvariant();
    }

    /// <summary>
    /// Initializes the Cosmos DB database and container if they don't exist.
    /// Called once at application startup.
    /// </summary>
    public async Task InitializeAsync(AuditLoggerOptions options)
    {
        var database = await _cosmosClient.CreateDatabaseIfNotExistsAsync(options.DatabaseName);
        await database.Database.CreateContainerIfNotExistsAsync(
            new ContainerProperties
            {
                Id = options.ContainerName,
                PartitionKeyPath = "/runId",
                DefaultTimeToLive = options.RetentionDays > 0
                    ? options.RetentionDays * 86400  // Convert days to seconds
                    : -1 // No expiration
            });

        _logger.LogInformation("Audit trail Cosmos DB initialized: {Database}/{Container}",
            options.DatabaseName, options.ContainerName);
    }

    public async ValueTask DisposeAsync()
    {
        _cosmosClient.Dispose();
    }
}

// --- Data Models ---

/// <summary>
/// Represents a single audit event in the pipeline execution.
/// Events are append-only and hash-chained for integrity.
/// </summary>
public sealed class AuditEvent
{
    [JsonPropertyName("id")]
    public string Id { get; set; } = Guid.NewGuid().ToString();

    [JsonPropertyName("runId")]
    public required string RunId { get; set; }

    [JsonPropertyName("eventType")]
    public required string EventType { get; set; }

    [JsonPropertyName("phase")]
    public required string Phase { get; set; }

    [JsonPropertyName("agent")]
    public required string Agent { get; set; }

    [JsonPropertyName("message")]
    public required string Message { get; set; }

    [JsonPropertyName("timestamp")]
    public required DateTimeOffset Timestamp { get; set; }

    [JsonPropertyName("data")]
    public string? Data { get; set; }

    [JsonPropertyName("artifactHash")]
    public string? ArtifactHash { get; set; }

    [JsonPropertyName("tokensUsed")]
    public int TokensUsed { get; set; }

    [JsonPropertyName("eventHash")]
    public string? EventHash { get; set; }

    [JsonPropertyName("previousEventHash")]
    public string? PreviousEventHash { get; set; }
}

/// <summary>
/// Result of an audit trail integrity verification.
/// </summary>
public sealed class AuditIntegrityResult
{
    public bool IsValid { get; set; }
    public int TotalEvents { get; set; }
    public List<string> InvalidEvents { get; set; } = [];
    public string Message { get; set; } = string.Empty;
}

/// <summary>
/// Configuration options for the Audit Logger.
/// </summary>
public sealed class AuditLoggerOptions
{
    public string CosmosEndpoint { get; set; } = string.Empty;
    public string CosmosKey { get; set; } = string.Empty;
    public string DatabaseName { get; set; } = "forgesquad";
    public string ContainerName { get; set; } = "audit-events";
    public int RetentionDays { get; set; } = 365; // 1 year default retention
}
