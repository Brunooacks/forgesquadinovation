// ============================================================================
// ForgeSquad — Azure Bicep Template
// Infraestrutura completa para o framework de orquestracao multi-agente
// Version: 1.0 | Date: 2026-03-20
// ============================================================================

// ─── Parameters / Parametros ────────────────────────────────────────────────

@description('Azure region for all resources')
param location string = resourceGroup().location

@description('Environment name (dev, staging, prod)')
@allowed(['dev', 'staging', 'prod'])
param environment string = 'dev'

@description('Project name prefix for all resources')
param projectName string = 'forgesquad'

@description('Container image for agent runtime')
param agentContainerImage string = 'ghcr.io/forgesquad/agent-runtime:latest'

@description('Cosmos DB throughput mode')
@allowed(['Serverless', 'Autoscale'])
param cosmosDbMode string = 'Serverless'

@description('Cosmos DB max autoscale throughput (only used if mode is Autoscale)')
param cosmosDbMaxThroughput int = 4000

@description('API Management SKU')
@allowed(['Developer', 'Standard', 'Premium'])
param apimSku string = 'Developer'

@description('Enable Private Link endpoints (recommended for prod)')
param enablePrivateLink bool = false

@description('Enable Front Door with WAF')
param enableFrontDoor bool = false

@description('Tags applied to all resources')
param tags object = {
  project: 'ForgeSquad'
  environment: environment
  managedBy: 'Bicep'
}

// ─── Variables ──────────────────────────────────────────────────────────────

var suffix = '${projectName}-${environment}'
var uniqueSuffix = uniqueString(resourceGroup().id, projectName)

// Naming conventions
var vnetName = 'vnet-${suffix}'
var containerAppsEnvName = 'cae-${suffix}'
var functionAppName = 'func-${suffix}'
var apimName = 'apim-${suffix}'
var cosmosDbAccountName = 'cosmos-${projectName}-${uniqueSuffix}'
var storageAccountName = 'st${replace(projectName, '-', '')}${uniqueSuffix}'
var serviceBusName = 'sb-${suffix}'
var eventGridTopicName = 'evgt-${suffix}'
var keyVaultName = 'kv-${projectName}-${uniqueSuffix}'
var appInsightsName = 'appi-${suffix}'
var logAnalyticsName = 'log-${suffix}'
var frontDoorName = 'fd-${suffix}'

// Network CIDR blocks
var vnetAddressPrefix = '10.0.0.0/16'
var snetContainerApps = '10.0.1.0/23'
var snetFunctions = '10.0.4.0/24'
var snetApim = '10.0.5.0/24'
var snetPrivateEndpoints = '10.0.6.0/24'

// ─── Log Analytics Workspace ────────────────────────────────────────────────

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: logAnalyticsName
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: environment == 'prod' ? 90 : 30
  }
}

// ─── Application Insights ───────────────────────────────────────────────────

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  tags: tags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalytics.id
    IngestionMode: 'LogAnalytics'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

// ─── Virtual Network / Rede Virtual ─────────────────────────────────────────

resource vnet 'Microsoft.Network/virtualNetworks@2024-01-01' = {
  name: vnetName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: 'snet-container-apps'
        properties: {
          addressPrefix: snetContainerApps
          delegations: []
          networkSecurityGroup: {
            id: nsgContainerApps.id
          }
        }
      }
      {
        name: 'snet-functions'
        properties: {
          addressPrefix: snetFunctions
          delegations: [
            {
              name: 'Microsoft.Web.serverFarms'
              properties: {
                serviceName: 'Microsoft.Web/serverFarms'
              }
            }
          ]
          networkSecurityGroup: {
            id: nsgFunctions.id
          }
        }
      }
      {
        name: 'snet-apim'
        properties: {
          addressPrefix: snetApim
          networkSecurityGroup: {
            id: nsgApim.id
          }
        }
      }
      {
        name: 'snet-private-endpoints'
        properties: {
          addressPrefix: snetPrivateEndpoints
          privateEndpointNetworkPolicies: 'Disabled'
          networkSecurityGroup: {
            id: nsgPrivateEndpoints.id
          }
        }
      }
    ]
  }
}

