/**
 * ForgeSquad Pipeline Runner — Lambda Function
 *
 * Orchestrates the 24-step, 10-phase pipeline for multi-agent execution.
 * Receives squad configuration, dispatches agents via ECS Fargate tasks,
 * manages 9 human checkpoints, writes to the DynamoDB audit trail,
 * and sends SNS notifications at each checkpoint.
 *
 * Environment variables (injected by CloudFormation/Terraform):
 *   ECS_CLUSTER, TASK_DEFINITION, DISPATCH_QUEUE_URL, RESPONSE_QUEUE_URL,
 *   APPROVAL_QUEUE_URL, ARTIFACTS_BUCKET, AUDIT_TABLE, PIPELINE_STATE_TABLE,
 *   CHECKPOINT_TABLE, CHECKPOINT_TOPIC_ARN, PIPELINE_COMPLETE_TOPIC_ARN,
 *   ERROR_ALERTS_TOPIC_ARN, SUBNET_A, SUBNET_B, SECURITY_GROUP,
 *   ENVIRONMENT, PROJECT_NAME
 */

const { ECSClient, RunTaskCommand, DescribeTasksCommand } = require('@aws-sdk/client-ecs');
const { DynamoDBClient } = require('@aws-sdk/client-dynamodb');
const { DynamoDBDocumentClient, PutCommand, GetCommand, UpdateCommand, QueryCommand } = require('@aws-sdk/lib-dynamodb');
const { SQSClient, SendMessageCommand } = require('@aws-sdk/client-sqs');
const { SNSClient, PublishCommand } = require('@aws-sdk/client-sns');
const { S3Client, PutObjectCommand } = require('@aws-sdk/client-s3');
const crypto = require('crypto');

// --- AWS Clients ---
const ecs = new ECSClient({});
const dynamoDb = DynamoDBDocumentClient.from(new DynamoDBClient({}));
const sqs = new SQSClient({});
const sns = new SNSClient({});
const s3 = new S3Client({});

// --- Environment ---
const {
  ECS_CLUSTER,
  TASK_DEFINITION,
  DISPATCH_QUEUE_URL,
  RESPONSE_QUEUE_URL,
  APPROVAL_QUEUE_URL,
  ARTIFACTS_BUCKET,
  AUDIT_TABLE,
  PIPELINE_STATE_TABLE,
  CHECKPOINT_TABLE,
  CHECKPOINT_TOPIC_ARN,
  PIPELINE_COMPLETE_TOPIC_ARN,
  ERROR_ALERTS_TOPIC_ARN,
  SUBNET_A,
  SUBNET_B,
  SECURITY_GROUP,
  ENVIRONMENT,
  PROJECT_NAME,
} = process.env;

