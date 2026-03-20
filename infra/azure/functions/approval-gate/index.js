/**
 * ForgeSquad — Approval Gate Azure Function
 *
 * Gerencia as aprovacoes humanas nos 9 checkpoints do pipeline.
 * Receives approve/reject/modify decisions via Service Bus,
 * updates Cosmos DB audit trail, validates SHA-256 artifact hashes,
 * and resumes pipeline execution upon approval.
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
const PIPELINE_RUNNER_URL = process.env.PIPELINE_RUNNER_URL;
const PIPELINE_RUNNER_KEY = process.env.PIPELINE_RUNNER_FUNCTION_KEY;

// ─── Azure Clients ──────────────────────────────────────────────────────────

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

// ─── Artifact Hash Validation ───────────────────────────────────────────────

async function validateArtifactHashes(squadId, phaseResults) {
  const containerClient = getBlobClient().getContainerClient("artifacts");
  const validationResults = [];

  for (const result of phaseResults) {
    if (!result.artifactHash) {
      validationResults.push({
        stepId: result.stepId,
        agent: result.agent,
        status: "no-artifact",
        valid: true,
      });
      continue;
    }

    try {
      // List blobs for this step
      const prefix = `${squadId}/`;
      const blobs = containerClient.listBlobsFlat({
        prefix,
        includeMetadata: true,
      });

      let found = false;
      for await (const blob of blobs) {
        if (
          blob.metadata &&
          blob.metadata.stepId === String(result.stepId) &&
          blob.metadata.squadId === squadId
        ) {
          const storedHash = blob.metadata.sha256Hash;
          const hashMatch = storedHash === result.artifactHash;

          validationResults.push({
            stepId: result.stepId,
            agent: result.agent,
            blobName: blob.name,
            expectedHash: result.artifactHash,
            actualHash: storedHash,
            valid: hashMatch,
            status: hashMatch ? "verified" : "hash-mismatch",
          });

          // Update blob tags if verified
          if (hashMatch) {
            const blobTagClient = containerClient.getBlockBlobClient(blob.name);
            await blobTagClient.setTags({
              squadId,
              phase: blob.metadata.phase || "unknown",
              verified: "true",
              verifiedAt: now(),
            });
          }

          found = true;
          break;
        }
      }

      if (!found) {
        validationResults.push({
          stepId: result.stepId,
          agent: result.agent,
          status: "artifact-not-found",
          valid: false,
        });
      }
    } catch (error) {
      validationResults.push({
        stepId: result.stepId,
        agent: result.agent,
        status: "validation-error",
        valid: false,
        error: error.message,
      });
    }
  }

  return validationResults;
}

// ─── Resume Pipeline ────────────────────────────────────────────────────────

async function resumePipeline(squadId, squadConfig) {
  const url = PIPELINE_RUNNER_URL || `https://${process.env.WEBSITE_HOSTNAME}/api/pipeline/run`;
  const key = PIPELINE_RUNNER_KEY;

  const headers = { "Content-Type": "application/json" };
  if (key) {
    headers["x-functions-key"] = key;
  }

  try {
    const response = await fetch(url, {
      method: "POST",
      headers,
      body: JSON.stringify({
        squadId,
        squadName: squadConfig?.squadName || squadId,
        squadConfig,
      }),
    });

    if (!response.ok) {
      const errorText = await response.text();
      throw new Error(`Pipeline resume failed (${response.status}): ${errorText}`);
    }

    return await response.json();
  } catch (error) {
    console.error(`Failed to resume pipeline ${squadId}:`, error.message);
    throw error;
  }
}

// ─── HTTP: Submit Approval Decision ─────────────────────────────────────────

app.http("submitApproval", {
  methods: ["POST"],
  authLevel: "function",
  route: "pipeline/{squadId}/approve",
  handler: async (request, context) => {
    const squadId = request.params.squadId;

    let body;
    try {
      body = await request.json();
    } catch {
      return { status: 400, jsonBody: { error: "Invalid JSON body" } };
    }

    const {
      checkpointId,
      decision,      // "approve" | "reject" | "modify"
      approvedBy,
      comments,
      modifications, // optional: changes requested if decision is "modify"
    } = body;

    // Validate required fields
    if (!checkpointId || !decision || !approvedBy) {
      return {
        status: 400,
        jsonBody: {
          error: "checkpointId, decision, and approvedBy are required",
          validDecisions: ["approve", "reject", "modify"],
        },
      };
    }

    if (!["approve", "reject", "modify"].includes(decision)) {
      return {
        status: 400,
        jsonBody: {
          error: `Invalid decision: ${decision}. Must be one of: approve, reject, modify`,
        },
      };
    }

    // Get checkpoint from Cosmos DB
    const checkpointContainer = getCosmosClient()
      .database(COSMOS_DATABASE)
      .container("checkpoints");

    const checkpointDocId = `${squadId}-${checkpointId}`;
    let checkpoint;

    try {
      const { resource } = await checkpointContainer
        .item(checkpointDocId, squadId)
        .read();
      checkpoint = resource;
    } catch (err) {
      if (err.code === 404) {
        return {
          status: 404,
          jsonBody: { error: `Checkpoint ${checkpointId} not found for squad ${squadId}` },
        };
      }
      throw err;
    }

    if (checkpoint.status !== "pending") {
      return {
        status: 409,
        jsonBody: {
          error: `Checkpoint ${checkpointId} is already ${checkpoint.status}`,
          decidedAt: checkpoint.decidedAt,
          decidedBy: checkpoint.decidedBy,
        },
      };
    }

    // Validate artifact hashes if approving
    let hashValidation = null;
    if (decision === "approve" && checkpoint.phaseResults?.length > 0) {
      context.log(`Validating artifact hashes for checkpoint ${checkpointId}`);
      hashValidation = await validateArtifactHashes(squadId, checkpoint.phaseResults);

      const invalidArtifacts = hashValidation.filter((v) => !v.valid);
      if (invalidArtifacts.length > 0) {
        await writeAuditEntry(squadId, {
          eventType: "checkpoint.hash-validation-failed",
          checkpointId,
          invalidArtifacts,
        });

        return {
          status: 422,
          jsonBody: {
            error: "Artifact hash validation failed. Cannot approve until resolved.",
            checkpointId,
            invalidArtifacts,
            recommendation: "Re-run the failed steps or investigate artifact tampering.",
          },
        };
      }
    }

    // Update checkpoint status
    checkpoint.status = decision === "approve" ? "approved" : decision;
    checkpoint.decidedBy = approvedBy;
    checkpoint.decidedAt = now();
    checkpoint.comments = comments || null;
    checkpoint.modifications = modifications || null;
    checkpoint.hashValidation = hashValidation;

    await checkpointContainer.item(checkpointDocId, squadId).replace(checkpoint);

    // Update pipeline state
    const pipelineContainer = getCosmosClient()
      .database(COSMOS_DATABASE)
      .container("pipeline-state");

    let pipelineState;
    try {
      const { resource } = await pipelineContainer.item(squadId, squadId).read();
      pipelineState = resource;
    } catch (err) {
      context.warn(`Pipeline state not found for ${squadId}`);
      pipelineState = null;
    }

    if (pipelineState) {
      // Update the checkpoint entry in pipeline state
      const cpIndex = pipelineState.checkpoints.findIndex((c) => c.id === checkpointId);
      if (cpIndex >= 0) {
        pipelineState.checkpoints[cpIndex].status = checkpoint.status;
        pipelineState.checkpoints[cpIndex].decidedAt = checkpoint.decidedAt;
        pipelineState.checkpoints[cpIndex].decidedBy = approvedBy;
      }

      if (decision === "approve") {
        pipelineState.status = "running";
        pipelineState.pendingCheckpoint = null;
      } else if (decision === "reject") {
        pipelineState.status = "rejected";
        pipelineState.pendingCheckpoint = null;
      } else if (decision === "modify") {
        pipelineState.status = "modifications-requested";
        pipelineState.pendingCheckpoint = checkpointId;
        pipelineState.requestedModifications = modifications;
      }

      pipelineState.updatedAt = now();
      await pipelineContainer.item(squadId, squadId).replace(pipelineState);
    }

    // Send response to Service Bus
    const sender = getServiceBusClient().createSender("approval-responses");
    try {
      await sender.sendMessages({
        body: {
          squadId,
          checkpointId,
          decision,
          approvedBy,
          comments,
          modifications,
          decidedAt: now(),
        },
        contentType: "application/json",
        subject: `approval-response-${checkpointId}`,
        applicationProperties: {
          squadId,
          checkpointId,
          decision,
          messageType: "approval-response",
        },
      });
    } finally {
      await sender.close();
    }

    // Emit Event Grid notification
    await getEventGridClient().send([
      {
        eventType: `ForgeSquad.Checkpoint.${decision.charAt(0).toUpperCase() + decision.slice(1)}d`,
        subject: `squads/${squadId}/checkpoints/${checkpointId}`,
        dataVersion: "1.0",
        data: {
          squadId,
          checkpointId,
          checkpointName: checkpoint.checkpointName,
          decision,
          approvedBy,
          comments,
          hashValidation: hashValidation
            ? {
                totalArtifacts: hashValidation.length,
                verified: hashValidation.filter((v) => v.valid).length,
              }
            : null,
          decidedAt: now(),
        },
      },
    ]);

    // Write to audit trail
    await writeAuditEntry(squadId, {
      eventType: `checkpoint.${decision}`,
      checkpointId,
      checkpointName: checkpoint.checkpointName,
      decision,
      approvedBy,
      comments,
      hashValidation: hashValidation
        ? {
            totalArtifacts: hashValidation.length,
            allVerified: hashValidation.every((v) => v.valid),
          }
        : null,
    });

    // If approved, resume pipeline
    let resumeResult = null;
    if (decision === "approve" && pipelineState?.status === "running") {
      try {
        context.log(`Resuming pipeline ${squadId} after checkpoint ${checkpointId} approval`);
        resumeResult = await resumePipeline(squadId, pipelineState.squadConfig);
      } catch (error) {
        context.error(`Failed to resume pipeline: ${error.message}`);
        resumeResult = { error: error.message };
      }
    }

    return {
      status: 200,
      jsonBody: {
        message: `Checkpoint ${checkpointId} ${decision === "approve" ? "approved" : decision === "reject" ? "rejected" : "sent for modifications"}`,
        squadId,
        checkpointId,
        decision,
        approvedBy,
        hashValidation: hashValidation
          ? {
              totalArtifacts: hashValidation.length,
              verified: hashValidation.filter((v) => v.valid).length,
              failed: hashValidation.filter((v) => !v.valid).length,
            }
          : null,
        pipelineStatus: pipelineState?.status || "unknown",
        resumeResult,
      },
    };
  },
});

// ─── HTTP: Get Checkpoint Details ───────────────────────────────────────────

app.http("getCheckpoint", {
  methods: ["GET"],
  authLevel: "function",
  route: "pipeline/{squadId}/checkpoints/{checkpointId}",
  handler: async (request, context) => {
    const { squadId, checkpointId } = request.params;

    const container = getCosmosClient()
      .database(COSMOS_DATABASE)
      .container("checkpoints");

    const checkpointDocId = `${squadId}-${checkpointId}`;

    try {
      const { resource } = await container.item(checkpointDocId, squadId).read();
      return { status: 200, jsonBody: resource };
    } catch (err) {
      if (err.code === 404) {
        return {
          status: 404,
          jsonBody: { error: `Checkpoint ${checkpointId} not found` },
        };
      }
      throw err;
    }
  },
});

// ─── HTTP: List Pending Checkpoints ─────────────────────────────────────────

app.http("listPendingCheckpoints", {
  methods: ["GET"],
  authLevel: "function",
  route: "pipeline/checkpoints/pending",
  handler: async (request, context) => {
    const container = getCosmosClient()
      .database(COSMOS_DATABASE)
      .container("checkpoints");

    const { resources } = await container.items
      .query({
        query: 'SELECT * FROM c WHERE c.status = "pending" ORDER BY c.createdAt ASC',
      })
      .fetchAll();

    return {
      status: 200,
      jsonBody: {
        count: resources.length,
        checkpoints: resources.map((cp) => ({
          squadId: cp.squadId,
          checkpointId: cp.checkpointId,
          checkpointName: cp.checkpointName,
          approvers: cp.approvers,
          createdAt: cp.createdAt,
          expiresAt: cp.expiresAt,
          phaseResultsSummary: {
            total: cp.phaseResults?.length || 0,
            successful: cp.phaseResults?.filter((r) => r.success).length || 0,
          },
        })),
      },
    };
  },
});

// ─── Service Bus Trigger: Process Approval Responses ────────────────────────

app.serviceBusTopic("processApprovalResponse", {
  connection: "SERVICEBUS_CONNECTION",
  topicName: "agent-messages",
  subscriptionName: "sub-project-manager",
  handler: async (message, context) => {
    const messageType = message.applicationProperties?.messageType;

    if (messageType !== "approval-response") {
      context.log(`Ignoring non-approval message type: ${messageType}`);
      return;
    }

    const { squadId, checkpointId, decision, approvedBy } = message.body;

    context.log(
      `Processing approval response: squad=${squadId}, checkpoint=${checkpointId}, decision=${decision}, by=${approvedBy}`
    );

    // Generate PM status report after each checkpoint decision
    await writeAuditEntry(squadId, {
      eventType: "pm.status-report-triggered",
      trigger: "checkpoint-decision",
      checkpointId,
      decision,
    });

    // Notify Event Grid for downstream consumers (Teams, email, etc.)
    try {
      await getEventGridClient().send([
        {
          eventType: "ForgeSquad.PM.StatusReportGenerated",
          subject: `squads/${squadId}/reports/checkpoint-${checkpointId}`,
          dataVersion: "1.0",
          data: {
            squadId,
            checkpointId,
            decision,
            approvedBy,
            reportType: "checkpoint-status",
            generatedAt: now(),
          },
        },
      ]);
    } catch (error) {
      context.error(`Failed to emit PM report event: ${error.message}`);
    }
  },
});

// ─── HTTP: Get Audit Trail ──────────────────────────────────────────────────

app.http("getAuditTrail", {
  methods: ["GET"],
  authLevel: "function",
  route: "pipeline/{squadId}/audit",
  handler: async (request, context) => {
    const squadId = request.params.squadId;
    const limit = parseInt(request.query.get("limit") || "50", 10);
    const eventType = request.query.get("eventType");

    const container = getCosmosClient()
      .database(COSMOS_DATABASE)
      .container("audit-trail");

    let query = "SELECT * FROM c WHERE c.squadId = @squadId";
    const parameters = [{ name: "@squadId", value: squadId }];

    if (eventType) {
      query += " AND c.eventType = @eventType";
      parameters.push({ name: "@eventType", value: eventType });
    }

    query += ` ORDER BY c.timestamp DESC OFFSET 0 LIMIT ${limit}`;

    const { resources } = await container.items
      .query({ query, parameters })
      .fetchAll();

    return {
      status: 200,
      jsonBody: {
        squadId,
        count: resources.length,
        entries: resources.map((entry) => ({
          id: entry.id,
          eventType: entry.eventType,
          timestamp: entry.timestamp,
          hash: entry.hash,
          details: Object.fromEntries(
            Object.entries(entry).filter(
              ([key]) =>
                !["id", "squadId", "eventType", "timestamp", "hash", "_rid", "_self", "_etag", "_attachments", "_ts"].includes(key)
            )
          ),
        })),
      },
    };
  },
});

// ─── HTTP: Verify Artifact Integrity ────────────────────────────────────────

app.http("verifyArtifact", {
  methods: ["POST"],
  authLevel: "function",
  route: "pipeline/{squadId}/verify-artifact",
  handler: async (request, context) => {
    const squadId = request.params.squadId;

    let body;
    try {
      body = await request.json();
    } catch {
      return { status: 400, jsonBody: { error: "Invalid JSON body" } };
    }

    const { stepId, expectedHash } = body;

    if (!stepId || !expectedHash) {
      return {
        status: 400,
        jsonBody: { error: "stepId and expectedHash are required" },
      };
    }

    const containerClient = getBlobClient().getContainerClient("artifacts");
    const prefix = `${squadId}/`;

    let artifactFound = false;
    let verificationResult = null;

    for await (const blob of containerClient.listBlobsFlat({ prefix, includeMetadata: true })) {
      if (blob.metadata?.stepId === String(stepId) && blob.metadata?.squadId === squadId) {
        artifactFound = true;

        // Download and compute hash
        const blobClientRef = containerClient.getBlockBlobClient(blob.name);
        const downloadResponse = await blobClientRef.download(0);
        const chunks = [];
        for await (const chunk of downloadResponse.readableStreamBody) {
          chunks.push(chunk);
        }
        const content = Buffer.concat(chunks).toString("utf-8");
        const computedHash = crypto.createHash("sha256").update(content).digest("hex");

        const storedHash = blob.metadata.sha256Hash;
        const matchesExpected = computedHash === expectedHash;
        const matchesStored = computedHash === storedHash;

        verificationResult = {
          blobName: blob.name,
          stepId,
          computedHash,
          expectedHash,
          storedHash,
          matchesExpected,
          matchesStored,
          integrity: matchesExpected && matchesStored ? "verified" : "compromised",
          verifiedAt: now(),
        };

        // Write verification to audit trail
        await writeAuditEntry(squadId, {
          eventType: "artifact.verification",
          stepId: parseInt(stepId, 10),
          blobName: blob.name,
          integrity: verificationResult.integrity,
          matchesExpected,
          matchesStored,
        });

        break;
      }
    }

    if (!artifactFound) {
      return {
        status: 404,
        jsonBody: { error: `No artifact found for step ${stepId} in squad ${squadId}` },
      };
    }

    return {
      status: verificationResult.integrity === "verified" ? 200 : 409,
      jsonBody: verificationResult,
    };
  },
});