// ─── Network Security Groups ────────────────────────────────────────────────

resource nsgContainerApps 'Microsoft.Network/networkSecurityGroups@2024-01-01' = {
  name: 'nsg-container-apps-${suffix}'
  location: location
  tags: tags
  properties: {
    securityRules: [
      {
        name: 'AllowHTTPSOutbound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Outbound'
        }
      }
      {
        name: 'DenyAllInbound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 4096
          direction: 'Inbound'
        }
      }
    ]
  }
}

resource nsgFunctions 'Microsoft.Network/networkSecurityGroups@2024-01-01' = {
  name: 'nsg-functions-${suffix}'
  location: location
  tags: tags
  properties: {
    securityRules: [
      {
        name: 'AllowVNetInbound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'DenyPublicInbound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 4096
          direction: 'Inbound'
        }
      }
    ]
  }
}

resource nsgApim 'Microsoft.Network/networkSecurityGroups@2024-01-01' = {
  name: 'nsg-apim-${suffix}'
  location: location
  tags: tags
  properties: {
    securityRules: [
      {
        name: 'AllowFrontDoorInbound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'AzureFrontDoor.Backend'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowAPIMManagement'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3443'
          sourceAddressPrefix: 'ApiManagement'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 110
          direction: 'Inbound'
        }
      }
    ]
  }
}

resource nsgPrivateEndpoints 'Microsoft.Network/networkSecurityGroups@2024-01-01' = {
  name: 'nsg-pe-${suffix}'
  location: location
  tags: tags
  properties: {
    securityRules: [
      {
        name: 'AllowVNetOnly'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'DenyAllInbound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 4096
          direction: 'Inbound'
        }
      }
    ]
  }
}

// ─── Azure Key Vault / Cofre de Chaves ──────────────────────────────────────

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
  location: location
  tags: tags
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    enableRbacAuthorization: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    enablePurgeProtection: true
    networkAcls: {
      defaultAction: enablePrivateLink ? 'Deny' : 'Allow'
      bypass: 'AzureServices'
    }
  }
}

// ─── Azure Cosmos DB / Banco de Dados ───────────────────────────────────────

resource cosmosDbAccount 'Microsoft.DocumentDB/databaseAccounts@2024-02-15-preview' = {
  name: cosmosDbAccountName
  location: location
  tags: tags
  kind: 'GlobalDocumentDB'
  properties: {
    databaseAccountOfferType: 'Standard'
    capabilities: cosmosDbMode == 'Serverless' ? [
      {
        name: 'EnableServerless'
      }
    ] : []
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
    }
    locations: [
      {
        locationName: location
        failoverPriority: 0
        isZoneRedundant: environment == 'prod'
      }
    ]
    publicNetworkAccess: enablePrivateLink ? 'Disabled' : 'Enabled'
    networkAclBypass: 'AzureServices'
    disableLocalAuth: true
  }
}

resource cosmosDb 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2024-02-15-preview' = {
  parent: cosmosDbAccount
  name: 'forgesquad-db'
  properties: {
    resource: {
      id: 'forgesquad-db'
    }
  }
}

// Audit Trail container (append-only)
resource cosmosContainerAudit 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2024-02-15-preview' = {
  parent: cosmosDb
  name: 'audit-trail'
  properties: {
    resource: {
      id: 'audit-trail'
      partitionKey: {
        paths: ['/squadId']
        kind: 'Hash'
        version: 2
      }
      indexingPolicy: {
        indexingMode: 'consistent'
        automatic: true
        includedPaths: [
          { path: '/squadId/?' }
          { path: '/phase/?' }
          { path: '/step/?' }
          { path: '/timestamp/?' }
          { path: '/eventType/?' }
        ]
        excludedPaths: [
          { path: '/*' }
        ]
      }
      defaultTtl: -1
    }
    options: cosmosDbMode == 'Autoscale' ? {
      autoscaleSettings: {
        maxThroughput: cosmosDbMaxThroughput
      }
    } : {}
  }
}

