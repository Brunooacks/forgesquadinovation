using System.ComponentModel;
using System.Net.Http.Json;
using System.Text.Json;
using System.Text.Json.Serialization;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Microsoft.SemanticKernel;

namespace ForgeSquad.Core.Skills;

/// <summary>
/// Semantic Kernel plugin that integrates with Devin AI for autonomous coding tasks.
/// Used by Dev Backend and Dev Frontend agents to delegate implementation work.
///
/// Devin API: https://api.devin.ai/v1/
/// This plugin provides a standardized interface for:
/// - Creating coding sessions
/// - Submitting tasks (bug fixes, feature implementation, refactoring)
/// - Monitoring task progress
/// - Retrieving generated code and artifacts
/// </summary>
public sealed class DevinSkill
{
    private readonly HttpClient _httpClient;
    private readonly DevinOptions _options;
    private readonly ILogger<DevinSkill> _logger;

    public DevinSkill(
        HttpClient httpClient,
        IOptions<DevinOptions> options,
        ILogger<DevinSkill> logger)
    {
        _httpClient = httpClient;
        _options = options.Value;
        _logger = logger;

        _httpClient.BaseAddress = new Uri(_options.BaseUrl);
        _httpClient.DefaultRequestHeaders.Add("Authorization", $"Bearer {_options.ApiKey}");
        _httpClient.DefaultRequestHeaders.Add("Accept", "application/json");
    }

    [KernelFunction("create_devin_session")]
    [Description("Creates a new Devin AI coding session for a specific task. Returns a session ID for tracking.")]
    public async Task<string> CreateSession(
        [Description("Name of the coding session")] string sessionName,
        [Description("Repository URL (GitHub) to work on")] string repositoryUrl,
        [Description("Branch to work on (default: main)")] string branch = "main")
    {
        _logger.LogInformation("Creating Devin session: {Name} for repo: {Repo}", sessionName, repositoryUrl);

        var request = new
        {
            name = sessionName,
            repository = repositoryUrl,
            branch,
            settings = new
            {
                auto_commit = false, // We review before committing
                max_duration_minutes = _options.MaxSessionDurationMinutes,
                language_preferences = _options.PreferredLanguages
            }
        };

        var response = await _httpClient.PostAsJsonAsync("/v1/sessions", request);
        response.EnsureSuccessStatusCode();

        var result = await response.Content.ReadFromJsonAsync<DevinSessionResponse>();

        return $"""
            ## Devin Session Created
            - **Session ID:** {result?.SessionId}
            - **Name:** {sessionName}
            - **Repository:** {repositoryUrl}
            - **Branch:** {branch}
            - **Status:** {result?.Status}
            - **URL:** {result?.DashboardUrl}

            Session is ready. Use `execute_coding_task` to submit work.
            """;
    }

    [KernelFunction("execute_coding_task")]
    [Description("Submits a coding task to Devin AI for autonomous execution. Devin will write code, run tests, and prepare a PR.")]
    public async Task<string> ExecuteCodingTask(
        [Description("Detailed description of the coding task")] string taskDescription,
        [Description("Programming language (csharp, python, typescript, java)")] string language,
        [Description("Task type: feature, bugfix, refactor, test, documentation")] string taskType = "feature",
        [Description("Acceptance criteria for the task")] string? acceptanceCriteria = null,
        [Description("Existing session ID (optional, creates new if not provided)")] string? sessionId = null)
    {
        _logger.LogInformation("Submitting coding task to Devin: {Type} in {Language}", taskType, language);

        var request = new
        {
            session_id = sessionId,
            task = new
            {
                description = taskDescription,
                type = taskType,
                language,
                acceptance_criteria = acceptanceCriteria,
                constraints = new
                {
                    follow_solid_principles = true,
                    include_unit_tests = true,
                    include_documentation = true,
                    max_file_changes = 20,
                    code_style = _options.CodeStyle
                }
            }
        };

        var response = await _httpClient.PostAsJsonAsync("/v1/tasks", request);
        response.EnsureSuccessStatusCode();

        var result = await response.Content.ReadFromJsonAsync<DevinTaskResponse>();

        return $"""
            ## Devin Task Submitted
            - **Task ID:** {result?.TaskId}
            - **Type:** {taskType}
            - **Language:** {language}
            - **Status:** {result?.Status}
            - **Estimated Duration:** {result?.EstimatedMinutes} minutes

            ### Task Description
            {taskDescription}

            ### Acceptance Criteria
            {acceptanceCriteria ?? "As defined in task description"}

            Use `check_task_status` with Task ID to monitor progress.
            """;
    }

    [KernelFunction("check_task_status")]
    [Description("Checks the status of a Devin AI coding task")]
    public async Task<string> CheckTaskStatus(
        [Description("Task ID returned by execute_coding_task")] string taskId)
    {
        _logger.LogInformation("Checking Devin task status: {TaskId}", taskId);

        var response = await _httpClient.GetAsync($"/v1/tasks/{taskId}");
        response.EnsureSuccessStatusCode();

        var result = await response.Content.ReadFromJsonAsync<DevinTaskStatusResponse>();

        var output = $"""
            ## Devin Task Status
            - **Task ID:** {taskId}
            - **Status:** {result?.Status}
            - **Progress:** {result?.ProgressPercent}%
            - **Files Changed:** {result?.FilesChanged}
            - **Tests Passing:** {result?.TestsPassing}/{result?.TestsTotal}
            """;

        if (result?.Status == "completed")
        {
            output += $"""

                ### Completed
                - **PR URL:** {result.PullRequestUrl}
                - **Files Modified:** {result.FilesChanged}
                - **Lines Added:** {result.LinesAdded}
                - **Lines Removed:** {result.LinesRemoved}
                - **Tests Added:** {result.TestsAdded}

                ### Generated Files
                {string.Join("\n", result.GeneratedFiles?.Select(f => $"- `{f}`") ?? [])}
                """;
        }

        return output;
    }

