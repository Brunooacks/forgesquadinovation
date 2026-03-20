# ForgeSquad com Semantic Kernel

## Guia Passo a Passo — Abordagem B (Pro-code)

**Framework:** Microsoft Semantic Kernel (C# / .NET 8)
**Runtime:** Azure AI Agent Service
**LLM:** Azure OpenAI Service (GPT-4o, GPT-4o-mini)

---

## Indice

1. [Pre-Requisitos](#pre-requisitos)
2. [Setup do Projeto](#setup-do-projeto)
3. [Arquitetura do Codigo](#arquitetura-do-codigo)
4. [Criacao de Agentes](#criacao-de-agentes)
5. [Multi-Agent Chat](#multi-agent-chat)
6. [Plugin System para Skills](#plugin-system)
7. [Pipeline Runner com Checkpoints](#pipeline-runner)
8. [Audit Trail com Cosmos DB](#audit-trail)
9. [Deploy no Azure](#deploy)
10. [Testes](#testes)

---

## 1. Pre-Requisitos

### Software

- .NET 8 SDK ou superior
- Visual Studio 2022 / VS Code / Rider
- Azure CLI (`az`)
- Docker (para desenvolvimento local)
- Git

### Servicos Azure

- Azure Subscription ativa
- Azure OpenAI Service com deployments:
  - `forgesquad-gpt4o` (GPT-4o)
  - `forgesquad-gpt4o-mini` (GPT-4o-mini)
- Azure Cosmos DB (conta NoSQL)
- Azure Key Vault
- Azure App Service ou Azure Container Apps
- Azure AI Search (opcional, para memoria semantica)
- Application Insights

### Licencas

- Microsoft 365 E3/E5 (para integracao Teams)
- Microsoft Teams (para checkpoints via Approvals)

---

## 2. Setup do Projeto

### 2.1 Criar o Projeto

```bash
# Criar solution
dotnet new sln -n ForgeSquad

# Criar projeto principal
dotnet new console -n ForgeSquad.Core -o src/ForgeSquad.Core

# Adicionar ao solution
dotnet sln add src/ForgeSquad.Core/ForgeSquad.Core.csproj

# Restaurar pacotes
dotnet restore
```

### 2.2 Configurar User Secrets (Desenvolvimento Local)

```bash
cd src/ForgeSquad.Core
dotnet user-secrets init

# Azure OpenAI
dotnet user-secrets set "AzureOpenAI:Endpoint" "https://your-resource.openai.azure.com/"
dotnet user-secrets set "AzureOpenAI:ApiKey" "your-api-key"
dotnet user-secrets set "AzureOpenAI:DeploymentGpt4o" "forgesquad-gpt4o"
dotnet user-secrets set "AzureOpenAI:DeploymentGpt4oMini" "forgesquad-gpt4o-mini"

# Cosmos DB
dotnet user-secrets set "CosmosDb:Endpoint" "https://your-cosmos.documents.azure.com:443/"
dotnet user-secrets set "CosmosDb:Key" "your-cosmos-key"
dotnet user-secrets set "CosmosDb:DatabaseName" "forgesquad"

# Teams (para Approvals)
dotnet user-secrets set "Teams:WebhookUrl" "https://your-teams-webhook-url"
dotnet user-secrets set "Teams:TenantId" "your-tenant-id"
dotnet user-secrets set "Teams:ClientId" "your-app-client-id"
dotnet user-secrets set "Teams:ClientSecret" "your-app-secret"
```

### 2.3 Estrutura de Pastas

```
src/ForgeSquad.Core/
  |-- Agents/
  |     |-- ArchitectAgent.cs
  |     |-- TechLeadAgent.cs
  |     |-- BusinessAnalystAgent.cs
  |     |-- DevBackendAgent.cs
  |     |-- DevFrontendAgent.cs
  |     |-- QAEngineerAgent.cs
  |     |-- TechWriterAgent.cs
  |     |-- ProjectManagerAgent.cs
  |     |-- FinanceAdvisorAgent.cs
  |-- Pipeline/
  |     |-- PipelineRunner.cs
  |     |-- PipelineDefinition.cs
  |     |-- PhaseDefinition.cs
  |     |-- StepDefinition.cs
  |     |-- ApprovalGate.cs
  |-- Skills/
  |     |-- DevinSkill.cs
  |     |-- GitHubCopilotSkill.cs
  |     |-- StackSpotSkill.cs
  |     |-- KiroSkill.cs
  |-- AuditTrail/
  |     |-- AuditLogger.cs
  |     |-- AuditEvent.cs
  |     |-- CosmosDbAuditStore.cs
  |-- Configuration/
  |     |-- ForgeSquadOptions.cs
  |     |-- AgentOptions.cs
  |-- Program.cs
  |-- ForgeSquad.Core.csproj
  |-- appsettings.json
```

---

## 3. Arquitetura do Codigo

### Diagrama de Dependencias

```
Program.cs (Entry Point)
  |
  +-- ServiceCollection (DI)
  |     |
  |     +-- Kernel (Semantic Kernel)
  |     |     |-- Azure OpenAI ChatCompletion
  |     |     |-- Plugins (Skills)
  |     |
  |     +-- Agents (9 ChatCompletionAgents)
  |     |     |-- System Prompts
  |     |     |-- Agent-specific Plugins
  |     |
  |     +-- PipelineRunner
  |     |     |-- Phase Definitions (YAML)
  |     |     |-- ApprovalGate
  |     |
  |     +-- AuditLogger
  |           |-- CosmosDbAuditStore
  |
  +-- Pipeline Execution
        |-- Sequential Phase Processing
        |-- AgentGroupChat (multi-agent collaboration)
        |-- Checkpoint Handling (human-in-the-loop)
        |-- Artifact Generation
```

### Fluxo de Execucao

```
1. Program.cs carrega configuracao e YAML do squad
2. Registra todos os agentes via DI
3. PipelineRunner recebe a definicao do pipeline
4. Para cada fase:
   a. Seleciona agente(s) responsavel(is)
   b. Se multi-agente: cria AgentGroupChat
   c. Executa cada step da fase
   d. Coleta artefatos gerados
   e. Se checkpoint: ApprovalGate.RequestApproval()
   f. AuditLogger registra evento
5. Ao final: gera relatorio consolidado
```

---

## 4. Criacao de Agentes

### Padrao de Criacao

Cada agente e criado usando `ChatCompletionAgent` do Semantic Kernel:

```csharp
var agent = new ChatCompletionAgent
{
    Name = "Architect",
    Instructions = "System prompt aqui...",
    Kernel = kernel,                    // Kernel com Azure OpenAI
    Arguments = new KernelArguments(    // Configuracoes do modelo
        new AzureOpenAIPromptExecutionSettings
        {
            Temperature = 0.2,
            MaxTokens = 4096
        })
};
```

### Model Tier Routing

Agentes criticos (Architect, Dev Backend, Finance Advisor) usam GPT-4o.
Agentes de suporte (BA, QA, Tech Writer, PM) usam GPT-4o-mini.

```
GPT-4o (Premium):     Architect, Tech Lead, Dev Backend, Dev Frontend, Finance Advisor
GPT-4o-mini (Std):    BA, QA Engineer, Tech Writer, Project Manager
```

### Detalhes

Veja os arquivos em `Agents/` para implementacao completa de cada agente.
Os agentes principais sao:
- `ArchitectAgent.cs` — System design, ADRs, quality gates
- `FinanceAdvisorAgent.cs` — Compliance Bacen, BIAN, Basel, LGPD

---

## 5. Multi-Agent Chat

### AgentGroupChat

O Semantic Kernel permite criar chats entre multiplos agentes:

```csharp
var chat = new AgentGroupChat(architectAgent, techLeadAgent, baAgent)
{
    ExecutionSettings = new()
    {
        TerminationStrategy = new ApprovalTerminationStrategy
        {
            Agents = [architectAgent],
            MaximumIterations = 10
        },
        SelectionStrategy = new SequentialSelectionStrategy()
    }
};
```

### Estrategias de Selecao

- **SequentialSelectionStrategy**: Round-robin entre agentes
- **KernelFunctionSelectionStrategy**: LLM decide quem fala proximo
- Custom: Implementar `SelectionStrategy` para logica especifica por fase

### Estrategias de Terminacao

- **ApprovalTerminationStrategy**: Termina quando agente especifico aprova
- **MaxIterationTerminationStrategy**: Limita numero de turnos
- Custom: Implementar `TerminationStrategy` para detectar consenso

---

## 6. Plugin System para Skills

### Padrao de Plugin

```csharp
public class DevinSkill
{
    [KernelFunction("execute_coding_task")]
    [Description("Executes a coding task using Devin AI")]
    public async Task<string> ExecuteCodingTask(
        [Description("Task description")] string taskDescription,
        [Description("Programming language")] string language)
    {
        // Integra com Devin API
    }
}
```

### Registro de Plugins

```csharp
kernel.Plugins.AddFromType<DevinSkill>();
kernel.Plugins.AddFromType<GitHubCopilotSkill>();
```

Veja `Skills/DevinSkill.cs` para implementacao completa.

---

## 7. Pipeline Runner com Checkpoints

### Definicao do Pipeline (YAML)

O pipeline e definido em YAML e carregado pelo `PipelineRunner`:

```yaml
pipeline:
  name: "ForgeSquad Standard"
  phases:
    - name: "Discovery"
      agents: ["PM", "BA", "Architect"]
      steps:
        - name: "Stakeholder Mapping"
          agent: "PM"
        - name: "Domain Analysis"
          agent: "BA"
        - name: "Feasibility Check"
          agent: "Architect"
      checkpoint:
        enabled: true
        approvers: ["product-owner@company.com"]
```

### Checkpoints (ApprovalGate)

O `ApprovalGate` suporta dois modos:
1. **Teams Approvals**: Envia Adaptive Card no Teams e aguarda resposta
2. **API/Console**: Aguarda aprovacao via API REST ou console interativo

Veja `Pipeline/ApprovalGate.cs` para implementacao.

---

## 8. Audit Trail com Cosmos DB

### Modelo de Dados

```
Database: forgesquad
  |-- Container: audit-events (partition key: /runId)
  |     |-- PhaseStarted
  |     |-- StepExecuted
  |     |-- CheckpointRequested
  |     |-- CheckpointDecided
  |     |-- ArtifactGenerated
  |     |-- PipelineCompleted
  |
  |-- Container: artifacts (partition key: /runId)
  |     |-- Artefatos gerados por cada fase
  |
  |-- Container: runs (partition key: /squadName)
        |-- Metadata de cada execucao
```

### Caracteristicas

- Append-only (eventos nunca sao modificados)
- SHA-256 hash de cada evento para integridade
- Event sourcing pattern para reconstruir estado
- TTL configuravel para retencao

Veja `AuditTrail/AuditLogger.cs` para implementacao.

---

## 9. Deploy no Azure

### 9.1 Infraestrutura (Bicep/Terraform)

Recursos necessarios:
- Azure App Service (ou Container Apps)
- Azure OpenAI Service
- Azure Cosmos DB
- Azure Key Vault
- Azure Application Insights
- Azure AI Search (opcional)

### 9.2 CI/CD com GitHub Actions

```yaml
name: Deploy ForgeSquad
on:
  push:
    branches: [main]

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-dotnet@v4
        with:
          dotnet-version: '8.0.x'
      - run: dotnet build --configuration Release
      - run: dotnet test
      - run: dotnet publish -c Release -o ./publish
      - uses: azure/webapps-deploy@v3
        with:
          app-name: forgesquad-api
          package: ./publish
```

### 9.3 Configuracao de Producao

```bash
# Configurar App Settings via Azure CLI
az webapp config appsettings set \
  --name forgesquad-api \
  --resource-group forgesquad-rg \
  --settings \
    AzureOpenAI__Endpoint="@Microsoft.KeyVault(VaultName=forgesquad-kv;SecretName=openai-endpoint)" \
    AzureOpenAI__ApiKey="@Microsoft.KeyVault(VaultName=forgesquad-kv;SecretName=openai-key)" \
    CosmosDb__Endpoint="@Microsoft.KeyVault(VaultName=forgesquad-kv;SecretName=cosmos-endpoint)"
```

---

## 10. Testes

### Testes Unitarios

```bash
dotnet new xunit -n ForgeSquad.Tests -o tests/ForgeSquad.Tests
dotnet sln add tests/ForgeSquad.Tests/ForgeSquad.Tests.csproj
dotnet add tests/ForgeSquad.Tests reference src/ForgeSquad.Core/ForgeSquad.Core.csproj
```

### Cobertura de Testes Recomendada

| Componente | Tipo de Teste | Prioridade |
|-----------|---------------|------------|
| PipelineRunner | Integracao | Alta |
| ApprovalGate | Unitario + Mock | Alta |
| AuditLogger | Unitario | Alta |
| Skills/Plugins | Unitario + Mock | Media |
| Agents (prompts) | Avaliacao LLM | Media |

### Execucao

```bash
dotnet test --collect:"XPlat Code Coverage"
dotnet tool install -g dotnet-reportgenerator-globaltool
reportgenerator -reports:**/coverage.cobertura.xml -targetdir:coverage-report
```