// Pipeline state container
resource cosmosContainerPipeline 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2024-02-15-preview' = {
  parent: cosmosDb
  name: 'pipeline-state'
  properties: {
    resource: {
      id: 'pipeline-state'
      partitionKey: {
        paths: ['/squadId']
        kind: 'Hash'
        version: 2
      }
    }
    options: cosmosDbMode == 'Autoscale' ? {
      autoscaleSettings: {
        maxThroughput: cosmosDbMaxThroughput
      }
    } : {}
  }
}

// Checkpoint container
resource cosmosContainerCheckpoints 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2024-02-15-preview' = {
  parent: cosmosDb
  name: 'checkpoints'
  properties: {
    resource: {
      id: 'checkpoints'
      partitionKey: {
        paths: ['/squadId']
        kind: 'Hash'
        version: 2
      }
      defaultTtl: 2592000 // 30 days
    }
    options: cosmosDbMode == 'Autoscale' ? {
      autoscaleSettings: {
        maxThroughput: cosmosDbMaxThroughput
      }
    } : {}
  }
}

// ─── Azure Blob Storage / Armazenamento ─────────────────────────────────────

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageAccountName
  location: location
  tags: tags
  sku: {
    name: environment == 'prod' ? 'Standard_GRS' : 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: false
    networkAcls: {
      defaultAction: enablePrivateLink ? 'Deny' : 'Allow'
      bypass: 'AzureServices'
    }
    isHnsEnabled: false
  }
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2023-05-01' = {
  parent: storageAccount
  name: 'default'
  properties: {
    isVersioningEnabled: true
    changeFeed: {
      enabled: true
      retentionInDays: environment == 'prod' ? 90 : 30
    }
    deleteRetentionPolicy: {
      enabled: true
      days: 30
    }
    containerDeleteRetentionPolicy: {
      enabled: true
      days: 30
    }
  }
}

resource artifactsContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = {
  parent: blobService
  name: 'artifacts'
  properties: {
    publicAccess: 'None'
    metadata: {
      purpose: 'ForgeSquad pipeline artifacts with SHA-256 integrity'
    }
  }
}

resource reportsContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = {
  parent: blobService
  name: 'reports'
  properties: {
    publicAccess: 'None'
  }
}

resource pipelineStateContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = {
  parent: blobService
  name: 'pipeline-state'
  properties: {
    publicAccess: 'None'
  }
}

// ─── Azure Service Bus / Barramento de Servicos ─────────────────────────────

resource serviceBus 'Microsoft.ServiceBus/namespaces@2022-10-01-preview' = {
  name: serviceBusName
  location: location
  tags: tags
  sku: {
    name: environment == 'prod' ? 'Premium' : 'Standard'
    tier: environment == 'prod' ? 'Premium' : 'Standard'
    capacity: environment == 'prod' ? 1 : 0
  }
  properties: {
    publicNetworkAccess: enablePrivateLink ? 'Disabled' : 'Enabled'
    disableLocalAuth: true
    minimumTlsVersion: '1.2'
  }
}

// Agent communication topic
resource topicAgentMessages 'Microsoft.ServiceBus/namespaces/topics@2022-10-01-preview' = {
  parent: serviceBus
  name: 'agent-messages'
  properties: {
    maxSizeInMegabytes: 1024
    defaultMessageTimeToLive: 'P7D'
    enablePartitioning: true
  }
}

// Per-agent subscriptions
var agentNames = [
  'architect'
  'tech-lead'
  'business-analyst'
  'dev-backend'
  'dev-frontend'
  'qa-engineer'
  'tech-writer'
  'project-manager'
  'devops'
]

resource agentSubscriptions 'Microsoft.ServiceBus/namespaces/topics/subscriptions@2022-10-01-preview' = [
  for agent in agentNames: {
    parent: topicAgentMessages
    name: 'sub-${agent}'
    properties: {
      lockDuration: 'PT5M'
      maxDeliveryCount: 5
      defaultMessageTimeToLive: 'P7D'
      deadLetteringOnMessageExpiration: true
    }
  }
]

// Approval queue (human checkpoints)
resource queueApprovals 'Microsoft.ServiceBus/namespaces/queues@2022-10-01-preview' = {
  parent: serviceBus
  name: 'approval-requests'
  properties: {
    lockDuration: 'PT5M'
    maxSizeInMegabytes: 1024
    requiresDuplicateDetection: true
    duplicateDetectionHistoryTimeWindow: 'PT10M'
    maxDeliveryCount: 3
    deadLetteringOnMessageExpiration: true
    defaultMessageTimeToLive: 'P7D'
  }
}

