/**
 * ForgeSquad Approval Gate — Lambda Function
 *
 * Handles human approval/reject/modify decisions for pipeline checkpoints.
 * Validates SHA-256 artifact hashes, updates the DynamoDB audit trail,
 * and resumes pipeline execution upon approval.
 *
 * Environment variables:
 *   AUDIT_TABLE, PIPELINE_STATE_TABLE, CHECKPOINT_TABLE,
 *   DISPATCH_QUEUE_URL, ARTIFACTS_BUCKET, PIPELINE_RUNNER_FUNCTION,
 *   ENVIRONMENT, PROJECT_NAME
 */

const { DynamoDBClient } = require('@aws-sdk/client-dynamodb');
const {
  DynamoDBDocumentClient,
  PutCommand,
  GetCommand,
  UpdateCommand,
} = require('@aws-sdk/lib-dynamodb');
const { SQSClient, SendMessageCommand } = require('@aws-sdk/client-sqs');
const { S3Client, GetObjectCommand, HeadObjectCommand } = require('@aws-sdk/client-s3');
const { LambdaClient, InvokeCommand } = require('@aws-sdk/client-lambda');
const crypto = require('crypto');

// --- AWS Clients ---
const dynamoDb = DynamoDBDocumentClient.from(new DynamoDBClient({}));
const sqs = new SQSClient({});
const s3 = new S3Client({});
const lambda = new LambdaClient({});

// --- Environment ---
const {
  AUDIT_TABLE,
  PIPELINE_STATE_TABLE,
  CHECKPOINT_TABLE,
  DISPATCH_QUEUE_URL,
  ARTIFACTS_BUCKET,
  PIPELINE_RUNNER_FUNCTION,
  ENVIRONMENT,
  PROJECT_NAME,
} = process.env;

// ==============================================================================
// Main Handler
// ==============================================================================

exports.handler = async (event) => {
  console.log('Approval Gate invoked:', JSON.stringify(event));

  try {
    const body = typeof event.body === 'string' ? JSON.parse(event.body) : event;
    const { action } = body;

    if (!action) {
      return response(400, { error: 'action is required (approve, reject, modify, status)' });
    }

    switch (action) {
      case 'approve':
        return await handleApproval(body);
      case 'reject':
        return await handleRejection(body);
      case 'modify':
        return await handleModification(body);
      case 'status':
        return await getCheckpointStatus(body);
      default:
        return response(400, { error: `Unknown action: ${action}` });
    }
  } catch (error) {
    console.error('Approval Gate error:', error);
    return response(500, { error: 'Internal error', message: error.message });
  }
};

// ==============================================================================
// Approve
// ==============================================================================

async function handleApproval(body) {
  const { checkpointId, approvedBy, comments, artifactHashes } = body;

  if (!checkpointId || !approvedBy) {
    return response(400, { error: 'checkpointId and approvedBy are required' });
  }

  // Retrieve checkpoint
  const checkpoint = await getCheckpoint(checkpointId);
  if (!checkpoint) {
    return response(404, { error: `Checkpoint ${checkpointId} not found` });
  }

  if (checkpoint.status !== 'pending') {
    return response(400, {
      error: `Checkpoint is already '${checkpoint.status}'`,
    });
  }

  // Validate approver role
  if (!checkpoint.approvers.includes(approvedBy) && approvedBy !== 'admin') {
    return response(403, {
      error: `User role '${approvedBy}' is not authorized to approve this checkpoint`,
      allowedApprovers: checkpoint.approvers,
    });
  }

  // Validate artifact hashes if provided
  if (artifactHashes && Object.keys(artifactHashes).length > 0) {
    const hashValidation = await validateArtifactHashes(
      checkpoint.pipelineId,
      artifactHashes
    );

    if (!hashValidation.valid) {
      await writeAuditEntry(checkpoint.pipelineId, 'HASH_VALIDATION_FAILED', {
        checkpointId,
        failures: hashValidation.failures,
        approvedBy,
      });

      return response(400, {
        error: 'Artifact hash validation failed',
        failures: hashValidation.failures,
      });
    }

    await writeAuditEntry(checkpoint.pipelineId, 'HASH_VALIDATION_PASSED', {
      checkpointId,
      verifiedArtifacts: Object.keys(artifactHashes),
      approvedBy,
    });
  }

  const now = new Date().toISOString();

  // Update checkpoint status
  await updateCheckpoint(checkpointId, {
    status: 'approved',
    approvedBy,
    approvedAt: now,
    comments: comments || '',
  });

  // Write audit entry
  await writeAuditEntry(checkpoint.pipelineId, 'CHECKPOINT_APPROVED', {
    checkpointId,
    checkpointName: checkpoint.checkpointName,
    phase: checkpoint.phase,
    approvedBy,
    comments,
  });

  // Resume pipeline execution
  await resumePipeline(checkpoint.pipelineId, checkpoint.phase + 1);

  return response(200, {
    checkpointId,
    status: 'approved',
    approvedBy,
    message: `Checkpoint '${checkpoint.checkpointName}' approved. Pipeline resuming at phase ${checkpoint.phase + 1}.`,
  });
}

