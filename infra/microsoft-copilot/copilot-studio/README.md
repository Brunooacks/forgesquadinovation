# ForgeSquad no Copilot Studio

## Guia Passo a Passo

**Abordagem A: Low-code com Microsoft Copilot Studio**

---

## Pre-Requisitos

- Licenca Microsoft 365 E3 ou E5
- Licenca Copilot Studio (standalone ou inclusa no M365 Copilot)
- Licenca Power Automate Premium (para conectores premium)
- Ambiente Dataverse provisionado
- Microsoft Teams configurado
- Azure OpenAI Service (para modelos GPT-4o)
- Permissoes de administrador no Power Platform

---

## 1. Criacao dos Agentes no Copilot Studio

### 1.1 Estrutura Geral

Cada agente do ForgeSquad sera um **Custom Copilot** no Copilot Studio.
Vamos criar 9 copilots, um para cada role:

| # | Copilot Name | Descricao |
|---|-------------|-----------|
| 1 | ForgeSquad-Architect | Design de sistema e decisoes arquiteturais |
| 2 | ForgeSquad-TechLead | Coordenacao tecnica e code review |
| 3 | ForgeSquad-BA | Requisitos e user stories |
| 4 | ForgeSquad-DevBackend | Implementacao backend |
| 5 | ForgeSquad-DevFrontend | Implementacao frontend |
| 6 | ForgeSquad-QA | Testes e qualidade |
| 7 | ForgeSquad-TechWriter | Documentacao tecnica |
| 8 | ForgeSquad-PM | Gestao de projeto e relatorios |
| 9 | ForgeSquad-FinanceAdvisor | Compliance financeiro e regulatorio |

### 1.2 Passo a Passo: Criar um Copilot