// Approval responses queue
resource queueApprovalResponses 'Microsoft.ServiceBus/namespaces/queues@2022-10-01-preview' = {
  parent: serviceBus
  name: 'approval-responses'
  properties: {
    lockDuration: 'PT5M'
    maxSizeInMegabytes: 1024
    maxDeliveryCount: 3
    deadLetteringOnMessageExpiration: true
    defaultMessageTimeToLive: 'P7D'
  }
}

// Pipeline commands queue
resource queuePipelineCommands 'Microsoft.ServiceBus/namespaces/queues@2022-10-01-preview' = {
  parent: serviceBus
  name: 'pipeline-commands'
  properties: {
    lockDuration: 'PT1M'
    maxSizeInMegabytes: 1024
    maxDeliveryCount: 5
    deadLetteringOnMessageExpiration: true
  }
}

// ─── Azure Event Grid / Grade de Eventos ────────────────────────────────────

resource eventGridTopic 'Microsoft.EventGrid/topics@2024-06-01-preview' = {
  name: eventGridTopicName
  location: location
  tags: tags
  properties: {
    inputSchema: 'EventGridSchema'
    publicNetworkAccess: 'Enabled'
  }
  identity: {
    type: 'SystemAssigned'
  }
}

// ─── Azure Container Apps Environment / Ambiente de Containers ──────────────

resource containerAppsEnv 'Microsoft.App/managedEnvironments@2024-03-01' = {
  name: containerAppsEnvName
  location: location
  tags: tags
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalytics.properties.customerId
        sharedKey: logAnalytics.listKeys().primarySharedKey
      }
    }
    vnetConfiguration: {
      infrastructureSubnetId: vnet.properties.subnets[0].id
      internal: false
    }
    daprAIInstrumentationKey: appInsights.properties.InstrumentationKey
    workloadProfiles: environment == 'prod' ? [
      {
        name: 'Consumption'
        workloadProfileType: 'Consumption'
      }
      {
        name: 'Dedicated-D4'
        workloadProfileType: 'D4'
        minimumCount: 1
        maximumCount: 3
      }
    ] : [
      {
        name: 'Consumption'
        workloadProfileType: 'Consumption'
      }
    ]
  }
}

// Dapr Component: Service Bus pub/sub
resource daprPubsub 'Microsoft.App/managedEnvironments/daprComponents@2024-03-01' = {
  parent: containerAppsEnv
  name: 'forgesquad-pubsub'
  properties: {
    componentType: 'pubsub.azure.servicebus.topics'
    version: 'v1'
    metadata: [
      {
        name: 'connectionString'
        secretRef: 'sb-connection'
      }
      {
        name: 'maxConcurrentHandlers'
        value: '5'
      }
    ]
    secrets: [
      {
        name: 'sb-connection'
        keyVaultUrl: '${keyVault.properties.vaultUri}secrets/servicebus-connection'
        identity: 'system'
      }
    ]
    scopes: [
      'agent-runtime'
      'pipeline-runner'
    ]
  }
}

// Dapr Component: Cosmos DB state store
resource daprStateStore 'Microsoft.App/managedEnvironments/daprComponents@2024-03-01' = {
  parent: containerAppsEnv
  name: 'forgesquad-statestore'
  properties: {
    componentType: 'state.azure.cosmosdb'
    version: 'v1'
    metadata: [
      {
        name: 'url'
        value: cosmosDbAccount.properties.documentEndpoint
      }
      {
        name: 'database'
        value: 'forgesquad-db'
      }
      {
        name: 'collection'
        value: 'pipeline-state'
      }
    ]
    scopes: [
      'agent-runtime'
      'pipeline-runner'
    ]
  }
}