// ==============================================================================
// Reject
// ==============================================================================

async function handleRejection(body) {
  const { checkpointId, rejectedBy, reason, blockPipeline = true } = body;

  if (!checkpointId || !rejectedBy || !reason) {
    return response(400, {
      error: 'checkpointId, rejectedBy, and reason are required',
    });
  }

  const checkpoint = await getCheckpoint(checkpointId);
  if (!checkpoint) {
    return response(404, { error: `Checkpoint ${checkpointId} not found` });
  }

  if (checkpoint.status !== 'pending') {
    return response(400, {
      error: `Checkpoint is already '${checkpoint.status}'`,
    });
  }

  // Validate approver role
  if (!checkpoint.approvers.includes(rejectedBy) && rejectedBy !== 'admin') {
    return response(403, {
      error: `User role '${rejectedBy}' is not authorized to reject this checkpoint`,
    });
  }

  const now = new Date().toISOString();

  // Update checkpoint
  await updateCheckpoint(checkpointId, {
    status: 'rejected',
    rejectedBy,
    rejectedAt: now,
    rejectionReason: reason,
  });

  // Update pipeline state
  if (blockPipeline) {
    await updatePipelineState(checkpoint.pipelineId, {
      status: 'blocked',
      blockedAt: now,
      blockedReason: reason,
      blockedBy: rejectedBy,
      currentCheckpoint: checkpointId,
    });
  }

  await writeAuditEntry(checkpoint.pipelineId, 'CHECKPOINT_REJECTED', {
    checkpointId,
    checkpointName: checkpoint.checkpointName,
    phase: checkpoint.phase,
    rejectedBy,
    reason,
    pipelineBlocked: blockPipeline,
  });

  return response(200, {
    checkpointId,
    status: 'rejected',
    rejectedBy,
    reason,
    pipelineBlocked: blockPipeline,
    message: blockPipeline
      ? `Checkpoint rejected. Pipeline blocked. Use 'modify' to request changes.`
      : `Checkpoint rejected but pipeline not blocked.`,
  });
}

// ==============================================================================
// Modify (Request Changes)
// ==============================================================================

async function handleModification(body) {
  const { checkpointId, requestedBy, changes, rerunSteps } = body;

  if (!checkpointId || !requestedBy || !changes) {
    return response(400, {
      error: 'checkpointId, requestedBy, and changes are required',
    });
  }

  const checkpoint = await getCheckpoint(checkpointId);
  if (!checkpoint) {
    return response(404, { error: `Checkpoint ${checkpointId} not found` });
  }

  if (!['pending', 'rejected'].includes(checkpoint.status)) {
    return response(400, {
      error: `Cannot modify checkpoint in '${checkpoint.status}' state`,
    });
  }

  const now = new Date().toISOString();

  // Update checkpoint with modification request
  await updateCheckpoint(checkpointId, {
    status: 'changes_requested',
    modifiedBy: requestedBy,
    modifiedAt: now,
    requestedChanges: changes,
    rerunSteps: rerunSteps || [],
  });

  // If specific steps should be re-run, dispatch them
  if (rerunSteps && rerunSteps.length > 0) {
    for (const stepInfo of rerunSteps) {
      await sqs.send(new SendMessageCommand({
        QueueUrl: DISPATCH_QUEUE_URL,
        MessageBody: JSON.stringify({
          taskId: `rerun-${Date.now()}-${crypto.randomBytes(4).toString('hex')}`,
          pipelineId: checkpoint.pipelineId,
          phase: checkpoint.phase,
          step: stepInfo.step,
          agentRole: stepInfo.agentRole,
          modelTier: stepInfo.modelTier || 'sonnet',
          isRerun: true,
          changes,
          timestamp: now,
        }),
      }));
    }
  }

  // Reset pipeline state to running (re-executing the current phase)
  await updatePipelineState(checkpoint.pipelineId, {
    status: 'running',
    currentPhase: checkpoint.phase,
  });

  await writeAuditEntry(checkpoint.pipelineId, 'CHECKPOINT_CHANGES_REQUESTED', {
    checkpointId,
    checkpointName: checkpoint.checkpointName,
    phase: checkpoint.phase,
    requestedBy,
    changes,
    rerunSteps,
  });

  return response(200, {
    checkpointId,
    status: 'changes_requested',
    requestedBy,
    message: `Changes requested for phase ${checkpoint.phase}. ${
      rerunSteps?.length ? `Re-running ${rerunSteps.length} step(s).` : ''
    }`,
  });
}

// ==============================================================================
// Status
// ==============================================================================

async function getCheckpointStatus(body) {
  const { checkpointId } = body;

  if (!checkpointId) {
    return response(400, { error: 'checkpointId is required' });
  }

  const checkpoint = await getCheckpoint(checkpointId);
  if (!checkpoint) {
    return response(404, { error: `Checkpoint ${checkpointId} not found` });
  }

  return response(200, checkpoint);
}