    [KernelFunction("get_task_code")]
    [Description("Retrieves the code generated by a completed Devin task")]
    public async Task<string> GetTaskCode(
        [Description("Task ID of a completed task")] string taskId,
        [Description("Specific file path to retrieve (optional, returns all if empty)")] string? filePath = null)
    {
        _logger.LogInformation("Retrieving code from Devin task: {TaskId}", taskId);

        var url = string.IsNullOrEmpty(filePath)
            ? $"/v1/tasks/{taskId}/code"
            : $"/v1/tasks/{taskId}/code?file={Uri.EscapeDataString(filePath)}";

        var response = await _httpClient.GetAsync(url);
        response.EnsureSuccessStatusCode();

        var result = await response.Content.ReadFromJsonAsync<DevinCodeResponse>();

        var output = $"## Code from Devin Task {taskId}\n\n";

        if (result?.Files != null)
        {
            foreach (var file in result.Files)
            {
                output += $"### `{file.Path}`\n```{file.Language}\n{file.Content}\n```\n\n";
            }
        }

        return output;
    }

    [KernelFunction("review_devin_output")]
    [Description("Reviews Devin's code output against quality standards and provides feedback")]
    public async Task<string> ReviewDevinOutput(
        [Description("Task ID to review")] string taskId,
        [Description("Quality criteria to check against")] string qualityCriteria = "SOLID principles, test coverage, documentation, error handling")
    {
        // First get the code
        var code = await GetTaskCode(taskId);

        return $"""
            ## Code Review Request for Devin Task {taskId}

            ### Quality Criteria
            {qualityCriteria}

            ### Review Checklist
            - [ ] Follows SOLID principles
            - [ ] Adequate test coverage (>80%)
            - [ ] Error handling implemented
            - [ ] Documentation/comments present
            - [ ] No security vulnerabilities
            - [ ] Follows project coding standards
            - [ ] No hardcoded credentials or secrets
            - [ ] Performance considerations addressed
            - [ ] Logging implemented appropriately

            ### Code to Review
            {code[..Math.Min(3000, code.Length)]}

            *The reviewing agent (Tech Lead or Architect) will provide detailed feedback.*
            """;
    }
}

// --- Configuration ---

public sealed class DevinOptions
{
    public string BaseUrl { get; set; } = "https://api.devin.ai";
    public string ApiKey { get; set; } = string.Empty;
    public int MaxSessionDurationMinutes { get; set; } = 120;
    public string[] PreferredLanguages { get; set; } = ["csharp", "typescript"];
    public string CodeStyle { get; set; } = "microsoft"; // Coding style guide
}

// --- API Response Models ---

public sealed class DevinSessionResponse
{
    [JsonPropertyName("session_id")]
    public string? SessionId { get; set; }

    [JsonPropertyName("status")]
    public string? Status { get; set; }

    [JsonPropertyName("dashboard_url")]
    public string? DashboardUrl { get; set; }
}

public sealed class DevinTaskResponse
{
    [JsonPropertyName("task_id")]
    public string? TaskId { get; set; }

    [JsonPropertyName("status")]
    public string? Status { get; set; }

    [JsonPropertyName("estimated_minutes")]
    public int EstimatedMinutes { get; set; }
}

public sealed class DevinTaskStatusResponse
{
    [JsonPropertyName("status")]
    public string? Status { get; set; }

    [JsonPropertyName("progress_percent")]
    public int ProgressPercent { get; set; }

    [JsonPropertyName("files_changed")]
    public int FilesChanged { get; set; }

    [JsonPropertyName("tests_passing")]
    public int TestsPassing { get; set; }

    [JsonPropertyName("tests_total")]
    public int TestsTotal { get; set; }

    [JsonPropertyName("pull_request_url")]
    public string? PullRequestUrl { get; set; }

    [JsonPropertyName("lines_added")]
    public int LinesAdded { get; set; }

    [JsonPropertyName("lines_removed")]
    public int LinesRemoved { get; set; }

    [JsonPropertyName("tests_added")]
    public int TestsAdded { get; set; }

    [JsonPropertyName("generated_files")]
    public List<string>? GeneratedFiles { get; set; }
}

public sealed class DevinCodeResponse
{
    [JsonPropertyName("files")]
    public List<DevinCodeFile>? Files { get; set; }
}

public sealed class DevinCodeFile
{
    [JsonPropertyName("path")]
    public string Path { get; set; } = string.Empty;

    [JsonPropertyName("content")]
    public string Content { get; set; } = string.Empty;

    [JsonPropertyName("language")]
    public string Language { get; set; } = string.Empty;
}