// Agent Runtime Container App
resource agentRuntime 'Microsoft.App/containerApps@2024-03-01' = {
  name: 'agent-runtime-${suffix}'
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    managedEnvironmentId: containerAppsEnv.id
    workloadProfileName: 'Consumption'
    configuration: {
      ingress: {
        external: false
        targetPort: 8080
        transport: 'http'
        corsPolicy: {
          allowedOrigins: ['*']
          allowedMethods: ['GET', 'POST', 'PUT']
          allowedHeaders: ['*']
        }
      }
      dapr: {
        enabled: true
        appId: 'agent-runtime'
        appPort: 8080
        appProtocol: 'http'
        enableApiLogging: true
      }
      secrets: [
        {
          name: 'appinsights-key'
          keyVaultUrl: '${keyVault.properties.vaultUri}secrets/appinsights-instrumentation-key'
          identity: 'system'
        }
        {
          name: 'openai-api-key'
          keyVaultUrl: '${keyVault.properties.vaultUri}secrets/openai-api-key'
          identity: 'system'
        }
      ]
      registries: []
    }
    template: {
      containers: [
        {
          name: 'agent-runtime'
          image: agentContainerImage
          resources: {
            cpu: json('0.5')
            memory: '1Gi'
          }
          env: [
            { name: 'ENVIRONMENT', value: environment }
            { name: 'APPLICATIONINSIGHTS_CONNECTION_STRING', value: appInsights.properties.ConnectionString }
            { name: 'COSMOS_DB_ENDPOINT', value: cosmosDbAccount.properties.documentEndpoint }
            { name: 'COSMOS_DB_DATABASE', value: 'forgesquad-db' }
            { name: 'STORAGE_ACCOUNT_NAME', value: storageAccount.name }
            { name: 'EVENTGRID_TOPIC_ENDPOINT', value: eventGridTopic.properties.endpoint }
            { name: 'KEY_VAULT_URI', value: keyVault.properties.vaultUri }
            { name: 'OPENAI_API_KEY', secretRef: 'openai-api-key' }
            { name: 'MODEL_TIER_ARCHITECT', value: 'gpt-4o' }
            { name: 'MODEL_TIER_SENIOR', value: 'gpt-4o-mini' }
            { name: 'MODEL_TIER_STANDARD', value: 'gpt-4o-mini' }
            { name: 'AGENT_COUNT', value: '9' }
            { name: 'PIPELINE_PHASES', value: '10' }
            { name: 'PIPELINE_STEPS', value: '24' }
            { name: 'CHECKPOINTS', value: '9' }
          ]
          probes: [
            {
              type: 'Liveness'
              httpGet: {
                path: '/health'
                port: 8080
              }
              initialDelaySeconds: 10
              periodSeconds: 30
            }
            {
              type: 'Readiness'
              httpGet: {
                path: '/ready'
                port: 8080
              }
              initialDelaySeconds: 5
              periodSeconds: 10
            }
          ]
        }
      ]
      scale: {
        minReplicas: environment == 'prod' ? 1 : 0
        maxReplicas: environment == 'prod' ? 10 : 3
        rules: [
          {
            name: 'http-scaling'
            http: {
              metadata: {
                concurrentRequests: '10'
              }
            }
          }
          {
            name: 'servicebus-scaling'
            custom: {
              type: 'azure-servicebus'
              metadata: {
                topicName: 'agent-messages'
                subscriptionName: 'sub-architect'
                messageCount: '5'
              }
              auth: [
                {
                  secretRef: 'sb-connection'
                  triggerParameter: 'connection'
                }
              ]
            }
          }
        ]
      }
    }
  }
}

// ─── Azure Functions / Funcoes ──────────────────────────────────────────────

resource functionStorageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: 'stfunc${uniqueSuffix}'
  location: location
  tags: tags
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
  }
}

resource hostingPlan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: 'asp-${suffix}'
  location: location
  tags: tags
  sku: {
    name: environment == 'prod' ? 'EP1' : 'Y1'
    tier: environment == 'prod' ? 'ElasticPremium' : 'Dynamic'
  }
  properties: {
    reserved: false
  }
}

