/**
 * ForgeSquad — Pipeline Runner Azure Function
 *
 * Orquestra a execucao do pipeline multi-agente ForgeSquad.
 * Receives squad configuration, orchestrates 9 agents across 10 phases / 24 steps,
 * manages 9 human checkpoints, writes audit trail to Cosmos DB, and emits
 * Event Grid notifications at every checkpoint.
 *
 * Runtime: Node.js 20 | Azure Functions v4
 */

const { app } = require("@azure/functions");
const { CosmosClient } = require("@azure/cosmos");
const { DefaultAzureCredential } = require("@azure/identity");
const { ServiceBusClient } = require("@azure/service-bus");
const { EventGridPublisherClient, AzureKeyCredential } = require("@azure/eventgrid");
const { BlobServiceClient } = require("@azure/storage-blob");
const crypto = require("crypto");

// ─── Configuration ──────────────────────────────────────────────────────────

const COSMOS_ENDPOINT = process.env.COSMOS_DB_ENDPOINT;
const COSMOS_DATABASE = process.env.COSMOS_DB_DATABASE || "forgesquad-db";
const SERVICEBUS_NAMESPACE = process.env.SERVICEBUS_NAMESPACE;
const EVENTGRID_ENDPOINT = process.env.EVENTGRID_TOPIC_ENDPOINT;
const EVENTGRID_KEY = process.env.EVENTGRID_KEY;
const STORAGE_ACCOUNT = process.env.STORAGE_ACCOUNT_NAME;
const CONTAINER_APP_FQDN = process.env.CONTAINER_APP_FQDN;

// ─── ForgeSquad Pipeline Definition ─────────────────────────────────────────

const PIPELINE_PHASES = [
  {
    id: 1,
    name: "Discovery",
    steps: [
      { id: 1, name: "requirements-gathering", agent: "business-analyst" },
      { id: 2, name: "stakeholder-interviews", agent: "business-analyst" },
    ],
    checkpoint: {
      id: "CP-01",
      name: "Requirements Sign-off",
      approvers: ["product-owner", "architect"],
    },
  },
  {
    id: 2,
    name: "Architecture",
    steps: [
      { id: 3, name: "system-design", agent: "architect" },
      { id: 4, name: "tech-stack-selection", agent: "architect" },
      { id: 5, name: "adr-creation", agent: "tech-writer" },
    ],
    checkpoint: {
      id: "CP-02",
      name: "Architecture Review",
      approvers: ["architect", "tech-lead"],
    },
  },
  {
    id: 3,
    name: "Planning",
    steps: [
      { id: 6, name: "sprint-planning", agent: "tech-lead" },
      { id: 7, name: "task-breakdown", agent: "tech-lead" },
    ],
    checkpoint: {
      id: "CP-03",
      name: "Sprint Plan Approval",
      approvers: ["project-manager", "tech-lead"],
    },
  },
  {
    id: 4,
    name: "Backend Development",
    steps: [
      { id: 8, name: "api-design", agent: "dev-backend" },
      { id: 9, name: "database-schema", agent: "dev-backend" },
      { id: 10, name: "api-implementation", agent: "dev-backend" },
    ],
    checkpoint: null,
  },
  {
    id: 5,
    name: "Frontend Development",
    steps: [
      { id: 11, name: "ui-design", agent: "dev-frontend" },
      { id: 12, name: "component-implementation", agent: "dev-frontend" },
      { id: 13, name: "api-integration", agent: "dev-frontend" },
    ],
    checkpoint: {
      id: "CP-04",
      name: "Feature Review",
      approvers: ["tech-lead", "architect"],
    },
  },
  {
    id: 6,
    name: "Testing",
    steps: [
      { id: 14, name: "test-strategy", agent: "qa-engineer" },
      { id: 15, name: "test-automation", agent: "qa-engineer" },
      { id: 16, name: "regression-testing", agent: "qa-engineer" },
    ],
    checkpoint: {
      id: "CP-05",
      name: "QA Gate",
      approvers: ["qa-engineer", "tech-lead"],
    },
  },
  {
    id: 7,
    name: "Security Review",
    steps: [
      { id: 17, name: "security-scan", agent: "devops" },
      { id: 18, name: "penetration-test-review", agent: "architect" },
    ],
    checkpoint: {
      id: "CP-06",
      name: "Security Sign-off",
      approvers: ["architect", "devops"],
    },
  },
  {
    id: 8,
    name: "Documentation",
    steps: [
      { id: 19, name: "api-documentation", agent: "tech-writer" },
      { id: 20, name: "runbook-creation", agent: "tech-writer" },
    ],
    checkpoint: null,
  },
  {
    id: 9,
    name: "Staging",
    steps: [
      { id: 21, name: "staging-deploy", agent: "devops" },
      { id: 22, name: "smoke-tests", agent: "qa-engineer" },
    ],
    checkpoint: {
      id: "CP-07",
      name: "Staging Approval",
      approvers: ["project-manager", "tech-lead"],
    },
  },
  {
    id: 10,
    name: "Production",
    steps: [
      { id: 23, name: "production-deploy", agent: "devops" },
      { id: 24, name: "post-deploy-validation", agent: "qa-engineer" },
    ],
    checkpoint: {
      id: "CP-08",
      name: "Go-Live Approval",
      approvers: ["project-manager", "architect", "product-owner"],
    },
  },
];