// --- Pipeline Definition ---
// 10 phases, 24 steps, 9 checkpoints
const PIPELINE_PHASES = [
  {
    phase: 1,
    name: 'Requirements',
    steps: [
      { step: 1, name: 'Stakeholder interviews', agents: ['business-analyst'] },
      { step: 2, name: 'Requirements document', agents: ['business-analyst'] },
      { step: 3, name: 'Acceptance criteria', agents: ['business-analyst', 'architect'] },
    ],
    checkpoint: {
      name: 'Requirements Approval',
      description: 'Review and approve the requirements document and acceptance criteria.',
      approvers: ['architect', 'admin'],
    },
  },
  {
    phase: 2,
    name: 'Architecture',
    steps: [
      { step: 4, name: 'System design', agents: ['architect'] },
      { step: 5, name: 'Architecture Decision Records', agents: ['architect', 'tech-writer'] },
    ],
    checkpoint: {
      name: 'Architecture Review',
      description: 'Review system design, ADRs, and technology choices.',
      approvers: ['architect', 'admin'],
    },
  },
  {
    phase: 3,
    name: 'Planning',
    steps: [
      { step: 6, name: 'Sprint planning', agents: ['tech-lead', 'project-manager'] },
      { step: 7, name: 'Task breakdown', agents: ['tech-lead'] },
    ],
    checkpoint: {
      name: 'Sprint Plan Approval',
      description: 'Approve sprint plan, task assignments, and timeline.',
      approvers: ['project-manager', 'admin'],
    },
  },
  {
    phase: 4,
    name: 'Backend Development',
    steps: [
      { step: 8, name: 'API design', agents: ['dev-backend', 'architect'] },
      { step: 9, name: 'Backend implementation', agents: ['dev-backend'] },
      { step: 10, name: 'Database migrations', agents: ['dev-backend'] },
    ],
    checkpoint: {
      name: 'Backend PR Review',
      description: 'Review backend code, API contracts, and database changes.',
      approvers: ['architect', 'tech-lead', 'admin'],
    },
  },
  {
    phase: 5,
    name: 'Frontend Development',
    steps: [
      { step: 11, name: 'UI/UX design review', agents: ['dev-frontend'] },
      { step: 12, name: 'Frontend implementation', agents: ['dev-frontend'] },
      { step: 13, name: 'Responsive testing', agents: ['dev-frontend', 'qa-engineer'] },
    ],
    checkpoint: {
      name: 'Frontend PR Review',
      description: 'Review frontend code, UI/UX implementation, and responsive behavior.',
      approvers: ['architect', 'tech-lead', 'admin'],
    },
  },
  {
    phase: 6,
    name: 'CLI Development',
    steps: [
      { step: 14, name: 'CLI commands implementation', agents: ['dev-cli'] },
      { step: 15, name: 'CLI testing', agents: ['dev-cli', 'qa-engineer'] },
    ],
    checkpoint: null, // No checkpoint for CLI phase
  },
  {
    phase: 7,
    name: 'Integration',
    steps: [
      { step: 16, name: 'API integration testing', agents: ['dev-backend', 'dev-frontend'] },
      { step: 17, name: 'End-to-end testing', agents: ['qa-engineer', 'tech-lead'] },
    ],
    checkpoint: {
      name: 'Integration Approval',
      description: 'Approve integration test results and system behavior.',
      approvers: ['tech-lead', 'architect', 'admin'],
    },
  },
  {
    phase: 8,
    name: 'Quality Assurance',
    steps: [
      { step: 18, name: 'Test strategy execution', agents: ['qa-engineer'] },
      { step: 19, name: 'Performance testing', agents: ['qa-engineer'] },
      { step: 20, name: 'Security testing', agents: ['qa-engineer', 'architect'] },
    ],
    checkpoint: {
      name: 'QA Sign-off',
      description: 'Review test results, coverage, performance benchmarks, and security findings.',
      approvers: ['qa-engineer', 'tech-lead', 'admin'],
    },
  },
  {
    phase: 9,
    name: 'Documentation',
    steps: [
      { step: 21, name: 'API documentation', agents: ['tech-writer'] },
      { step: 22, name: 'Runbooks and ADRs', agents: ['tech-writer', 'architect'] },
      { step: 23, name: 'User guides', agents: ['tech-writer'] },
    ],
    checkpoint: {
      name: 'Documentation Review',
      description: 'Review all documentation for accuracy, completeness, and clarity.',
      approvers: ['architect', 'tech-lead', 'admin'],
    },
  },
  {
    phase: 10,
    name: 'Release',
    steps: [
      { step: 24, name: 'Release preparation', agents: ['project-manager', 'architect', 'tech-lead'] },
    ],
    checkpoint: {
      name: 'Go/No-Go Decision',
      description: 'Final release decision based on all previous phase outcomes.',
      approvers: ['project-manager', 'architect', 'admin'],
    },
  },
];

// --- Model Tier Routing ---
const MODEL_TIERS = {
  architect: 'opus',
  'tech-lead': 'opus',
  'business-analyst': 'sonnet',
  'dev-backend': 'sonnet',
  'dev-frontend': 'sonnet',
  'dev-cli': 'sonnet',
  'qa-engineer': 'sonnet',
  'tech-writer': 'haiku',
  'project-manager': 'haiku',
};

// ==============================================================================
// Main Handler
// ==============================================================================

exports.handler = async (event) => {
  console.log('Pipeline Runner invoked:', JSON.stringify(event));

  try {
    const body = typeof event.body === 'string' ? JSON.parse(event.body) : event;
    const { action = 'start' } = body;

    switch (action) {
      case 'start':
        return await startPipeline(body);
      case 'resume':
        return await resumePipeline(body);
      case 'status':
        return await getPipelineStatus(body);
      case 'cancel':
        return await cancelPipeline(body);
      default:
        return response(400, { error: `Unknown action: ${action}` });
    }
  } catch (error) {
    console.error('Pipeline Runner error:', error);

    await publishError(error.message, event);
    return response(500, { error: 'Internal pipeline error', message: error.message });
  }
};

// ==============================================================================
// Pipeline Lifecycle
// ==============================================================================