resource functionApp 'Microsoft.Web/sites@2023-12-01' = {
  name: functionAppName
  location: location
  tags: tags
  kind: 'functionapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: hostingPlan.id
    httpsOnly: true
    virtualNetworkSubnetId: vnet.properties.subnets[1].id
    siteConfig: {
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
      nodeVersion: '~20'
      appSettings: [
        { name: 'AzureWebJobsStorage', value: 'DefaultEndpointsProtocol=https;AccountName=${functionStorageAccount.name};EndpointSuffix=${az.environment().suffixes.storage};AccountKey=${functionStorageAccount.listKeys().keys[0].value}' }
        { name: 'FUNCTIONS_EXTENSION_VERSION', value: '~4' }
        { name: 'FUNCTIONS_WORKER_RUNTIME', value: 'node' }
        { name: 'WEBSITE_NODE_DEFAULT_VERSION', value: '~20' }
        { name: 'APPLICATIONINSIGHTS_CONNECTION_STRING', value: appInsights.properties.ConnectionString }
        { name: 'COSMOS_DB_ENDPOINT', value: cosmosDbAccount.properties.documentEndpoint }
        { name: 'COSMOS_DB_DATABASE', value: 'forgesquad-db' }
        { name: 'STORAGE_ACCOUNT_NAME', value: storageAccount.name }
        { name: 'SERVICEBUS_NAMESPACE', value: '${serviceBusName}.servicebus.windows.net' }
        { name: 'EVENTGRID_TOPIC_ENDPOINT', value: eventGridTopic.properties.endpoint }
        { name: 'KEY_VAULT_URI', value: keyVault.properties.vaultUri }
        { name: 'CONTAINER_APP_NAME', value: agentRuntime.name }
        { name: 'CONTAINER_APP_FQDN', value: agentRuntime.properties.configuration.ingress.fqdn }
      ]
    }
  }
}

// ─── API Management / Gerenciamento de API ──────────────────────────────────

resource apim 'Microsoft.ApiManagement/service@2023-09-01-preview' = {
  name: apimName
  location: location
  tags: tags
  sku: {
    name: apimSku
    capacity: apimSku == 'Developer' ? 1 : 1
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publisherEmail: 'forgesquad@nttdata.com'
    publisherName: 'ForgeSquad - NTT DATA'
    virtualNetworkType: 'External'
    virtualNetworkConfiguration: {
      subnetResourceId: vnet.properties.subnets[2].id
    }
  }
}

// Pipeline API
resource apiPipeline 'Microsoft.ApiManagement/service/apis@2023-09-01-preview' = {
  parent: apim
  name: 'forgesquad-pipeline'
  properties: {
    displayName: 'ForgeSquad Pipeline API'
    apiRevision: '1'
    path: 'pipeline'
    protocols: ['https']
    subscriptionRequired: true
    serviceUrl: 'https://${functionApp.properties.defaultHostName}/api'
  }
}

// Run Pipeline operation
resource operationRunPipeline 'Microsoft.ApiManagement/service/apis/operations@2023-09-01-preview' = {
  parent: apiPipeline
  name: 'run-pipeline'
  properties: {
    displayName: 'Run Pipeline'
    method: 'POST'
    urlTemplate: '/pipeline/run'
    description: 'Start a new ForgeSquad pipeline execution'
  }
}

// Get Pipeline Status operation
resource operationGetStatus 'Microsoft.ApiManagement/service/apis/operations@2023-09-01-preview' = {
  parent: apiPipeline
  name: 'get-status'
  properties: {
    displayName: 'Get Pipeline Status'
    method: 'GET'
    urlTemplate: '/pipeline/{squadId}/status'
    templateParameters: [
      {
        name: 'squadId'
        required: true
        type: 'string'
      }
    ]
  }
}

// Submit Approval operation
resource operationSubmitApproval 'Microsoft.ApiManagement/service/apis/operations@2023-09-01-preview' = {
  parent: apiPipeline
  name: 'submit-approval'
  properties: {
    displayName: 'Submit Checkpoint Approval'
    method: 'POST'
    urlTemplate: '/pipeline/{squadId}/approve'
    templateParameters: [
      {
        name: 'squadId'
        required: true
        type: 'string'
      }
    ]
  }
}