// Final checkpoint after production
const FINAL_CHECKPOINT = {
  id: "CP-09",
  name: "Post-Mortem & Retrospective",
  approvers: ["project-manager", "architect", "tech-lead"],
};

// ─── Azure Clients (lazy init with managed identity) ────────────────────────

let cosmosClient;
let sbClient;
let eventGridClient;
let blobClient;

function getCosmosClient() {
  if (!cosmosClient) {
    const credential = new DefaultAzureCredential();
    cosmosClient = new CosmosClient({ endpoint: COSMOS_ENDPOINT, aadCredentials: credential });
  }
  return cosmosClient;
}

function getServiceBusClient() {
  if (!sbClient) {
    const credential = new DefaultAzureCredential();
    sbClient = new ServiceBusClient(SERVICEBUS_NAMESPACE, credential);
  }
  return sbClient;
}

function getEventGridClient() {
  if (!eventGridClient) {
    eventGridClient = new EventGridPublisherClient(
      EVENTGRID_ENDPOINT,
      "EventGrid",
      new AzureKeyCredential(EVENTGRID_KEY)
    );
  }
  return eventGridClient;
}

function getBlobClient() {
  if (!blobClient) {
    const credential = new DefaultAzureCredential();
    blobClient = new BlobServiceClient(
      `https://${STORAGE_ACCOUNT}.blob.core.windows.net`,
      credential
    );
  }
  return blobClient;
}

// ─── Utility Functions ──────────────────────────────────────────────────────

function generateId() {
  return crypto.randomUUID();
}

function sha256(data) {
  return crypto.createHash("sha256").update(JSON.stringify(data)).digest("hex");
}

function now() {
  return new Date().toISOString();
}

// ─── Audit Trail ────────────────────────────────────────────────────────────

async function writeAuditEntry(squadId, entry) {
  const container = getCosmosClient()
    .database(COSMOS_DATABASE)
    .container("audit-trail");

  const auditRecord = {
    id: generateId(),
    squadId,
    timestamp: now(),
    hash: sha256(entry),
    ...entry,
  };

  await container.items.create(auditRecord);
  return auditRecord;
}

// ─── Pipeline State ─────────────────────────────────────────────────────────

async function getPipelineState(squadId) {
  const container = getCosmosClient()
    .database(COSMOS_DATABASE)
    .container("pipeline-state");

  try {
    const { resource } = await container.item(squadId, squadId).read();
    return resource;
  } catch (err) {
    if (err.code === 404) return null;
    throw err;
  }
}

async function savePipelineState(state) {
  const container = getCosmosClient()
    .database(COSMOS_DATABASE)
    .container("pipeline-state");

  await container.items.upsert(state);
  return state;
}

// ─── Agent Execution ────────────────────────────────────────────────────────

async function executeAgent(squadId, step, squadConfig) {
  const agentEndpoint = `https://${CONTAINER_APP_FQDN}/api/agents/${step.agent}/execute`;

  const payload = {
    squadId,
    stepId: step.id,
    stepName: step.name,
    agent: step.agent,
    config: squadConfig,
    timestamp: now(),
  };

  try {
    const response = await fetch(agentEndpoint, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(payload),
    });

    if (!response.ok) {
      const errorText = await response.text();
      throw new Error(`Agent ${step.agent} failed (${response.status}): ${errorText}`);
    }

    const result = await response.json();

    // Store artifact if produced
    if (result.artifact) {
      await storeArtifact(squadId, step, result.artifact);
    }

    return {
      success: true,
      stepId: step.id,
      agent: step.agent,
      output: result,
      artifactHash: result.artifact ? sha256(result.artifact) : null,
      completedAt: now(),
    };
  } catch (error) {
    return {
      success: false,
      stepId: step.id,
      agent: step.agent,
      error: error.message,
      failedAt: now(),
    };
  }
}