async function startPipeline(config) {
  const pipelineId = `pipe-${Date.now()}-${crypto.randomBytes(4).toString('hex')}`;
  const now = new Date().toISOString();

  const { squadName, squadConfig, startFromPhase = 1 } = config;

  if (!squadName) {
    return response(400, { error: 'squadName is required' });
  }

  // Initialize pipeline state
  const pipelineState = {
    pipelineId,
    squadName,
    squadConfig: squadConfig || {},
    status: 'running',
    currentPhase: startFromPhase,
    currentStep: PIPELINE_PHASES[startFromPhase - 1].steps[0].step,
    startedAt: now,
    updatedAt: now,
    completedPhases: [],
    checkpointsPassed: [],
    ttl: Math.floor(Date.now() / 1000) + 30 * 24 * 3600, // 30 days TTL
  };

  await dynamoDb.send(new PutCommand({
    TableName: PIPELINE_STATE_TABLE,
    Item: pipelineState,
  }));

  await writeAuditEntry(pipelineId, 'PIPELINE_STARTED', {
    squadName,
    environment: ENVIRONMENT,
    totalPhases: PIPELINE_PHASES.length,
    totalSteps: 24,
    totalCheckpoints: 9,
  });

  // Begin executing from the specified phase
  await executePhase(pipelineId, startFromPhase, pipelineState);

  return response(200, {
    pipelineId,
    status: 'running',
    message: `Pipeline started for squad '${squadName}' at phase ${startFromPhase}`,
  });
}

async function resumePipeline(body) {
  const { pipelineId, fromPhase } = body;

  if (!pipelineId) {
    return response(400, { error: 'pipelineId is required' });
  }

  const state = await getPipelineState(pipelineId);
  if (!state) {
    return response(404, { error: `Pipeline ${pipelineId} not found` });
  }

  if (state.status !== 'waiting_approval') {
    return response(400, { error: `Pipeline is in '${state.status}' state, cannot resume` });
  }

  const nextPhase = fromPhase || state.currentPhase + 1;

  if (nextPhase > PIPELINE_PHASES.length) {
    await completePipeline(pipelineId, state);
    return response(200, { pipelineId, status: 'completed', message: 'Pipeline completed successfully' });
  }

  await updatePipelineState(pipelineId, {
    status: 'running',
    currentPhase: nextPhase,
    currentStep: PIPELINE_PHASES[nextPhase - 1].steps[0].step,
  });

  await writeAuditEntry(pipelineId, 'PIPELINE_RESUMED', { fromPhase: nextPhase });
  await executePhase(pipelineId, nextPhase, state);

  return response(200, { pipelineId, status: 'running', currentPhase: nextPhase });
}

async function cancelPipeline(body) {
  const { pipelineId, reason } = body;

  if (!pipelineId) {
    return response(400, { error: 'pipelineId is required' });
  }

  await updatePipelineState(pipelineId, {
    status: 'cancelled',
    cancelledAt: new Date().toISOString(),
    cancelReason: reason || 'Cancelled by user',
  });

  await writeAuditEntry(pipelineId, 'PIPELINE_CANCELLED', { reason });

  return response(200, { pipelineId, status: 'cancelled' });
}

async function getPipelineStatus(body) {
  const { pipelineId } = body;

  if (!pipelineId) {
    return response(400, { error: 'pipelineId is required' });
  }

  const state = await getPipelineState(pipelineId);
  if (!state) {
    return response(404, { error: `Pipeline ${pipelineId} not found` });
  }

  return response(200, state);
}

// ==============================================================================
// Phase Execution
// ==============================================================================

async function executePhase(pipelineId, phaseNumber, pipelineState) {
  const phase = PIPELINE_PHASES[phaseNumber - 1];

  if (!phase) {
    await completePipeline(pipelineId, pipelineState);
    return;
  }

  console.log(`Executing phase ${phaseNumber}: ${phase.name}`);
  await writeAuditEntry(pipelineId, 'PHASE_STARTED', {
    phase: phaseNumber,
    phaseName: phase.name,
    stepsCount: phase.steps.length,
  });

  // Execute each step in the phase sequentially
  for (const step of phase.steps) {
    await executeStep(pipelineId, phase, step);
  }

  // If phase has a checkpoint, pause for human approval
  if (phase.checkpoint) {
    await createCheckpoint(pipelineId, phase);
  } else {
    // No checkpoint — move to next phase
    await updatePipelineState(pipelineId, {
      completedPhases: [...(pipelineState.completedPhases || []), phaseNumber],
      currentPhase: phaseNumber + 1,
    });

    if (phaseNumber < PIPELINE_PHASES.length) {
      await executePhase(pipelineId, phaseNumber + 1, pipelineState);
    } else {
      await completePipeline(pipelineId, pipelineState);
    }
  }
}