// Rate limiting policy
resource apimPolicy 'Microsoft.ApiManagement/service/apis/policies@2023-09-01-preview' = {
  parent: apiPipeline
  name: 'policy'
  properties: {
    value: '''
      <policies>
        <inbound>
          <base />
          <rate-limit calls="100" renewal-period="60" />
          <cors>
            <allowed-origins><origin>*</origin></allowed-origins>
            <allowed-methods><method>GET</method><method>POST</method><method>PUT</method></allowed-methods>
            <allowed-headers><header>*</header></allowed-headers>
          </cors>
          <validate-jwt header-name="Authorization" failed-validation-httpcode="401">
            <openid-config url="https://login.microsoftonline.com/{tenant}/.well-known/openid-configuration" />
            <audiences><audience>api://forgesquad</audience></audiences>
          </validate-jwt>
        </inbound>
        <backend><base /></backend>
        <outbound><base /></outbound>
        <on-error><base /></on-error>
      </policies>
    '''
    format: 'xml'
  }
}

// ─── Azure Front Door + WAF (optional) ─────────────────────────────────────

resource wafPolicy 'Microsoft.Network/FrontDoorWebApplicationFirewallPolicies@2024-02-01' = if (enableFrontDoor) {
  name: 'waf-${suffix}'
  location: 'Global'
  tags: tags
  sku: {
    name: 'Premium_AzureFrontDoor'
  }
  properties: {
    policySettings: {
      enabledState: 'Enabled'
      mode: 'Prevention'
      requestBodyCheck: 'Enabled'
    }
    managedRules: {
      managedRuleSets: [
        {
          ruleSetType: 'Microsoft_DefaultRuleSet'
          ruleSetVersion: '2.1'
        }
        {
          ruleSetType: 'Microsoft_BotManagerRuleSet'
          ruleSetVersion: '1.1'
        }
      ]
    }
    customRules: {
      rules: [
        {
          name: 'RateLimitRule'
          priority: 1
          ruleType: 'RateLimitRule'
          rateLimitThreshold: 1000
          rateLimitDurationInMinutes: 1
          matchConditions: [
            {
              matchVariable: 'RemoteAddr'
              operator: 'IPMatch'
              negateCondition: true
              matchValue: ['10.0.0.0/8']
            }
          ]
          action: 'Block'
        }
      ]
    }
  }
}

resource frontDoor 'Microsoft.Cdn/profiles@2024-02-01' = if (enableFrontDoor) {
  name: frontDoorName
  location: 'Global'
  tags: tags
  sku: {
    name: 'Premium_AzureFrontDoor'
  }
}

resource fdEndpoint 'Microsoft.Cdn/profiles/afdEndpoints@2024-02-01' = if (enableFrontDoor) {
  parent: frontDoor
  name: 'ep-${suffix}'
  location: 'Global'
  properties: {
    enabledState: 'Enabled'
  }
}

// ─── RBAC Role Assignments / Atribuicoes de Funcao ──────────────────────────

// Function App -> Cosmos DB Data Contributor
resource roleCosmosFunction 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(functionApp.id, cosmosDbAccount.id, 'cosmos-contributor')
  scope: cosmosDbAccount
  properties: {
    principalId: functionApp.identity.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '00000000-0000-0000-0000-000000000002') // Cosmos DB Built-in Data Contributor
    principalType: 'ServicePrincipal'
  }
}

// Function App -> Storage Blob Data Contributor
resource roleStorageFunction 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(functionApp.id, storageAccount.id, 'storage-contributor')
  scope: storageAccount
  properties: {
    principalId: functionApp.identity.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe') // Storage Blob Data Contributor
    principalType: 'ServicePrincipal'
  }
}

// Function App -> Service Bus Data Sender
resource roleServiceBusSenderFunction 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(functionApp.id, serviceBus.id, 'sb-sender')
  scope: serviceBus
  properties: {
    principalId: functionApp.identity.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '69a216fc-b8fb-44d8-bc22-1f3c2cd27a39') // Azure Service Bus Data Sender
    principalType: 'ServicePrincipal'
  }
}

// Function App -> Service Bus Data Receiver
resource roleServiceBusReceiverFunction 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(functionApp.id, serviceBus.id, 'sb-receiver')
  scope: serviceBus
  properties: {
    principalId: functionApp.identity.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4f6d3b9b-027b-4f4c-9142-0e5a2a2247e0') // Azure Service Bus Data Receiver
    principalType: 'ServicePrincipal'
  }
}