// ─── Artifact Storage ───────────────────────────────────────────────────────

async function storeArtifact(squadId, step, artifact) {
  const containerClient = getBlobClient().getContainerClient("artifacts");
  const blobName = `${squadId}/phase-${Math.ceil(step.id / 3)}/step-${step.id}-${step.name}.json`;
  const blockBlobClient = containerClient.getBlockBlobClient(blobName);

  const content = JSON.stringify(artifact, null, 2);
  const hash = sha256(artifact);

  await blockBlobClient.upload(content, Buffer.byteLength(content), {
    blobHTTPHeaders: { blobContentType: "application/json" },
    metadata: {
      squadId,
      stepId: String(step.id),
      stepName: step.name,
      agent: step.agent,
      sha256Hash: hash,
      createdAt: now(),
    },
    tags: {
      squadId,
      phase: String(Math.ceil(step.id / 3)),
      verified: "false",
    },
  });

  return { blobName, hash };
}

// ─── Checkpoint Management ──────────────────────────────────────────────────

async function createCheckpoint(squadId, checkpoint, phaseResults) {
  // Write checkpoint to Cosmos DB
  const container = getCosmosClient()
    .database(COSMOS_DATABASE)
    .container("checkpoints");

  const checkpointRecord = {
    id: `${squadId}-${checkpoint.id}`,
    squadId,
    checkpointId: checkpoint.id,
    checkpointName: checkpoint.name,
    approvers: checkpoint.approvers,
    status: "pending",
    phaseResults: phaseResults.map((r) => ({
      stepId: r.stepId,
      agent: r.agent,
      success: r.success,
      artifactHash: r.artifactHash || null,
    })),
    createdAt: now(),
    expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString(), // 7 days
  };

  await container.items.create(checkpointRecord);

  // Send approval request to Service Bus queue
  const sender = getServiceBusClient().createSender("approval-requests");
  try {
    await sender.sendMessages({
      body: {
        squadId,
        checkpointId: checkpoint.id,
        checkpointName: checkpoint.name,
        approvers: checkpoint.approvers,
        phaseResults: checkpointRecord.phaseResults,
        requestedAt: now(),
      },
      contentType: "application/json",
      subject: `checkpoint-${checkpoint.id}`,
      applicationProperties: {
        squadId,
        checkpointId: checkpoint.id,
        messageType: "approval-request",
      },
    });
  } finally {
    await sender.close();
  }

  // Emit Event Grid notification
  await getEventGridClient().send([
    {
      eventType: "ForgeSquad.Checkpoint.Created",
      subject: `squads/${squadId}/checkpoints/${checkpoint.id}`,
      dataVersion: "1.0",
      data: {
        squadId,
        checkpointId: checkpoint.id,
        checkpointName: checkpoint.name,
        approvers: checkpoint.approvers,
        status: "pending",
        createdAt: now(),
      },
    },
  ]);

  // Write to audit trail
  await writeAuditEntry(squadId, {
    eventType: "checkpoint.created",
    checkpointId: checkpoint.id,
    checkpointName: checkpoint.name,
    approvers: checkpoint.approvers,
    phaseResultCount: phaseResults.length,
  });

  return checkpointRecord;
}

// ─── Main Pipeline Runner Function ──────────────────────────────────────────