async function executeStep(pipelineId, phase, step) {
  console.log(`  Step ${step.step}: ${step.name} (agents: ${step.agents.join(', ')})`);

  await writeAuditEntry(pipelineId, 'STEP_STARTED', {
    phase: phase.phase,
    step: step.step,
    stepName: step.name,
    agents: step.agents,
  });

  // Dispatch each agent for this step
  const agentTasks = step.agents.map((agentRole) =>
    dispatchAgent(pipelineId, phase, step, agentRole)
  );

  const results = await Promise.allSettled(agentTasks);

  // Check for failures
  const failures = results.filter((r) => r.status === 'rejected');
  if (failures.length > 0) {
    console.error(`Step ${step.step} had ${failures.length} agent failure(s)`);
    await writeAuditEntry(pipelineId, 'STEP_PARTIAL_FAILURE', {
      step: step.step,
      failures: failures.map((f) => f.reason?.message || 'Unknown error'),
    });
  }

  await writeAuditEntry(pipelineId, 'STEP_COMPLETED', {
    phase: phase.phase,
    step: step.step,
    stepName: step.name,
    agentResults: results.map((r, i) => ({
      agent: step.agents[i],
      status: r.status,
      taskArn: r.status === 'fulfilled' ? r.value?.taskArn : null,
    })),
  });

  // Update pipeline state
  await updatePipelineState(pipelineId, { currentStep: step.step });
}

// ==============================================================================
// Agent Dispatch
// ==============================================================================

async function dispatchAgent(pipelineId, phase, step, agentRole) {
  const modelTier = MODEL_TIERS[agentRole] || 'sonnet';
  const taskId = `task-${Date.now()}-${crypto.randomBytes(4).toString('hex')}`;

  // Send dispatch message to SQS
  const message = {
    taskId,
    pipelineId,
    phase: phase.phase,
    phaseName: phase.name,
    step: step.step,
    stepName: step.name,
    agentRole,
    modelTier,
    timestamp: new Date().toISOString(),
  };

  await sqs.send(new SendMessageCommand({
    QueueUrl: DISPATCH_QUEUE_URL,
    MessageBody: JSON.stringify(message),
    MessageGroupId: pipelineId,
    MessageAttributes: {
      agentRole: { DataType: 'String', StringValue: agentRole },
      modelTier: { DataType: 'String', StringValue: modelTier },
      pipelineId: { DataType: 'String', StringValue: pipelineId },
    },
  }));

  // Run ECS Fargate task
  const ecsResult = await ecs.send(new RunTaskCommand({
    cluster: ECS_CLUSTER,
    taskDefinition: TASK_DEFINITION,
    launchType: 'FARGATE',
    count: 1,
    networkConfiguration: {
      awsvpcConfiguration: {
        subnets: [SUBNET_A, SUBNET_B],
        securityGroups: [SECURITY_GROUP],
        assignPublicIp: 'DISABLED',
      },
    },
    overrides: {
      containerOverrides: [
        {
          name: 'agent',
          environment: [
            { name: 'AGENT_ROLE', value: agentRole },
            { name: 'MODEL_TIER', value: modelTier },
            { name: 'PIPELINE_ID', value: pipelineId },
            { name: 'PHASE', value: String(phase.phase) },
            { name: 'STEP', value: String(step.step) },
            { name: 'TASK_ID', value: taskId },
          ],
        },
      ],
    },
    tags: [
      { key: 'PipelineId', value: pipelineId },
      { key: 'AgentRole', value: agentRole },
      { key: 'Phase', value: String(phase.phase) },
      { key: 'Step', value: String(step.step) },
    ],
  }));

  const taskArn = ecsResult.tasks?.[0]?.taskArn;

  await writeAuditEntry(pipelineId, 'AGENT_DISPATCHED', {
    taskId,
    agentRole,
    modelTier,
    phase: phase.phase,
    step: step.step,
    ecsTaskArn: taskArn,
  });

  console.log(`    Agent '${agentRole}' dispatched (model: ${modelTier}, task: ${taskArn})`);

  return { taskId, taskArn, agentRole };
}

// ==============================================================================
// Checkpoints
// ==============================================================================