// Function App -> Key Vault Secrets User
resource roleKeyVaultFunction 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(functionApp.id, keyVault.id, 'kv-secrets')
  scope: keyVault
  properties: {
    principalId: functionApp.identity.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4633458b-17de-408a-b874-0445c86b69e6') // Key Vault Secrets User
    principalType: 'ServicePrincipal'
  }
}

// Container App -> Key Vault Secrets User
resource roleKeyVaultContainerApp 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(agentRuntime.id, keyVault.id, 'kv-secrets-ca')
  scope: keyVault
  properties: {
    principalId: agentRuntime.identity.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4633458b-17de-408a-b874-0445c86b69e6')
    principalType: 'ServicePrincipal'
  }
}

// Container App -> Cosmos DB Data Contributor
resource roleCosmosContainerApp 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(agentRuntime.id, cosmosDbAccount.id, 'cosmos-contributor-ca')
  scope: cosmosDbAccount
  properties: {
    principalId: agentRuntime.identity.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '00000000-0000-0000-0000-000000000002')
    principalType: 'ServicePrincipal'
  }
}

// ─── Private Link Endpoints (optional) ──────────────────────────────────────

resource peCosmosDb 'Microsoft.Network/privateEndpoints@2024-01-01' = if (enablePrivateLink) {
  name: 'pe-cosmos-${suffix}'
  location: location
  tags: tags
  properties: {
    subnet: {
      id: vnet.properties.subnets[3].id
    }
    privateLinkServiceConnections: [
      {
        name: 'cosmos-connection'
        properties: {
          privateLinkServiceId: cosmosDbAccount.id
          groupIds: ['Sql']
        }
      }
    ]
  }
}

resource peStorage 'Microsoft.Network/privateEndpoints@2024-01-01' = if (enablePrivateLink) {
  name: 'pe-storage-${suffix}'
  location: location
  tags: tags
  properties: {
    subnet: {
      id: vnet.properties.subnets[3].id
    }
    privateLinkServiceConnections: [
      {
        name: 'storage-connection'
        properties: {
          privateLinkServiceId: storageAccount.id
          groupIds: ['blob']
        }
      }
    ]
  }
}

resource peKeyVault 'Microsoft.Network/privateEndpoints@2024-01-01' = if (enablePrivateLink) {
  name: 'pe-kv-${suffix}'
  location: location
  tags: tags
  properties: {
    subnet: {
      id: vnet.properties.subnets[3].id
    }
    privateLinkServiceConnections: [
      {
        name: 'kv-connection'
        properties: {
          privateLinkServiceId: keyVault.id
          groupIds: ['vault']
        }
      }
    ]
  }
}

resource peServiceBus 'Microsoft.Network/privateEndpoints@2024-01-01' = if (enablePrivateLink) {
  name: 'pe-sb-${suffix}'
  location: location
  tags: tags
  properties: {
    subnet: {
      id: vnet.properties.subnets[3].id
    }
    privateLinkServiceConnections: [
      {
        name: 'sb-connection'
        properties: {
          privateLinkServiceId: serviceBus.id
          groupIds: ['namespace']
        }
      }
    ]
  }
}

// ─── Outputs / Saidas ───────────────────────────────────────────────────────

output vnetId string = vnet.id
output containerAppsEnvId string = containerAppsEnv.id
output agentRuntimeFqdn string = agentRuntime.properties.configuration.ingress.fqdn
output functionAppHostname string = functionApp.properties.defaultHostName
output apimGatewayUrl string = apim.properties.gatewayUrl
output cosmosDbEndpoint string = cosmosDbAccount.properties.documentEndpoint
output storageAccountName string = storageAccount.name
output serviceBusNamespace string = '${serviceBusName}.servicebus.windows.net'
output eventGridTopicEndpoint string = eventGridTopic.properties.endpoint
output keyVaultUri string = keyVault.properties.vaultUri
output appInsightsConnectionString string = appInsights.properties.ConnectionString
output frontDoorEndpoint string = enableFrontDoor ? fdEndpoint.properties.hostName : 'N/A - Front Door disabled'