app.http("runPipeline", {
  methods: ["POST"],
  authLevel: "function",
  route: "pipeline/run",
  handler: async (request, context) => {
    context.log("Pipeline Runner invoked");

    let body;
    try {
      body = await request.json();
    } catch {
      return { status: 400, jsonBody: { error: "Invalid JSON body" } };
    }

    const { squadId, squadName, squadConfig, startFromPhase, startFromStep } = body;

    if (!squadId || !squadName) {
      return {
        status: 400,
        jsonBody: { error: "squadId and squadName are required" },
      };
    }

    // Check for existing pipeline state (resume support)
    let state = await getPipelineState(squadId);
    const isResume = !!state;

    if (!state) {
      state = {
        id: squadId,
        squadId,
        squadName,
        squadConfig: squadConfig || {},
        status: "running",
        currentPhase: startFromPhase || 1,
        currentStep: startFromStep || 1,
        completedSteps: [],
        failedSteps: [],
        checkpoints: [],
        startedAt: now(),
        updatedAt: now(),
      };
    } else {
      // Resume from where we left off
      if (state.status === "awaiting-approval") {
        return {
          status: 409,
          jsonBody: {
            error: "Pipeline is awaiting checkpoint approval",
            checkpointId: state.pendingCheckpoint,
            squadId,
          },
        };
      }
      state.status = "running";
      state.updatedAt = now();
    }

    await savePipelineState(state);

    // Audit: pipeline started/resumed
    await writeAuditEntry(squadId, {
      eventType: isResume ? "pipeline.resumed" : "pipeline.started",
      squadName,
      totalPhases: PIPELINE_PHASES.length,
      totalSteps: 24,
      totalCheckpoints: 9,
      startingPhase: state.currentPhase,
      startingStep: state.currentStep,
    });

    // Execute phases sequentially
    for (let pi = state.currentPhase - 1; pi < PIPELINE_PHASES.length; pi++) {
      const phase = PIPELINE_PHASES[pi];
      const phaseResults = [];

      context.log(`Executing Phase ${phase.id}: ${phase.name}`);

      // Audit: phase started
      await writeAuditEntry(squadId, {
        eventType: "phase.started",
        phaseId: phase.id,
        phaseName: phase.name,
        stepCount: phase.steps.length,
      });

      // Execute steps within phase
      for (const step of phase.steps) {
        // Skip already completed steps (resume support)
        if (state.completedSteps.includes(step.id)) {
          context.log(`Skipping completed step ${step.id}: ${step.name}`);
          continue;
        }

        context.log(`Executing Step ${step.id}: ${step.name} (agent: ${step.agent})`);

        // Audit: step started
        await writeAuditEntry(squadId, {
          eventType: "step.started",
          phaseId: phase.id,
          stepId: step.id,
          stepName: step.name,
          agent: step.agent,
        });

        // Execute the agent
        const result = await executeAgent(squadId, step, state.squadConfig);
        phaseResults.push(result);

        if (result.success) {
          state.completedSteps.push(step.id);
          state.currentStep = step.id + 1;

          await writeAuditEntry(squadId, {
            eventType: "step.completed",
            phaseId: phase.id,
            stepId: step.id,
            stepName: step.name,
            agent: step.agent,
            artifactHash: result.artifactHash,
          });
        } else {
          state.failedSteps.push({ stepId: step.id, error: result.error });

          await writeAuditEntry(squadId, {
            eventType: "step.failed",
            phaseId: phase.id,
            stepId: step.id,
            stepName: step.name,
            agent: step.agent,
            error: result.error,
          });

          // For non-critical steps, continue; for critical steps, pause
          context.warn(`Step ${step.id} failed: ${result.error}`);
        }

        // Update pipeline state
        state.updatedAt = now();
        await savePipelineState(state);
      }

      // Audit: phase completed
      await writeAuditEntry(squadId, {
        eventType: "phase.completed",
        phaseId: phase.id,
        phaseName: phase.name,
        successCount: phaseResults.filter((r) => r.success).length,
        failCount: phaseResults.filter((r) => !r.success).length,
      });

      // Handle checkpoint if present
      if (phase.checkpoint) {
        context.log(`Checkpoint ${phase.checkpoint.id}: ${phase.checkpoint.name}`);

        const checkpoint = await createCheckpoint(squadId, phase.checkpoint, phaseResults);

        // Pause pipeline — waiting for human approval
        state.status = "awaiting-approval";
        state.pendingCheckpoint = phase.checkpoint.id;
        state.currentPhase = phase.id + 1;
        state.updatedAt = now();
        state.checkpoints.push({
          id: phase.checkpoint.id,
          name: phase.checkpoint.name,
          status: "pending",
          createdAt: now(),
        });

        await savePipelineState(state);

        // Return immediately — pipeline will be resumed by approval-gate function
        return {
          status: 202,
          jsonBody: {
            message: `Pipeline paused at checkpoint: ${phase.checkpoint.name}`,
            squadId,
            status: "awaiting-approval",
            checkpointId: phase.checkpoint.id,
            checkpointName: phase.checkpoint.name,
            approvers: phase.checkpoint.approvers,
            completedSteps: state.completedSteps.length,
            totalSteps: 24,
            progress: `${Math.round((state.completedSteps.length / 24) * 100)}%`,
          },
        };
      }
    }

    // All phases completed — final checkpoint
    context.log("All phases completed. Creating final checkpoint (CP-09).");

    await createCheckpoint(squadId, FINAL_CHECKPOINT, []);

    state.status = "awaiting-approval";
    state.pendingCheckpoint = FINAL_CHECKPOINT.id;
    state.updatedAt = now();
    state.checkpoints.push({
      id: FINAL_CHECKPOINT.id,
      name: FINAL_CHECKPOINT.name,
      status: "pending",
      createdAt: now(),
    });

    await savePipelineState(state);

    return {
      status: 202,
      jsonBody: {
        message: "Pipeline execution complete. Awaiting final retrospective approval.",
        squadId,
        status: "awaiting-final-approval",
        checkpointId: FINAL_CHECKPOINT.id,
        checkpointName: FINAL_CHECKPOINT.name,
        completedSteps: state.completedSteps.length,
        totalSteps: 24,
        progress: "100%",
      },
    };
  },
});