async function createCheckpoint(pipelineId, phase) {
  const checkpointId = `chk-${pipelineId}-phase${phase.phase}`;
  const now = new Date().toISOString();

  const checkpoint = {
    checkpointId,
    pipelineId,
    phase: phase.phase,
    phaseName: phase.name,
    checkpointName: phase.checkpoint.name,
    description: phase.checkpoint.description,
    approvers: phase.checkpoint.approvers,
    status: 'pending',
    createdAt: now,
    ttl: Math.floor(Date.now() / 1000) + 7 * 24 * 3600, // 7 days TTL
  };

  // Save checkpoint to DynamoDB
  await dynamoDb.send(new PutCommand({
    TableName: CHECKPOINT_TABLE,
    Item: checkpoint,
  }));

  // Update pipeline state to waiting
  await updatePipelineState(pipelineId, {
    status: 'waiting_approval',
    currentCheckpoint: checkpointId,
  });

  // Send approval request to SQS
  await sqs.send(new SendMessageCommand({
    QueueUrl: APPROVAL_QUEUE_URL,
    MessageBody: JSON.stringify(checkpoint),
    MessageAttributes: {
      checkpointId: { DataType: 'String', StringValue: checkpointId },
      pipelineId: { DataType: 'String', StringValue: pipelineId },
    },
  }));

  // Send SNS notification
  await sns.send(new PublishCommand({
    TopicArn: CHECKPOINT_TOPIC_ARN,
    Subject: `[ForgeSquad] Checkpoint: ${phase.checkpoint.name}`,
    Message: JSON.stringify({
      checkpointId,
      pipelineId,
      phase: phase.phase,
      phaseName: phase.name,
      checkpointName: phase.checkpoint.name,
      description: phase.checkpoint.description,
      approvers: phase.checkpoint.approvers,
      environment: ENVIRONMENT,
      timestamp: now,
      approvalUrl: `https://${PROJECT_NAME}-api.example.com/approval?checkpointId=${checkpointId}`,
    }, null, 2),
    MessageAttributes: {
      environment: { DataType: 'String', StringValue: ENVIRONMENT },
      checkpointName: { DataType: 'String', StringValue: phase.checkpoint.name },
    },
  }));

  await writeAuditEntry(pipelineId, 'CHECKPOINT_CREATED', {
    checkpointId,
    checkpointName: phase.checkpoint.name,
    phase: phase.phase,
    approvers: phase.checkpoint.approvers,
  });

  console.log(`Checkpoint created: ${phase.checkpoint.name} (pipeline paused)`);
}

// ==============================================================================
// Pipeline Completion
// ==============================================================================

async function completePipeline(pipelineId, pipelineState) {
  const now = new Date().toISOString();

  await updatePipelineState(pipelineId, {
    status: 'completed',
    completedAt: now,
    completedPhases: PIPELINE_PHASES.map((p) => p.phase),
  });

  await writeAuditEntry(pipelineId, 'PIPELINE_COMPLETED', {
    squadName: pipelineState.squadName,
    startedAt: pipelineState.startedAt,
    completedAt: now,
    totalPhases: PIPELINE_PHASES.length,
    totalSteps: 24,
  });

  // Notify completion
  await sns.send(new PublishCommand({
    TopicArn: PIPELINE_COMPLETE_TOPIC_ARN,
    Subject: `[ForgeSquad] Pipeline Completed: ${pipelineState.squadName}`,
    Message: JSON.stringify({
      pipelineId,
      squadName: pipelineState.squadName,
      status: 'completed',
      startedAt: pipelineState.startedAt,
      completedAt: now,
      environment: ENVIRONMENT,
    }, null, 2),
  }));

  console.log(`Pipeline ${pipelineId} completed successfully.`);
}

// ==============================================================================
// DynamoDB Helpers
// ==============================================================================

async function getPipelineState(pipelineId) {
  const result = await dynamoDb.send(new GetCommand({
    TableName: PIPELINE_STATE_TABLE,
    Key: { pipelineId },
  }));
  return result.Item;
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
      agentRole: details?.agentRole || details?.agents?.[0] || 'system',
    },
    // Append-only: condition ensures we never overwrite an existing entry
    ConditionExpression: 'attribute_not_exists(pipelineId) AND attribute_not_exists(#ts)',
    ExpressionAttributeNames: { '#ts': 'timestamp' },
  }));
}

// ==============================================================================
// Error Handling
// ==============================================================================

async function publishError(message, context) {
  try {
    await sns.send(new PublishCommand({
      TopicArn: ERROR_ALERTS_TOPIC_ARN,
      Subject: `[ForgeSquad] Pipeline Error — ${ENVIRONMENT}`,
      Message: JSON.stringify({
        error: message,
        context: typeof context === 'object' ? JSON.stringify(context).substring(0, 1000) : String(context),
        environment: ENVIRONMENT,
        timestamp: new Date().toISOString(),
      }, null, 2),
    }));
  } catch (snsError) {
    console.error('Failed to publish error alert:', snsError);
  }
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