// ==============================================================================
// SHA-256 Artifact Validation
// ==============================================================================

async function validateArtifactHashes(pipelineId, expectedHashes) {
  const failures = [];

  for (const [artifactKey, expectedHash] of Object.entries(expectedHashes)) {
    try {
      const s3Key = `${pipelineId}/${artifactKey}`;

      // Get the object from S3
      const getResult = await s3.send(new GetObjectCommand({
        Bucket: ARTIFACTS_BUCKET,
        Key: s3Key,
      }));

      // Read the stream and compute SHA-256
      const chunks = [];
      for await (const chunk of getResult.Body) {
        chunks.push(chunk);
      }
      const buffer = Buffer.concat(chunks);
      const actualHash = crypto.createHash('sha256').update(buffer).digest('hex');

      if (actualHash !== expectedHash.toLowerCase()) {
        failures.push({
          artifact: artifactKey,
          expected: expectedHash.toLowerCase(),
          actual: actualHash,
          status: 'HASH_MISMATCH',
        });
      }
    } catch (error) {
      if (error.name === 'NoSuchKey') {
        failures.push({
          artifact: artifactKey,
          status: 'ARTIFACT_NOT_FOUND',
          error: `Artifact '${artifactKey}' not found in S3`,
        });
      } else {
        failures.push({
          artifact: artifactKey,
          status: 'VALIDATION_ERROR',
          error: error.message,
        });
      }
    }
  }

  return {
    valid: failures.length === 0,
    failures,
    verified: Object.keys(expectedHashes).length - failures.length,
    total: Object.keys(expectedHashes).length,
  };
}

// ==============================================================================
// Resume Pipeline
// ==============================================================================

async function resumePipeline(pipelineId, fromPhase) {
  console.log(`Resuming pipeline ${pipelineId} from phase ${fromPhase}`);

  // Invoke the pipeline runner Lambda asynchronously
  await lambda.send(new InvokeCommand({
    FunctionName: PIPELINE_RUNNER_FUNCTION,
    InvocationType: 'Event', // Async invocation
    Payload: JSON.stringify({
      action: 'resume',
      pipelineId,
      fromPhase,
    }),
  }));
}

// ==============================================================================
// DynamoDB Helpers
// ==============================================================================

async function getCheckpoint(checkpointId) {
  const result = await dynamoDb.send(new GetCommand({
    TableName: CHECKPOINT_TABLE,
    Key: { checkpointId },
  }));
  return result.Item;
}

async function updateCheckpoint(checkpointId, updates) {
  const updateExpressions = [];
  const expressionValues = {};
  const expressionNames = {};

  updates.updatedAt = new Date().toISOString();

  for (const [key, value] of Object.entries(updates)) {
    const attrName = `#${key}`;
    const attrValue = `:${key}`;
    updateExpressions.push(`${attrName} = ${attrValue}`);
    expressionNames[attrName] = key;
    expressionValues[attrValue] = value;
  }

  await dynamoDb.send(new UpdateCommand({
    TableName: CHECKPOINT_TABLE,
    Key: { checkpointId },
    UpdateExpression: `SET ${updateExpressions.join(', ')}`,
    ExpressionAttributeNames: expressionNames,
    ExpressionAttributeValues: expressionValues,
  }));
}

async function updatePipelineState(pipelineId, updates) {
  const updateExpressions = [];
  const expressionValues = {};
  const expressionNames = {};

  updates.updatedAt = new Date().toISOString();

  for (const [key, value] of Object.entries(updates)) {
    const attrName = `#${key}`;
    const attrValue = `:${key}`;
    updateExpressions.push(`${attrName} = ${attrValue}`);
    expressionNames[attrName] = key;
    expressionValues[attrValue] = value;
  }

  await dynamoDb.send(new UpdateCommand({
    TableName: PIPELINE_STATE_TABLE,
    Key: { pipelineId },
    UpdateExpression: `SET ${updateExpressions.join(', ')}`,
    ExpressionAttributeNames: expressionNames,
    ExpressionAttributeValues: expressionValues,
  }));
}

async function writeAuditEntry(pipelineId, eventType, details) {
  const now = new Date().toISOString();
  const entryId = `${now}-${crypto.randomBytes(4).toString('hex')}`;

  await dynamoDb.send(new PutCommand({
    TableName: AUDIT_TABLE,
    Item: {
      pipelineId,
      timestamp: entryId,
      eventType,
      details,
      environment: ENVIRONMENT,
      createdAt: now,
      agentRole: details?.approvedBy || details?.rejectedBy || details?.requestedBy || 'system',
    },
    ConditionExpression:
      'attribute_not_exists(pipelineId) AND attribute_not_exists(#ts)',
    ExpressionAttributeNames: { '#ts': 'timestamp' },
  }));
}

// ==============================================================================
// HTTP Response Helper
// ==============================================================================

function response(statusCode, body) {
  return {
    statusCode,
    headers: {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Headers': 'Content-Type,Authorization',
      'X-Request-Id': crypto.randomBytes(8).toString('hex'),
    },
    body: JSON.stringify(body),
  };
}