1. Acesse [https://copilotstudio.microsoft.com](https://copilotstudio.microsoft.com)
2. Clique em **"Create a copilot"**
3. Selecione **"New copilot"**
4. Configure:
   - **Name:** ForgeSquad-Architect (ou o nome do agente)
   - **Description:** Agente responsavel por design de sistema e decisoes arquiteturais
   - **Language:** Portuguese (Brazil)
   - **Instructions:** Cole o system prompt do arquivo YAML correspondente
5. Em **"Knowledge"**, adicione:
   - Documentos SharePoint com padroes arquiteturais da empresa
   - URLs de documentacao tecnica relevante
   - Dataverse tables com decisoes anteriores (ADRs)
6. Clique em **"Create"**

### 1.3 Configuracao de Instrucoes (System Prompt)

Para cada copilot, use as instrucoes do arquivo YAML correspondente em `agents/`.
Exemplo para o Architect:

```
Voce e o Architect do ForgeSquad, responsavel por:
- Design de arquitetura de sistemas
- Decisoes arquiteturais (ADRs)
- Validacao de requisitos nao-funcionais
- Governanca tecnica do squad
...
```

Veja detalhes completos em `agents/architect-copilot.yaml`.

---

## 2. Configuracao de Topics para Cada Fase

### 2.1 Estrutura de Topics

Cada fase do pipeline ForgeSquad sera um **Topic** no copilot correspondente.
Topics sao acionados por trigger phrases ou por Power Automate.

### 2.2 Topics por Fase e Copilot

#### Copilot: ForgeSquad-Architect

| Topic | Trigger | Acao |
|-------|---------|------|
| Phase1-Feasibility | "analisar viabilidade" | Analisa requisitos e retorna parecer |
| Phase3-SolutionDesign | "projetar arquitetura" | Gera diagrama C4 e recomendacoes |
| Phase3-ADRCreation | "criar ADR" | Gera Architecture Decision Record |
| ReviewGate | "revisar artefato" | Valida artefato contra checklist |

#### Copilot: ForgeSquad-BA

| Topic | Trigger | Acao |
|-------|---------|------|
| Phase1-DomainAnalysis | "analisar dominio" | Identifica bounded contexts |
| Phase2-UserStories | "criar user stories" | Gera user stories no formato padrao |
| Phase2-AcceptanceCriteria | "definir criterios" | Cria criterios de aceite Gherkin |

#### Copilot: ForgeSquad-TechLead

| Topic | Trigger | Acao |
|-------|---------|------|
| Phase4-SprintPlanning | "planejar sprint" | Cria plano de sprint |
| Phase4-TaskBreakdown | "quebrar tarefas" | Decompoe stories em tasks |
| Phase5-CodeReview | "revisar codigo" | Executa code review |
| Phase9-CICD | "configurar pipeline" | Define pipeline CI/CD |

#### Copilot: ForgeSquad-DevBackend

| Topic | Trigger | Acao |
|-------|---------|------|
| Phase5-APIDesign | "projetar API" | Gera especificacao OpenAPI |
| Phase5-Implementation | "implementar backend" | Gera codigo com Devin/Copilot |

#### Copilot: ForgeSquad-DevFrontend

| Topic | Trigger | Acao |
|-------|---------|------|
| Phase6-UIDesign | "projetar interface" | Define componentes UI |
| Phase6-Implementation | "implementar frontend" | Gera codigo frontend |
| Phase6-Integration | "integrar frontend" | Conecta com APIs backend |

#### Copilot: ForgeSquad-QA

| Topic | Trigger | Acao |
|-------|---------|------|
| Phase7-TestStrategy | "definir estrategia" | Cria plano de testes |
| Phase7-TestExecution | "executar testes" | Roda suite de testes |

#### Copilot: ForgeSquad-TechWriter

| Topic | Trigger | Acao |
|-------|---------|------|
| Phase8-APIDocs | "documentar API" | Gera documentacao de API |
| Phase8-Runbooks | "criar runbook" | Gera runbooks operacionais |

#### Copilot: ForgeSquad-PM

| Topic | Trigger | Acao |
|-------|---------|------|
| Phase1-StakeholderMapping | "mapear stakeholders" | Identifica partes interessadas |
| Phase10-Metrics | "coletar metricas" | Consolida metricas do projeto |
| Phase10-LessonsLearned | "retrospectiva" | Gera relatorio de licoes aprendidas |
| StatusReport | "gerar relatorio" | Cria status report do projeto |

#### Copilot: ForgeSquad-FinanceAdvisor

| Topic | Trigger | Acao |
|-------|---------|------|
| ComplianceCheck | "validar compliance" | Verifica conformidade regulatoria |
| RegulatoryReview | "revisar regulatorio" | Analisa impacto de regulacoes |

### 2.3 Como Criar um Topic

1. Abra o copilot no Copilot Studio
2. Va para **"Topics"** > **"+ New topic"**
3. Configure:
   - **Name:** Phase3-SolutionDesign
   - **Trigger phrases:** "projetar arquitetura", "design de solucao", "criar arquitetura"
4. No canvas, adicione nos:
   - **Message:** "Vou iniciar o design da arquitetura. Qual e o contexto do projeto?"
   - **Question:** Coleta informacoes do usuario
   - **Action:** Chama plugin/conector para gerar artefato
   - **Message:** Apresenta resultado
   - **Action:** Salva artefato no Dataverse

---

## 3. Integracao com Power Automate para Orquestracao

### 3.1 Fluxo Principal: Pipeline Orchestrator

O fluxo Power Automate `pipeline-orchestrator` e o coracao da orquestracao.
Ele sequencia as fases, aciona os copilots corretos e gerencia checkpoints.

Veja a definicao completa em `flows/pipeline-orchestrator.json`.

### 3.2 Como Criar o Fluxo

1. Acesse [https://make.powerautomate.com](https://make.powerautomate.com)
2. Clique em **"+ Create"** > **"Automated cloud flow"**
3. Trigger: **"When a message is posted in a channel"** (Teams)
   - Ou: **"Manually triggered"** para testes
4. Adicione acoes sequenciais para cada fase
5. Use **"Start a Teams approval"** para checkpoints
6. Use **"HTTP"** action para chamar copilots via API

### 3.3 Padrao de Chamada para Cada Fase

```
[Trigger] -> [Set Phase Variable] -> [Call Copilot API]
    -> [Parse Response] -> [Save to Dataverse]
    -> [If Checkpoint: Start Approval] -> [Wait for Approval]
    -> [Log to Audit Trail] -> [Next Phase]
```

### 3.4 Conectores Necessarios

| Conector | Uso |
|---------|-----|
| Microsoft Teams | Notificacoes e Approvals |
| Dataverse | Audit trail e armazenamento |
| HTTP | Chamadas para Copilot Studio API |
| SharePoint | Armazenamento de artefatos |
| Azure OpenAI | Chamadas diretas ao modelo (fallback) |
| Office 365 Outlook | Notificacoes por email |

---

## 4. Configuracao de Approval Gates via Microsoft Teams

### 4.1 Tipos de Aprovacao

| Checkpoint | Tipo | Aprovadores |
|-----------|------|-------------|
| CP1 - Discovery | Approve/Reject | Product Owner |
| CP2 - Requirements | Approve/Reject/Modify | PO + Tech Lead |
| CP3 - Architecture | Approve/Reject | CTO / Architect Lead |
| CP4 - Planning | Approve/Reject | PM + PO |
| CP5 - Backend | Approve/Reject | Tech Lead |
| CP6 - Frontend | Approve/Reject | Tech Lead + UX Lead |
| CP7 - QA | Approve/Reject | QA Lead |
| CP8 - Documentation | Approve/Reject | Tech Writer Lead |
| CP9 - Deployment | Approve/Reject | CTO + DevOps Lead |

### 4.2 Configuracao no Power Automate

Para cada checkpoint, adicione a acao **"Start and wait for an approval"**:

1. **Approval type:** Approve/Reject - First to respond
2. **Title:** "ForgeSquad Checkpoint {N}: {Phase Name}"
3. **Assigned to:** email dos aprovadores
4. **Details:** Resumo dos artefatos gerados na fase
5. **Item link:** Link para artefatos no SharePoint

### 4.3 Adaptive Card para Checkpoints

Os checkpoints enviam Adaptive Cards no Teams com:
- Resumo da fase concluida
- Lista de artefatos gerados
- Metricas da fase (tempo, tokens, custo)
- Botoes de Approve/Reject/Request Changes

---

## 5. Dataverse para Audit Trail

### 5.1 Tabelas Necessarias

Crie as seguintes tabelas no Dataverse:

#### Tabela: ForgeSquad_Runs

| Coluna | Tipo | Descricao |
|--------|------|-----------|
| RunId | GUID (PK) | Identificador unico da execucao |
| SquadName | Text | Nome do squad |
| ProjectName | Text | Nome do projeto |
| Status | Choice | NotStarted/Running/Paused/Completed/Failed |
| StartedAt | DateTime | Inicio da execucao |
| CompletedAt | DateTime | Fim da execucao |
| CreatedBy | Lookup (User) | Usuario que iniciou |

#### Tabela: ForgeSquad_PhaseExecutions

| Coluna | Tipo | Descricao |
|--------|------|-----------|
| ExecutionId | GUID (PK) | ID da execucao da fase |
| RunId | Lookup (Runs) | Referencia ao run |
| PhaseName | Text | Nome da fase |
| PhaseNumber | Integer | Numero da fase (1-10) |
| AgentName | Text | Agente primario |
| Status | Choice | Pending/Running/WaitingApproval/Approved/Rejected/Completed |
| InputHash | Text | SHA-256 do input |
| OutputHash | Text | SHA-256 do output |
| StartedAt | DateTime | Inicio |
| CompletedAt | DateTime | Fim |
| TokensUsed | Integer | Total de tokens consumidos |
| CostEstimate | Decimal | Custo estimado (BRL) |

#### Tabela: ForgeSquad_Artifacts

| Coluna | Tipo | Descricao |
|--------|------|-----------|
| ArtifactId | GUID (PK) | ID do artefato |
| ExecutionId | Lookup (PhaseExec) | Fase que gerou |
| ArtifactType | Choice | Document/Code/Diagram/Report/ADR |
| FileName | Text | Nome do arquivo |
| StorageUrl | URL | Link no SharePoint |
| ContentHash | Text | SHA-256 do conteudo |
| CreatedAt | DateTime | Data de criacao |

#### Tabela: ForgeSquad_Approvals

| Coluna | Tipo | Descricao |
|--------|------|-----------|
| ApprovalId | GUID (PK) | ID da aprovacao |
| ExecutionId | Lookup (PhaseExec) | Fase relacionada |
| CheckpointNumber | Integer | Numero do checkpoint (1-9) |
| ApproverEmail | Text | Email do aprovador |
| Decision | Choice | Approved/Rejected/Modified |
| Comments | Multiline Text | Comentarios do aprovador |
| DecidedAt | DateTime | Data da decisao |

### 5.2 Como Criar as Tabelas

1. Acesse [https://make.powerapps.com](https://make.powerapps.com)
2. Selecione o ambiente correto
3. Va para **"Tables"** > **"+ New table"**
4. Crie cada tabela com as colunas listadas acima
5. Configure relacionamentos (Lookups) entre tabelas

---

## 6. Deployment em Teams e M365

### 6.1 Publicar Copilots no Teams

Para cada copilot:

1. No Copilot Studio, va para **"Channels"**
2. Selecione **"Microsoft Teams"**
3. Clique em **"Turn on Teams"**
4. Configure:
   - **App name:** ForgeSquad - Architect (ou o role)
   - **Short description:** Agente de arquitetura do ForgeSquad
   - **Icon:** Upload icone do role
5. Clique em **"Publish"**
6. Para distribuir na organizacao:
   - Va para **Teams Admin Center**
   - Upload o pacote do app
   - Defina politicas de permissao

### 6.2 Canal Dedicado no Teams

Crie um canal dedicado para o ForgeSquad:

1. No Teams, crie um team **"ForgeSquad"**
2. Adicione canais:
   - **#general** - Visao geral e comandos
   - **#pipeline** - Status de execucao
   - **#approvals** - Checkpoints e aprovacoes
   - **#artifacts** - Artefatos gerados
   - **#audit** - Log de auditoria

### 6.3 Fluxo Completo do Usuario

```
1. Usuario entra no canal #general do Teams
2. Digita: "@ForgeSquad-PM iniciar squad para projeto X"
3. PM Copilot responde com formulario de configuracao
4. Usuario preenche e confirma
5. Power Automate inicia pipeline
6. A cada fase:
   - Notificacao no canal #pipeline
   - Artefatos postados no #artifacts
   - Checkpoints enviados no #approvals
7. Ao final, relatorio completo no #general
```

---

## Dicas e Melhores Praticas

1. **Teste cada copilot individualmente** antes de integrar com Power Automate
2. **Use variaveis de ambiente** no Power Automate para URLs e configuracoes
3. **Configure retry policies** nas acoes HTTP para resiliencia
4. **Monitore uso de tokens** via Dataverse para controle de custos
5. **Use Solution packages** para mover entre ambientes (Dev/Test/Prod)
6. **Configure DLP policies** no Power Platform Admin Center
7. **Habilite logging** em todos os copilots para troubleshooting

---

## Limitacoes Conhecidas

- Copilot Studio tem limite de 2000 mensagens/dia por copilot (plano padrao)
- Power Automate Premium requer licenca por usuario ou per-flow
- Aprovacoes no Teams tem timeout de 30 dias
- Dataverse tem limite de 1GB por ambiente (plano padrao)
- Latencia entre chamadas pode chegar a 5-10s por step
