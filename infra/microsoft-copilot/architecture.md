# ForgeSquad no Ecossistema Microsoft Copilot

## Guia Completo de Arquitetura

**Versao:** 1.0
**Data:** 2026-03-20
**Autor:** ForgeSquad Team

---

## Indice

1. [Visao Geral](#visao-geral)
2. [Mapeamento ForgeSquad para Microsoft](#mapeamento)
3. [Abordagem A: Copilot Studio (Low-code)](#abordagem-a)
4. [Abordagem B: Semantic Kernel + Azure AI Agent Service (Pro-code)](#abordagem-b)
5. [Abordagem C: Microsoft AutoGen (Research-grade)](#abordagem-c)
6. [Tabela Comparativa](#tabela-comparativa)
7. [Recomendacoes por Cenario](#recomendacoes)

---

## Visao Geral

O ForgeSquad e um framework de orquestracao multi-agente para squads de Engenharia de Software.
Ele coordena **9 agentes**, organizados em **10 fases**, com **24 passos** e **9 checkpoints humanos**.

### Componentes do ForgeSquad

| Componente | Descricao |
|-----------|-----------|
| **9 Agentes** | Architect, Tech Lead, Business Analyst, Dev Backend, Dev Frontend, QA Engineer, Tech Writer, Project Manager, Finance Advisor |
| **10 Fases** | Discovery, Requirements, Architecture, Planning, Backend Dev, Frontend Dev, QA, Documentation, Deployment, Retrospective |
| **24 Passos** | Cada fase contem 2-3 passos sequenciais com artefatos definidos |
| **9 Checkpoints** | Pontos de aprovacao humana (go/no-go) entre fases criticas |

### Pipeline Visual

```
Discovery -> Requirements -> Architecture -> Planning -> Backend -> Frontend -> QA -> Docs -> Deploy -> Retro
   [CP1]       [CP2]          [CP3]         [CP4]      [CP5]      [CP6]     [CP7]  [CP8]   [CP9]
```

---

## Mapeamento ForgeSquad para Microsoft

### Como cada componente do ForgeSquad mapeia para servicos Microsoft

```
+---------------------------+---------------------------+---------------------------+
|     FORGESQUAD            |  COPILOT STUDIO           |  SEMANTIC KERNEL          |
+---------------------------+---------------------------+---------------------------+
| Agente (Persona)          | Custom Copilot            | ChatCompletionAgent       |
| Pipeline Step             | Topic + Actions           | KernelFunction            |
| Pipeline Runner           | Power Automate Flow       | PipelineRunner (custom)   |
| Checkpoint (Approval)     | Teams Approval Action     | ApprovalGate + Teams API  |
| Audit Trail               | Dataverse Table           | Cosmos DB + Event Source  |
| Memory (Context)          | Copilot Knowledge         | SemanticMemory + Qdrant   |
| Skill (Tool)              | Plugin/Connector          | KernelPlugin              |
| Squad Definition (YAML)   | Solution Package          | YAML + DI Registration    |
| Report (PM Output)        | Adaptive Card in Teams    | Markdown + Teams Webhook  |
+---------------------------+---------------------------+---------------------------+
```

### Mapeamento de Agentes para Servicos

| Agente ForgeSquad | Azure OpenAI Model | Tier Recomendado |
|---|---|---|
| Architect | GPT-4o | Premium (raciocinio complexo) |
| Tech Lead | GPT-4o | Premium |
| Business Analyst | GPT-4o-mini | Standard |
| Dev Backend | GPT-4o | Premium (geracao de codigo) |
| Dev Frontend | GPT-4o | Premium (geracao de codigo) |
| QA Engineer | GPT-4o-mini | Standard |
| Tech Writer | GPT-4o-mini | Standard |
| Project Manager | GPT-4o-mini | Standard |
| Finance Advisor | GPT-4o | Premium (compliance) |

---

## Abordagem A: Copilot Studio (Low-code)

### Descricao

Usa o **Microsoft Copilot Studio** (antigo Power Virtual Agents) para criar copilots personalizados
para cada role do squad. A orquestracao e feita via **Power Automate**, com aprovacoes via
**Microsoft Teams** e audit trail em **Dataverse**.

### Arquitetura

```
                            +------------------+
                            |  Microsoft Teams  |
                            |  (Interface UI)   |
                            +--------+---------+
                                     |
                    +----------------+----------------+
                    |                                  |
           +--------v--------+              +---------v--------+
           | Copilot Studio   |              | Teams Approvals   |
           | (9 Custom        |              | (9 Checkpoints)   |
           |  Copilots)       |              +------------------+
           +--------+--------+
                    |
        +-----------+-----------+
        |           |           |
   +----v----+ +---v----+ +---v----+
   |Architect| |Tech    | |BA      |  ... (9 copilots)
   |Copilot  | |Lead    | |Copilot |
   +---------+ |Copilot | +--------+
               +--------+
                    |
           +--------v--------+
           | Power Automate   |
           | (Pipeline        |
           |  Orchestrator)   |
           +--------+--------+
                    |
        +-----------+-----------+
        |           |           |
   +----v----+ +---v----+ +---v----+
   |Topics/  | |Custom  | |Dataverse|
   |Actions  | |Connect.| |(Audit   |
   |(Steps)  | |(Skills)| | Trail)  |
   +---------+ +--------+ +---------+
```

### Fluxo de Execucao

```
Passo 1: Usuario inicia squad via Teams
         |
Passo 2: Power Automate dispara pipeline
         |
Passo 3: Para cada fase:
         |-- Ativa copilot do agente responsavel
         |-- Copilot executa topics/actions
         |-- Artefatos salvos em SharePoint/Dataverse
         |-- Se checkpoint: envia Teams Approval
         |-- Aguarda aprovacao humana
         |-- Continua para proxima fase
         |
Passo 4: Project Manager copilot gera relatorio
         |
Passo 5: Adaptive Card com resumo no Teams
```

### Vantagens

- Criacao rapida (dias, nao semanas)
- Interface visual para configuracao
- Integracao nativa com M365 e Teams
- Sem necessidade de infraestrutura de codigo
- Conectores prontos para 1000+ servicos
- Governance via Power Platform Admin Center

### Desvantagens

- Limitacoes de logica complexa em topics
- Custo por mensagem pode escalar rapidamente
- Menos controle sobre orquestracao multi-agente
- Dificuldade para logica de roteamento avancada entre agentes
- Vendor lock-in forte no ecossistema Microsoft
- Debugging mais dificil em fluxos complexos

---

## Abordagem B: Semantic Kernel + Azure AI Agent Service (Pro-code)

### Descricao

Usa o **Semantic Kernel SDK** (C# ou Python) como framework de orquestracao de agentes.
Cada agente e um `ChatCompletionAgent` com system prompt, plugins e funcoes especificas.
O **Azure AI Agent Service** fornece a infraestrutura gerenciada para deploy dos agentes.

### Arquitetura

```
                        +------------------------+
                        |    Azure AI Agent       |
                        |    Service (Managed)    |
                        +----------+-------------+
                                   |
                    +--------------+--------------+
                    |                              |
           +--------v--------+          +---------v---------+
           | Semantic Kernel  |          | Azure OpenAI       |
           | Agent Framework  |          | Service            |
           | (Orchestration)  |          | (GPT-4o, GPT-4o-  |
           +--------+--------+          |  mini)             |
                    |                    +-------------------+
                    |
     +--------------+--------------+--------------+
     |              |              |               |
+----v----+  +-----v----+  +-----v-----+  +------v------+
|Architect|  |Tech Lead |  |BA Agent   |  | ... 6 more  |
|Agent    |  |Agent     |  |           |  | agents      |
+---------+  +----------+  +-----------+  +-------------+
     |              |              |               |
     +--------------+--------------+--------------+
                    |
           +--------v--------+
           | Pipeline Runner  |
           | (Phase Engine)   |
           +--------+--------+
                    |
        +-----------+-----------+-----------+
        |           |           |           |
   +----v----+ +---v----+ +---v----+ +----v-----+
   |Approval | |Audit   | |Skills  | |Semantic  |
   |Gates    | |Logger  | |Plugins | |Memory    |
   |(Teams   | |(Cosmos | |(Devin, | |(Qdrant/  |
   | API)    | | DB)    | | etc.)  | | AI Search|
   +---------+ +--------+ +--------+ +----------+
```

### Fluxo de Execucao Detalhado

```
Program.cs
  |
  +-- Registra agentes via DI
  |     |-- ArchitectAgent (GPT-4o, plugins: ADR, C4Model)
  |     |-- TechLeadAgent (GPT-4o, plugins: CodeReview, Sprint)
  |     |-- BAAgent (GPT-4o-mini, plugins: UserStory, Criteria)
  |     |-- DevBackendAgent (GPT-4o, plugins: Devin, CodeGen)
  |     |-- DevFrontendAgent (GPT-4o, plugins: Figma, Components)
  |     |-- QAAgent (GPT-4o-mini, plugins: TestGen, Coverage)
  |     |-- TechWriterAgent (GPT-4o-mini, plugins: DocGen, ADR)
  |     |-- PMAgent (GPT-4o-mini, plugins: Report, Gantt)
  |     +-- FinanceAdvisorAgent (GPT-4o, plugins: Compliance)
  |
  +-- Carrega pipeline YAML
  |     |-- 10 fases, 24 steps, 9 checkpoints
  |
  +-- Inicia PipelineRunner
        |
        +-- Para cada fase:
              |-- Seleciona agente(s) da fase
              |-- Cria AgentGroupChat (se multi-agente)
              |-- Executa steps da fase
              |-- Coleta artefatos
              |-- Se checkpoint:
              |     |-- ApprovalGate.RequestApproval()
              |     |-- Envia Adaptive Card via Teams
              |     |-- Aguarda resposta (Approve/Reject/Modify)
              |     |-- Se Reject: rollback ou re-execute
              |-- AuditLogger.Log(fase, artefatos, decisao)
              +-- Avanca para proxima fase
```

### Multi-Agent Chat

```
+----------------------------------------------------------+
|  AgentGroupChat (Semantic Kernel)                         |
|                                                           |
|  Architect: "Recomendo arquitetura hexagonal com..."      |
|  Tech Lead: "Concordo, mas precisamos considerar..."      |
|  BA: "O requisito REQ-003 exige que..."                   |
|  Architect: "Entao a decisao final e..."                  |
|                                                           |
|  [TerminationStrategy: quando Architect diz "DECIDIDO"]   |
|  [SelectionStrategy: round-robin ou role-based]           |
+----------------------------------------------------------+
```

### Vantagens

- Controle total sobre orquestracao
- Type-safe com C# (ou flexivel com Python)
- Plugins extensiveis e testados unitariamente
- Multi-agent chat nativo no Semantic Kernel
- Azure AI Agent Service para deploy gerenciado
- Integracao profunda com Azure (Cosmos DB, AI Search, Key Vault)
- CI/CD completo com Azure DevOps ou GitHub Actions
- Observabilidade com Application Insights

### Desvantagens

- Requer equipe de desenvolvimento
- Tempo de implementacao maior (semanas)
- Custo de infraestrutura Azure
- Complexidade de manter agentes sincronizados
- Curva de aprendizado do Semantic Kernel

---

## Abordagem C: Microsoft AutoGen (Research-grade)

### Descricao

Usa o **AutoGen** (framework open-source da Microsoft Research) para criar agentes conversacionais
que colaboram via group chat. Cada agente e um `AssistantAgent` com ferramentas (tools) registradas.
O `GroupChat` gerencia a selecao de speaker e o fluxo de conversa.

### Arquitetura

```
                    +---------------------------+
                    |  AutoGen Runtime           |
                    |  (Python)                  |
                    +----------+----------------+
                               |
              +----------------+----------------+
              |                |                |
     +--------v------+  +-----v-------+  +-----v-------+
     | GroupChat       |  | Tool        |  | Human       |
     | Manager         |  | Executor    |  | Proxy       |
     | (Speaker Select)|  | (Functions) |  | (Approvals) |
     +--------+-------+  +-----+-------+  +-----+-------+
              |                |                  |
   +----------+----------+    |                  |
   |    |    |    |      |    |                  |
+--v-+ +v-+ +v-+ +v-+ +v-+  |                  |
|Arch| |TL| |BA| |Dev| |QA|  |                  |
|    | |  | |  | |BE | |  | ...                 |
+----+ +--+ +--+ +---+ +--+  |                  |
   |                          |                  |
   +-----------+--------------+                  |
               |                                 |
      +--------v--------+              +--------v--------+
      | Azure OpenAI     |              | Microsoft Teams  |
      | (LLM Backend)    |              | (Checkpoints)    |
      +------------------+              +------------------+
              |
      +-------v--------+
      | Cosmos DB /     |
      | Azure Storage   |
      | (Audit Trail)   |
      +----------------+
```

### Fluxo de Group Chat

```
+-----------------------------------------------------------------+
|  AutoGen GroupChat                                               |
|                                                                  |
|  Rodada 1 (Discovery):                                          |
|    PM -> "Vamos iniciar o projeto X. BA, colete requisitos."     |
|    BA -> "Identifiquei 15 user stories. Architect, valide."     |
|    Architect -> "Stories validadas. Recomendo priorizar..."      |
|    [CHECKPOINT 1 - HumanProxy solicita aprovacao]               |
|                                                                  |
|  Rodada 2 (Architecture):                                        |
|    Architect -> "Proposta: microservicos com event sourcing..."  |
|    TechLead -> "Concordo. Sugiro adicionar CQRS para..."        |
|    FinanceAdvisor -> "Atencao: requisito Bacen 4658 exige..."   |
|    Architect -> "Ajustado. ADR-001 registrado. DECIDIDO."       |
|    [CHECKPOINT 2 - HumanProxy solicita aprovacao]               |
|                                                                  |
|  ... (continua por 10 fases)                                     |
+-----------------------------------------------------------------+
```

### Speaker Selection Strategy

```
Fase          | Speaker Order                    | Terminacao
--------------+----------------------------------+------------------
Discovery     | PM -> BA -> Architect            | Architect decide
Requirements  | BA -> Architect -> TechLead      | BA finaliza
Architecture  | Architect -> TechLead -> Finance | Architect decide
Planning      | TechLead -> PM -> Architect      | TechLead finaliza
Backend Dev   | DevBE -> TechLead -> Architect   | DevBE entrega
Frontend Dev  | DevFE -> TechLead -> Architect   | DevFE entrega
QA            | QA -> DevBE -> DevFE             | QA aprova
Documentation | TechWriter -> Architect          | TechWriter finaliza
Deployment    | TechLead -> DevBE -> QA          | TechLead finaliza
Retrospective | PM -> todos                      | PM finaliza
```

### Vantagens

- Framework open-source e gratuito
- Flexibilidade maxima na orquestracao
- GroupChat nativo com selecao de speaker inteligente
- HumanProxyAgent para checkpoints naturais
- Comunidade ativa e evolucao rapida
- Suporte a raciocinio complexo multi-turno
- Facil de prototipar e experimentar

### Desvantagens

- Ainda em evolucao (breaking changes frequentes)
- Menos suporte enterprise que Semantic Kernel
- Sem managed service (precisa hospedar)
- Debugging de group chats complexos e desafiador
- Menos integracao nativa com M365/Teams
- Documentacao ainda em maturacao

---

## Tabela Comparativa

```
+-------------------+------------------+------------------+------------------+
| Dimensao          | Copilot Studio   | Semantic Kernel  | AutoGen          |
+-------------------+------------------+------------------+------------------+
| Paradigma         | Low-code         | Pro-code (C#/Py) | Pro-code (Py)    |
| Complexidade      | Baixa            | Alta             | Media-Alta       |
| Tempo Setup       | 2-5 dias         | 2-4 semanas      | 1-2 semanas      |
| Controle          | Limitado         | Total            | Total            |
| Multi-Agent       | Via Power Auto.  | AgentGroupChat   | GroupChat nativo |
| Checkpoints       | Teams Approvals  | Custom + Teams   | HumanProxyAgent  |
| Audit Trail       | Dataverse        | Cosmos DB        | Custom           |
| Escalabilidade    | Alta (managed)   | Alta (Azure)     | Media (custom)   |
| Custo Mensal Est. | R$ 5-15k        | R$ 8-25k        | R$ 3-12k        |
| Vendor Lock-in    | Alto             | Medio            | Baixo            |
| Enterprise Ready  | Sim              | Sim              | Parcial          |
| Governanca        | Power Platform   | Azure RBAC       | Custom           |
| CI/CD             | ALM Accelerator  | Azure DevOps     | GitHub Actions   |
| Observabilidade   | Power Platform   | App Insights     | Custom logging   |
| Linguagem         | Configuracao     | C# / Python      | Python           |
| Modelo LLM        | Azure OpenAI     | Azure OpenAI     | Azure OpenAI     |
| Skills/Plugins    | Conectores       | KernelPlugins    | Tool Functions   |
| Maturidade        | GA (produtivo)   | GA (produtivo)   | Preview          |
+-------------------+------------------+------------------+------------------+
```

### Custo Estimado Mensal (9 agentes, uso moderado)

```
+---------------------------+-------------+-------------+-------------+
| Item                      | Copilot St. | Sem. Kernel | AutoGen     |
+---------------------------+-------------+-------------+-------------+
| Azure OpenAI (GPT-4o)    | R$ 2.000    | R$ 3.000    | R$ 3.000    |
| Azure OpenAI (GPT-4o-m)  | R$ 500      | R$ 800      | R$ 800      |
| Copilot Studio License    | R$ 1.200    | -           | -           |
| Power Automate Premium    | R$ 800      | -           | -           |
| Azure App Service / AKS   | -           | R$ 2.000    | R$ 1.500    |
| Cosmos DB                 | -           | R$ 1.500    | R$ 800      |
| Dataverse                 | R$ 600      | -           | -           |
| Azure AI Search           | -           | R$ 1.200    | R$ 800      |
| Teams Premium (approvals) | R$ 400      | R$ 400      | R$ 400      |
| Monitoring / Logs         | Incluso     | R$ 500      | R$ 300      |
+---------------------------+-------------+-------------+-------------+
| TOTAL ESTIMADO            | R$ 5.500    | R$ 9.400    | R$ 7.600    |
+---------------------------+-------------+-------------+-------------+
```

*Valores em Reais (BRL), estimativa para marco 2026. Podem variar conforme uso.*

---

## Recomendacoes por Cenario

### Startup / MVP Rapido
**Recomendacao: Abordagem A (Copilot Studio)**
- Menor tempo para valor
- Menor custo inicial
- Nao requer equipe de desenvolvimento dedicada
- Facil de iterar e ajustar

### Enterprise / Producao Regulada
**Recomendacao: Abordagem B (Semantic Kernel)**
- Controle total sobre governanca e compliance
- Audit trail enterprise-grade com Cosmos DB
- CI/CD completo e testabilidade
- Integracao profunda com Azure Security

### Pesquisa / Inovacao / PoC Avancada
**Recomendacao: Abordagem C (AutoGen)**
- Maxima flexibilidade para experimentacao
- GroupChat com raciocinio multi-turno sofisticado
- Menor custo para experimentacao
- Ideal para validar hipoteses antes de produtificar

### Abordagem Hibrida (Recomendada para ForgeSquad)

```
Fase 1 (Semana 1-2):   AutoGen para PoC e validacao do pipeline
Fase 2 (Semana 3-6):   Semantic Kernel para implementacao production-grade
Fase 3 (Semana 7-8):   Copilot Studio para interface de usuario no Teams
```

Esta abordagem hibrida permite:
1. Validar rapidamente com AutoGen
2. Construir com solidez via Semantic Kernel
3. Entregar experiencia de usuario via Copilot Studio

---

## Mapeamento Detalhado: Fases x Agentes x Microsoft

### Fase 1: Discovery (3 steps)

| Step | Agente Primario | Agente Secundario | Microsoft Service |
|------|----------------|-------------------|-------------------|
| 1.1 Stakeholder Mapping | PM | BA | Copilot: Topic "StakeholderMap" / SK: PMAgent |
| 1.2 Domain Analysis | BA | Architect | Copilot: Topic "DomainAnalysis" / SK: BAAgent |
| 1.3 Feasibility Check | Architect | Finance Advisor | Copilot: Topic "Feasibility" / SK: ArchitectAgent |
| **CHECKPOINT 1** | - | - | Teams Approval / ApprovalGate |

### Fase 2: Requirements (3 steps)

| Step | Agente Primario | Agente Secundario | Microsoft Service |
|------|----------------|-------------------|-------------------|
| 2.1 User Stories | BA | Architect | SK: BAAgent + ArchitectAgent chat |
| 2.2 Acceptance Criteria | BA | QA | SK: BAAgent + QAAgent chat |
| 2.3 Requirements Review | Architect | Tech Lead | SK: AgentGroupChat |
| **CHECKPOINT 2** | - | - | Teams Approval / ApprovalGate |

### Fase 3: Architecture (2 steps)

| Step | Agente Primario | Agente Secundario | Microsoft Service |
|------|----------------|-------------------|-------------------|
| 3.1 Solution Design | Architect | Tech Lead | SK: ArchitectAgent (C4Model plugin) |
| 3.2 ADR Creation | Architect | Finance Advisor | SK: ArchitectAgent (ADR plugin) |
| **CHECKPOINT 3** | - | - | Teams Approval / ApprovalGate |

### Fase 4: Planning (2 steps)

| Step | Agente Primario | Agente Secundario | Microsoft Service |
|------|----------------|-------------------|-------------------|
| 4.1 Sprint Planning | Tech Lead | PM | SK: TechLeadAgent |
| 4.2 Task Breakdown | Tech Lead | Dev BE + Dev FE | SK: AgentGroupChat |
| **CHECKPOINT 4** | - | - | Teams Approval / ApprovalGate |

### Fase 5: Backend Development (3 steps)

| Step | Agente Primario | Agente Secundario | Microsoft Service |
|------|----------------|-------------------|-------------------|
| 5.1 API Design | Dev Backend | Architect | SK: DevBackendAgent (OpenAPI plugin) |
| 5.2 Implementation | Dev Backend | - | SK: DevBackendAgent (Devin plugin) |
| 5.3 Code Review | Tech Lead | Architect | SK: AgentGroupChat |
| **CHECKPOINT 5** | - | - | Teams Approval / ApprovalGate |

### Fase 6: Frontend Development (3 steps)

| Step | Agente Primario | Agente Secundario | Microsoft Service |
|------|----------------|-------------------|-------------------|
| 6.1 UI Design | Dev Frontend | BA | SK: DevFrontendAgent (Figma plugin) |
| 6.2 Implementation | Dev Frontend | - | SK: DevFrontendAgent |
| 6.3 Integration | Dev Frontend | Dev Backend | SK: AgentGroupChat |
| **CHECKPOINT 6** | - | - | Teams Approval / ApprovalGate |

### Fase 7: QA (2 steps)

| Step | Agente Primario | Agente Secundario | Microsoft Service |
|------|----------------|-------------------|-------------------|
| 7.1 Test Strategy | QA | Tech Lead | SK: QAAgent |
| 7.2 Test Execution | QA | Dev BE + Dev FE | SK: QAAgent (TestRunner plugin) |
| **CHECKPOINT 7** | - | - | Teams Approval / ApprovalGate |

### Fase 8: Documentation (2 steps)

| Step | Agente Primario | Agente Secundario | Microsoft Service |
|------|----------------|-------------------|-------------------|
| 8.1 API Docs | Tech Writer | Dev Backend | SK: TechWriterAgent |
| 8.2 Runbooks & ADRs | Tech Writer | Architect | SK: TechWriterAgent |
| **CHECKPOINT 8** | - | - | Teams Approval / ApprovalGate |

### Fase 9: Deployment (2 steps)

| Step | Agente Primario | Agente Secundario | Microsoft Service |
|------|----------------|-------------------|-------------------|
| 9.1 CI/CD Pipeline | Tech Lead | Dev Backend | SK: TechLeadAgent (Azure DevOps plugin) |
| 9.2 Production Deploy | Tech Lead | QA | SK: TechLeadAgent |
| **CHECKPOINT 9** | - | - | Teams Approval / ApprovalGate |

### Fase 10: Retrospective (2 steps)

| Step | Agente Primario | Agente Secundario | Microsoft Service |
|------|----------------|-------------------|-------------------|
| 10.1 Metrics Collection | PM | All Agents | SK: PMAgent |
| 10.2 Lessons Learned | PM | Architect | SK: AgentGroupChat |

---

## Proximos Passos

1. Escolha a abordagem adequada ao seu cenario
2. Siga o README.md da abordagem escolhida
3. Configure pre-requisitos (licencas, Azure subscription)
4. Execute o setup conforme o `setup-guide.md`
5. Teste com um squad piloto antes de escalar