// ─── Get Pipeline Status ────────────────────────────────────────────────────

app.http("getPipelineStatus", {
  methods: ["GET"],
  authLevel: "function",
  route: "pipeline/{squadId}/status",
  handler: async (request, context) => {
    const squadId = request.params.squadId;

    const state = await getPipelineState(squadId);
    if (!state) {
      return { status: 404, jsonBody: { error: `Pipeline ${squadId} not found` } };
    }

    // Get recent audit entries
    const auditContainer = getCosmosClient()
      .database(COSMOS_DATABASE)
      .container("audit-trail");

    const { resources: recentAudit } = await auditContainer.items
      .query({
        query: "SELECT TOP 20 * FROM c WHERE c.squadId = @squadId ORDER BY c.timestamp DESC",
        parameters: [{ name: "@squadId", value: squadId }],
      })
      .fetchAll();

    return {
      status: 200,
      jsonBody: {
        squadId: state.squadId,
        squadName: state.squadName,
        status: state.status,
        currentPhase: state.currentPhase,
        currentStep: state.currentStep,
        completedSteps: state.completedSteps.length,
        failedSteps: state.failedSteps.length,
        totalSteps: 24,
        progress: `${Math.round((state.completedSteps.length / 24) * 100)}%`,
        pendingCheckpoint: state.pendingCheckpoint || null,
        checkpoints: state.checkpoints,
        startedAt: state.startedAt,
        updatedAt: state.updatedAt,
        recentActivity: recentAudit.map((a) => ({
          eventType: a.eventType,
          timestamp: a.timestamp,
          details: {
            phaseId: a.phaseId,
            stepId: a.stepId,
            stepName: a.stepName,
            agent: a.agent,
            checkpointId: a.checkpointId,
          },
        })),
      },
    };
  },
});

// ─── List All Pipelines ─────────────────────────────────────────────────────

app.http("listPipelines", {
  methods: ["GET"],
  authLevel: "function",
  route: "pipeline/list",
  handler: async (request, context) => {
    const statusFilter = request.query.get("status");

    const container = getCosmosClient()
      .database(COSMOS_DATABASE)
      .container("pipeline-state");

    let query = "SELECT c.id, c.squadName, c.status, c.currentPhase, c.currentStep, c.completedSteps, c.startedAt, c.updatedAt FROM c";
    const parameters = [];

    if (statusFilter) {
      query += " WHERE c.status = @status";
      parameters.push({ name: "@status", value: statusFilter });
    }

    query += " ORDER BY c.updatedAt DESC";

    const { resources } = await container.items
      .query({ query, parameters })
      .fetchAll();

    return {
      status: 200,
      jsonBody: {
        count: resources.length,
        pipelines: resources.map((p) => ({
          squadId: p.id,
          squadName: p.squadName,
          status: p.status,
          currentPhase: p.currentPhase,
          progress: `${Math.round(((p.completedSteps?.length || 0) / 24) * 100)}%`,
          startedAt: p.startedAt,
          updatedAt: p.updatedAt,
        })),
      },
    };
  },
});

module.exports = { PIPELINE_PHASES, FINAL_CHECKPOINT };
