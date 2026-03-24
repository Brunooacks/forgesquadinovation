# De-Para de Tecnologias — Skills para Agentes de IA

> Documento de referência para criação de skills em múltiplas plataformas de agentes de IA.
> ForgeSquad Framework | Março 2026

---

## 1. Visão Geral

Cada plataforma de agentes de IA possui seu próprio modelo para definir **skills** (também chamados de tools, plugins, actions, extensions ou functions). Este documento mapeia como esses conceitos se traduzem entre plataformas, permitindo que o ForgeSquad expanda para deployment multi-plataforma.

### Skills Atuais do ForgeSquad

| Skill | Categoria | Agentes que Usam |
|-------|-----------|------------------|
| Devin | Development | Dev Backend, Dev Frontend, QA, Tech Lead |
| GitHub Copilot | Development | Dev Backend, Dev Frontend, Tech Lead |
| StackSpot | Infrastructure | Dev Backend, Architect |
| Kiro | Requirements | Business Analyst |
| Jira Sync | Project Management | Project Manager |
| SonarQube | Quality | QA Engineer, Tech Lead, Architect |

---

## 2. Plataformas Comparadas

### 2.1 Claude Code / Anthropic

| Aspecto | Detalhe |
|---------|---------|
| **Agent SDK** | Claude Agent SDK (Python, TypeScript) |
| **Formato de Skill** | SKILL.md (Markdown com frontmatter YAML) |
| **Tool Use** | Tool Use API (JSON Schema), MCP (Model Context Protocol) |
| **Protocolo Aberto** | MCP — conecta LLMs a ferramentas/dados externos |
| **Conceitos-chave** | System prompts, tool definitions, human-in-the-loop, prompt caching |
| **Modelo de Preço** | Per-token: Opus $15/$75 (in/out por 1M tokens), Sonnet $3/$15, Haiku $0.25/$1.25 |
| **Pontos Fortes** | Ecossistema MCP, raciocínio forte, precisão em tool use, segurança |
| **SDK** | `@anthropic-ai/sdk` (TS), `anthropic` (Python) |
| **Padrões de Agente** | ReAct loop, orchestrator-worker, evaluator-optimizer |
| **Context Window** | Até 1M tokens (Opus 4.6) |

### 2.2 OpenAI GPT / Codex / Assistants API

| Aspecto | Detalhe |
|---------|---------|
| **Agent Framework** | Assistants API, GPT Actions, Codex CLI, Agents SDK |
| **Formato de Skill** | Function definitions (JSON Schema), GPT Actions (OpenAPI spec) |
| **Tool Use** | Function calling, Code Interpreter, File Search, Web browsing |
| **Conceitos-chave** | Assistants, Threads, Runs, Tools, Vector Stores, File objects |
| **Codex CLI** | Ferramenta CLI para coding autônomo (similar ao Claude Code) |
| **Modelo de Preço** | GPT-4o: $2.50/$10 (in/out por 1M tokens), o3: $10/$40 |
| **Pontos Fortes** | Ecossistema massivo, GPT Store, multi-modal, Code Interpreter sandbox |
| **SDK** | `openai` (Python/TS) |
| **Padrões de Agente** | Assistants API com tool chaining, Agents SDK, Swarm (experimental) |
| **Context Window** | 128K tokens (GPT-4o), 200K (o3) |

### 2.3 Antigravity / StackSpot AI

| Aspecto | Detalhe |
|---------|---------|
| **Plataforma** | StackSpot AI — plataforma enterprise de produtividade para devs |
| **Agent Framework** | StackSpot AI Agents, Quick Commands, Custom Actions |
| **Formato de Skill** | Quick Commands (YAML + templates Jinja2), Actions (code-based) |
| **Tool Use** | StackSpot Actions, Knowledge Sources (KS), Remote Quick Commands |
| **Conceitos-chave** | Stacks, Plugins, Stackfiles, Knowledge Sources, AI Assistants |
| **Modelo de Preço** | Licenciamento enterprise, per-seat |
| **Pontos Fortes** | Enterprise-ready, IaC templates, knowledge organizacional, origem brasileira |
| **Integração** | VS Code extension, CLI, CI/CD plugins |
| **Context Window** | Depende do modelo backend (GPT-4o ou Claude) |

### 2.4 GitHub Copilot / Copilot Extensions

| Aspecto | Detalhe |
|---------|---------|
| **Agent Framework** | Copilot Extensions (agents), Chat participants, Copilot Workspace |
| **Formato de Skill** | Copilot Extensions (GitHub Apps com AI), Chat participants (@workspace) |
| **Tool Use** | Extensions API, function calling via chat, MCP servers |
| **Conceitos-chave** | Chat participants, slash commands, contexto implícito, code suggestions |
| **Modelo de Preço** | Individual $10/mês, Business $19/mês, Enterprise $39/mês |
| **Pontos Fortes** | Deep IDE integration, context awareness, enterprise SSO/audit |
| **SDK** | `@octokit/core`, Copilot Extensions SDK |
| **Context Window** | Gerenciado internamente (baseado em GPT-4o/Claude) |

### 2.5 Amazon Q Developer

| Aspecto | Detalhe |
|---------|---------|
| **Agent Framework** | Amazon Q Developer Agents (/dev, /transform) |
| **Formato de Skill** | Customizations, guardrails, prompt profiles |
| **Tool Use** | `/dev` (features), `/transform` (Java upgrades), `/review`, `/test`, `/doc` |
| **Conceitos-chave** | Workspace context, customizations, guardrails, IAM integration |
| **Modelo de Preço** | Free tier, Pro $19/user/mês, Business (custom) |
| **Pontos Fortes** | Integração AWS nativa, Java modernization, IAM, segurança enterprise |
| **Context Window** | Gerenciado internamente |

### 2.6 Google Gemini / Vertex AI Agent Builder

| Aspecto | Detalhe |
|---------|---------|
| **Agent Framework** | Vertex AI Agent Builder, Gemini Extensions |
| **Formato de Skill** | OpenAPI tools, Datastore tools, Code Interpreter, Extensions |
| **Tool Use** | Function calling, grounding, RAG, Code Execution |
| **Conceitos-chave** | Agents, Tools, Sessions, Playbooks, Data Stores, Grounding |
| **Modelo de Preço** | Gemini 2.0 Pro: $1.25/$5 (in/out por 1M tokens), Flash: $0.075/$0.30 |
| **Pontos Fortes** | Multi-modal, contexto longo (2M tokens), Google Cloud integration |
| **SDK** | `google-cloud-aiplatform`, `@google/generative-ai` |
| **Context Window** | Até 2M tokens (Gemini 1.5/2.0 Pro) |

### 2.7 Microsoft Copilot Studio / Semantic Kernel

| Aspecto | Detalhe |
|---------|---------|
| **Agent Framework** | Copilot Studio (low-code), Semantic Kernel (pro-code C#/Python) |
| **Formato de Skill** | Topics + Actions (Studio), Plugins + Functions (Semantic Kernel) |
| **Tool Use** | Connectors (1000+), Power Automate flows, Azure Functions |
| **Conceitos-chave** | Topics, Entities, Actions, Plugins, Planners, Memories, Connectors |
| **Modelo de Preço** | Studio: $200/mês por 25K mensagens, Azure OpenAI: por consumo |
| **Pontos Fortes** | M365 integration, Power Platform, enterprise connectors, low-code |
| **SDK** | `Microsoft.SemanticKernel` (C#), `semantic-kernel` (Python) |
| **Context Window** | Depende do modelo Azure OpenAI backend |

### 2.8 Devin (Cognition AI)

| Aspecto | Detalhe |
|---------|---------|
| **Agent Framework** | Agente autônomo de software engineering |
| **Formato de Skill** | Natural language instructions, playbooks |
| **Tool Use** | Shell, browser, editor, planner (built-in) |
| **Conceitos-chave** | Sessions, snapshots, knowledge base, playbooks |
| **Modelo de Preço** | Teams $500/mês, per-ACU (Agent Compute Unit) |
| **Pontos Fortes** | Totalmente autônomo, browser use, long-running tasks |
| **API** | Devin API para gerenciamento programático de sessions |

### 2.9 Cursor / Windsurf (Codeium)

| Aspecto | Cursor | Windsurf |
|---------|--------|----------|
| **Tipo** | AI-first code editor (VS Code fork) | AI-powered IDE |
| **Skills** | `.cursorrules`, `@` mentions, Composer | Cascade flows, context rules |
| **Tool Use** | Built-in (codebase search, terminal, file edit, web) | Cascade agent (multi-step) |
| **Conceitos** | Composer (multi-file), Chat, Cmd+K (inline edit) | Cascade (agentic), Supercomplete |
| **Preço** | Pro $20/mês, Business $40/mês | Pro $15/mês, Teams $30/mês |
| **MCP Support** | Sim | Sim |

### 2.10 Frameworks Open-Source

| Framework | Formato de Skill | Padrão de Agente | Linguagem |
|-----------|-----------------|-------------------|-----------|
| **LangChain/LangGraph** | Tools (Python functions + decorators) | ReAct, Plan-and-Execute, State Machines | Python/TS |
| **CrewAI** | Tools (Python classes BaseTool) | Crews, Tasks, Processes (seq/hierárquico) | Python |
| **AutoGen (Microsoft)** | Python functions registradas | ConversableAgent, GroupChat, nested chats | Python |
| **Haystack** | Components pipeline | Pipeline-based | Python |
| **Phidata** | Tools (Python functions) | Agent teams, workflows | Python |

---

## 3. Tabela De-Para — Conceitos Fundamentais

| Conceito ForgeSquad | Claude Code | OpenAI/Codex | StackSpot | GitHub Copilot | Amazon Q | Gemini/Vertex | Copilot Studio | Devin | LangChain | CrewAI |
|---------------------|-------------|--------------|-----------|----------------|----------|---------------|----------------|-------|-----------|--------|
| **Agent** | Agent (SDK) | Assistant | AI Assistant | Extension Agent | Q Agent | Vertex Agent | Copilot Bot | Session | Agent | CrewAgent |
| **Skill** | SKILL.md + MCP | Function/Action | Quick Command | Extension | Customization | Extension/Tool | Topic + Action | Playbook | Tool | BaseTool |
| **Pipeline** | Orchestration loop | Thread + Runs | Stack Pipeline | Workflow | /dev workflow | Playbook | Topic Flow | Session Plan | Chain/Graph | Process |
| **Checkpoint** | Human-in-the-loop | requiresAction | Approval Gate | PR Review | Review step | Human callback | Escalation | Snapshot | HumanInputRun | human_input |
| **Memory** | `_memory/` files | Thread history | Knowledge Source | @workspace | Workspace ctx | Data Store | Conversation vars | Knowledge base | Memory | memory |
| **Tool Call** | `tool_use` block | `function_call` | Action execution | Extension call | Agent action | `functionCall` | Connector call | Tool execution | `tool.run()` | `_run()` |
| **Audit Trail** | SHA-256 JSON | Run Steps | Stack logs | Audit log | CloudTrail | Cloud Logging | Conversation logs | Session log | Callbacks | verbose |
| **Persona/Role** | System prompt | Instructions | Agent profile | Extension desc | Profile | System instruction | Bot description | Prompt | Agent role | role/goal |
| **Context Window** | 1M tokens | 128-200K | Depende backend | Gerenciado | Gerenciado | 2M tokens | Depende backend | Ilimitado* | Depende LLM | Depende LLM |
| **Multi-Agent** | Subagents | Multi-assistant | Múltiplos agents | Múltiplas ext. | Não nativo | Multi-agent | Multi-bot | Não nativo | LangGraph | Crew |
| **Error Handling** | Tool error result | Run failed status | Action error | Extension error | Error response | Error block | Error topic | Error snapshot | Exception | Exception |
| **Auth** | MCP auth, API key | API key, OAuth | StackSpot token | GitHub App | IAM roles | Service Account | Azure AD | API key | N/A | N/A |
| **Rate Limits** | Per-token tier | TPM/RPM tiers | Per-seat | Per-seat + quota | Per-seat | Per-token quota | Per-message | Per-ACU | Per-LLM | Per-LLM |

---

## 4. Tabela De-Para — Criação de Skills

### Como criar uma skill em cada plataforma:

| Aspecto | Claude Code | OpenAI | StackSpot | GitHub Copilot | Amazon Q | Vertex AI | Copilot Studio | Devin |
|---------|-------------|--------|-----------|----------------|----------|-----------|----------------|-------|
| **Formato** | SKILL.md (Markdown) | JSON Schema | YAML + Jinja2 | GitHub App + API | Console config | OpenAPI + YAML | Visual designer | Natural language |
| **Linguagem** | Python/TypeScript | Python/TS/any | Java/TS/Python | Any (HTTP API) | N/A (config) | Python | Power Fx / C# | N/A |
| **Input** | JSON Schema in tool | JSON Schema params | Input variables | API params | N/A | OpenAPI params | Entity slots | Prompt text |
| **Output** | Tool result (text/JSON) | Function return | Template output | Chat response | Response text | Tool response | Message/Card | Session output |
| **Auth** | MCP auth, API keys | API key, OAuth | StackSpot token | GitHub App auth | IAM roles | Service Account | Azure AD | API key |
| **Teste** | Local MCP testing | Playground | StackSpot CLI | Extension debug | Console test | Agent tester | Test canvas | Session test |
| **Deploy** | npm publish / local | API deployment | Stack publish | GitHub Marketplace | N/A | Vertex deploy | Publish | N/A |
| **Marketplace** | MCP Registry | GPT Store | StackSpot Mkt | Extensions Mkt | N/A | N/A | Copilot Gallery | N/A |
| **Versionamento** | Git / semver | API version | Stack version | GitHub releases | N/A | Model version | Bot version | N/A |
| **Documentação** | Inline no SKILL.md | Function description | README do QC | Extension docs | N/A | Tool description | Topic description | Playbook desc |

---

## 5. Exemplos Práticos — Skill "Code Review" em Cada Plataforma

### 5.1 Claude Code (SKILL.md + MCP)

```markdown
---
name: "Code Review"
description: "Automated code review with quality analysis"
type: tool
version: "1.0.0"
category: quality
agents: [tech-lead, architect]
---

# Code Review Skill

## When to Use
- After implementation, before merge
- Quality gate enforcement

## Tool Definition
\`\`\`json
{
  "name": "review_code",
  "description": "Analyze code for quality, security, and patterns",
  "input_schema": {
    "type": "object",
    "properties": {
      "file_path": { "type": "string" },
      "review_type": { "enum": ["security", "quality", "architecture"] }
    },
    "required": ["file_path"]
  }
}
\`\`\`
```

### 5.2 OpenAI (Function Calling / Assistants API)

```json
{
  "type": "function",
  "function": {
    "name": "review_code",
    "description": "Analyze code for quality, security, and patterns",
    "parameters": {
      "type": "object",
      "properties": {
        "file_path": { "type": "string", "description": "Path to file" },
        "review_type": {
          "type": "string",
          "enum": ["security", "quality", "architecture"]
        }
      },
      "required": ["file_path"]
    }
  }
}
```

### 5.3 StackSpot (Quick Command)

```yaml
schema-version: v3
kind: quick-command
metadata:
  name: code-review
  display-name: "Code Review"
  description: "Automated code review"
  categories: [quality]
spec:
  type: ai-augmented
  inputs:
    - name: file_path
      type: text
      required: true
    - name: review_type
      type: select
      options: [security, quality, architecture]
  prompt: |
    Analyze the following code for {{ review_type }} issues:
    {{ file_content }}
```

### 5.4 GitHub Copilot (Extension)

```typescript
// GitHub Copilot Extension — server.ts
import { createServer } from "@copilot-extensions/preview-sdk";

const server = createServer((req, res) => {
  const { messages } = req.body;
  const userMessage = messages[messages.length - 1].content;

  // Parse code review request
  const review = analyzeCode(userMessage);

  res.json({
    choices: [{
      message: {
        role: "assistant",
        content: review.summary
      }
    }]
  });
});
```

### 5.5 Amazon Q (Customization)

```yaml
# Amazon Q Developer Customization
name: code-review-standards
description: "Enterprise code review standards"
type: customization
content:
  guidelines: |
    When reviewing code, check for:
    - OWASP Top 10 vulnerabilities
    - SOLID principles adherence
    - Test coverage > 80%
    - No hardcoded secrets
```

### 5.6 Vertex AI (Tool)

```python
from vertexai.generative_models import Tool, FunctionDeclaration

review_code_func = FunctionDeclaration(
    name="review_code",
    description="Analyze code for quality and security",
    parameters={
        "type": "object",
        "properties": {
            "file_path": {"type": "string"},
            "review_type": {"type": "string", "enum": ["security", "quality"]}
        },
        "required": ["file_path"]
    }
)

review_tool = Tool(function_declarations=[review_code_func])
```

### 5.7 Semantic Kernel (Plugin C#)

```csharp
using Microsoft.SemanticKernel;

public class CodeReviewPlugin
{
    [KernelFunction("review_code")]
    [Description("Analyze code for quality, security, and patterns")]
    public async Task<string> ReviewCodeAsync(
        [Description("Path to file")] string filePath,
        [Description("Type: security, quality, architecture")] string reviewType = "quality")
    {
        var code = await File.ReadAllTextAsync(filePath);
        // Análise de código...
        return $"Review ({reviewType}): {results}";
    }
}
```

### 5.8 LangChain (Tool Python)

```python
from langchain_core.tools import tool

@tool
def review_code(file_path: str, review_type: str = "quality") -> str:
    """Analyze code for quality, security, and architecture patterns.

    Args:
        file_path: Path to the file to review
        review_type: Type of review (security, quality, architecture)
    """
    with open(file_path) as f:
        code = f.read()
    # Análise...
    return f"Review ({review_type}): {analysis_result}"
```

### 5.9 CrewAI (Tool + Agent)

```python
from crewai_tools import BaseTool

class CodeReviewTool(BaseTool):
    name: str = "Code Review"
    description: str = "Analyze code for quality and security issues"

    def _run(self, file_path: str, review_type: str = "quality") -> str:
        with open(file_path) as f:
            code = f.read()
        # Análise...
        return f"Review ({review_type}): {result}"

# Uso no agente
tech_lead = Agent(
    role="Tech Lead",
    tools=[CodeReviewTool()],
    goal="Ensure code quality and security standards"
)
```

---

## 6. Custos Comparativos por Plataforma

### 6.1 Custo por Desenvolvedor

| Plataforma | Tier | 1 Dev/Mês | 100 Devs/Mês | 600 Devs/Mês | Observações |
|------------|------|-----------|--------------|--------------|-------------|
| **Claude Code** | Max Plan | $100 | $10,000 | $60,000 | 5x mais uso que Pro |
| **Claude Code** | Enterprise | $30-50* | $3,000-5,000 | $18,000-30,000 | *Estimado, negociável |
| **Claude API** | Per-token | ~$65 | ~$6,500 | ~$39,000 | Baseado em consumo médio |
| **OpenAI Codex** | Per-token | ~$50 | ~$5,000 | ~$30,000 | Codex CLI + API tokens |
| **OpenAI ChatGPT** | Team | $25 | $2,500 | $15,000 | Limites de uso |
| **GitHub Copilot** | Enterprise | $39 | $3,900 | $23,400 | Inclui Extensions |
| **StackSpot AI** | Enterprise | ~$50* | ~$5,000 | ~$30,000 | *Licença negociável |
| **Amazon Q** | Pro | $19 | $1,900 | $11,400 | Inclui /dev, /transform |
| **Gemini Code Assist** | Enterprise | $19 | $1,900 | $11,400 | Google Cloud integration |
| **Copilot Studio** | Per-message | ~$80* | ~$8,000 | ~$48,000 | *25K msgs = $200 |
| **Devin** | Teams | $500 | $50,000 | $300,000 | Autônomo, ACU-based |
| **Cursor** | Business | $40 | $4,000 | $24,000 | IDE completa |
| **Windsurf** | Teams | $30 | $3,000 | $18,000 | IDE completa |
| **M365 Copilot** | Per-seat | $30 | $3,000 | $18,000 | Word, Excel, Teams, PPT |

### 6.2 Custo Total — Cenários de Combinação para 600 Devs

| Cenário | Stack | Custo Mensal | Custo Anual |
|---------|-------|-------------|-------------|
| **Mínimo** | Claude API + GitHub Copilot Business ($19) | $50,400 | $604,800 |
| **Recomendado** | Claude Code Max + Copilot Enterprise + StackSpot | $113,400 | $1,360,800 |
| **Premium** | Claude + Copilot Ent + StackSpot + Devin (50 seats) + M365 Copilot (200) | $168,400 | $2,020,800 |
| **Full Enterprise** | Tudo acima + Amazon Q + Cursor + Vertex AI | $215,000 | $2,580,000 |

### 6.3 O que está incluído em cada licença

| Plataforma | Incluído | Não Incluído |
|------------|----------|--------------|
| Claude Code Max | 5x mais uso, todos os modelos, MCP | API consumption além do plano |
| GitHub Copilot Ent | Chat, completions, extensions, audit | Copilot Workspace (preview) |
| StackSpot AI | Quick Commands, KS, Actions, CLI | Custom stacks enterprise |
| Amazon Q Pro | /dev, /transform, /review, /test | Customizations avançadas |
| Devin Teams | Sessions, playbooks, API access | ACUs além do plano |
| M365 Copilot | Word, Excel, PPT, Teams, Outlook | Copilot Studio (separado) |

---

## 7. Matriz de Capacidades

### Legenda: ✅ Suporte completo | ⚠️ Suporte parcial/limitado | ❌ Não disponível

| Capacidade | Claude | OpenAI | StackSpot | Copilot | Amazon Q | Gemini | Copilot Studio | Devin | Cursor | LangChain |
|------------|--------|--------|-----------|---------|----------|--------|----------------|-------|--------|-----------|
| **Function Calling** | ✅ | ✅ | ⚠️ | ✅ | ❌ | ✅ | ✅ | ❌ | ❌ | ✅ |
| **Multi-Agent** | ✅ | ⚠️ | ❌ | ❌ | ❌ | ✅ | ✅ | ❌ | ❌ | ✅ |
| **Custom Skills/Plugins** | ✅ | ✅ | ✅ | ✅ | ⚠️ | ✅ | ✅ | ⚠️ | ⚠️ | ✅ |
| **IDE Integration** | ✅ | ⚠️ | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ | ✅ | ❌ |
| **Autonomous Coding** | ✅ | ✅ | ❌ | ⚠️ | ✅ | ⚠️ | ❌ | ✅ | ✅ | ⚠️ |
| **Enterprise SSO** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | N/A |
| **Audit Trail** | ✅ | ⚠️ | ✅ | ✅ | ✅ | ✅ | ✅ | ⚠️ | ❌ | ⚠️ |
| **On-Premise** | ❌ | ❌ | ✅ | ❌ | ⚠️ | ⚠️ | ⚠️ | ❌ | ❌ | ✅ |
| **Open Source** | ⚠️ MCP | ⚠️ Swarm | ❌ | ❌ | ❌ | ⚠️ | ❌ | ❌ | ❌ | ✅ |
| **Regulated Industry** | ✅ | ✅ | ✅ | ⚠️ | ✅ | ✅ | ✅ | ⚠️ | ❌ | ✅ |
| **Human-in-the-Loop** | ✅ | ✅ | ✅ | ⚠️ | ⚠️ | ✅ | ✅ | ✅ | ⚠️ | ✅ |
| **MCP Protocol** | ✅ | ✅ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ | ✅ | ⚠️ |
| **Browser Use** | ✅ | ⚠️ | ❌ | ❌ | ❌ | ❌ | ⚠️ | ✅ | ❌ | ⚠️ |
| **File System** | ✅ | ⚠️ | ❌ | ✅ | ✅ | ❌ | ❌ | ✅ | ✅ | ✅ |
| **Terminal Access** | ✅ | ✅ | ⚠️ | ⚠️ | ✅ | ❌ | ❌ | ✅ | ✅ | ✅ |
| **Image Understanding** | ✅ | ✅ | ❌ | ✅ | ⚠️ | ✅ | ⚠️ | ✅ | ✅ | ✅ |
| **Code Generation** | ✅✅ | ✅✅ | ⚠️ | ✅ | ✅ | ✅ | ⚠️ | ✅✅ | ✅✅ | ✅ |
| **Streaming** | ✅ | ✅ | ❌ | ✅ | ❌ | ✅ | ⚠️ | ❌ | ✅ | ✅ |
| **Batch Processing** | ✅ | ✅ | ✅ | ❌ | ❌ | ✅ | ⚠️ | ✅ | ❌ | ✅ |
| **RAG/Knowledge** | ✅ MCP | ✅ Vector Store | ✅ KS | ✅ @workspace | ⚠️ | ✅ Data Store | ✅ Knowledge | ✅ KB | ⚠️ | ✅ |
| **Prompt Caching** | ✅ | ✅ | N/A | N/A | N/A | ✅ | N/A | N/A | N/A | N/A |

---

## 8. Estratégia de Portabilidade ForgeSquad

### 8.1 Arquitetura de Camadas

```
┌─────────────────────────────────────────────────────┐
│                 ForgeSquad Core                       │
│  (Agents, Pipeline, Checkpoints, Audit Trail)        │
├─────────────────────────────────────────────────────┤
│           Skill Definition Layer (YAML)               │
│  (Formato agnóstico: nome, inputs, outputs, triggers) │
├─────────────────────────────────────────────────────┤
│              Adapter Layer (por plataforma)            │
│  ┌──────┐ ┌──────┐ ┌────────┐ ┌──────┐ ┌──────┐    │
│  │Claude│ │OpenAI│ │StackSpt│ │Copilt│ │Vertex│    │
│  │ MCP  │ │ Func │ │  QC    │ │ Ext  │ │ Tool │    │
│  └──────┘ └──────┘ └────────┘ └──────┘ └──────┘    │
├─────────────────────────────────────────────────────┤
│            Runtime Layer (execução)                   │
│  Claude API | OpenAI API | StackSpot | GitHub | GCP  │
└─────────────────────────────────────────────────────┘
```

### 8.2 Formato Agnóstico de Skill (Proposta)

```yaml
# forgesquad-skill.yaml — formato portável
apiVersion: forgesquad/v1
kind: Skill
metadata:
  name: code-review
  version: "1.0.0"
  category: quality
  agents: [tech-lead, architect]
spec:
  description: "Automated code review with quality analysis"
  inputs:
    - name: file_path
      type: string
      required: true
      description: "Path to file to review"
    - name: review_type
      type: enum
      options: [security, quality, architecture]
      default: quality
  outputs:
    - name: review_result
      type: object
      properties:
        score: number
        issues: array
        recommendations: array
  triggers:
    - event: post-implementation
    - event: pre-merge
  adapters:
    claude: skills/code-review/claude-adapter.md
    openai: skills/code-review/openai-adapter.json
    stackspot: skills/code-review/stackspot-adapter.yaml
    copilot: skills/code-review/copilot-adapter.ts
    semantic-kernel: skills/code-review/sk-adapter.cs
```

### 8.3 Mapeamento de Skills ForgeSquad → Cada Plataforma

| Skill ForgeSquad | Claude Code | OpenAI | StackSpot | GitHub Copilot | Amazon Q | Semantic Kernel | LangChain |
|------------------|-------------|--------|-----------|----------------|----------|-----------------|-----------|
| **Devin Integration** | MCP Server | Assistant + API | Action | Extension | N/A | HTTP Plugin | Tool + API |
| **Code Review** | SKILL.md | Function | Quick Command | Built-in | /review | KernelFunction | @tool |
| **Test Automation** | MCP + CLI | Code Interpreter | Action | Extension | /test | Plugin | Tool + CLI |
| **API Documentation** | SKILL.md | Function | Template | Extension | /doc | Plugin | @tool |
| **Jira Sync** | MCP Server | Function + API | Connector | Extension | N/A | Connector | Tool + API |
| **SonarQube** | MCP + CLI | Function + API | Action | Extension | N/A | HTTP Plugin | Tool + API |
| **Architecture Review** | SKILL.md | Assistant | KS + QC | Extension | N/A | Plugin | Agent + tools |
| **Compliance Check** | SKILL.md | Function | Action | Extension | Guardrail | Plugin | @tool |
| **Security Scan** | MCP + CLI | Code Interpreter | Action | Extension | /review | Plugin | Tool + CLI |
| **Performance Test** | MCP + CLI | Code Interpreter | Action | Extension | N/A | Plugin | Tool + CLI |

### 8.4 Esforço de Portabilidade por Plataforma

| Plataforma | Complexidade | Esforço (pessoa-meses) | Prioridade | Justificativa |
|------------|-------------|------------------------|------------|---------------|
| **Claude Code (atual)** | N/A | 0 (já implementado) | — | Base atual |
| **OpenAI/Codex** | Média | 3-4 meses | Alta | Maior ecossistema, GPT Store |
| **GitHub Copilot Extensions** | Média | 2-3 meses | Alta | Deep IDE integration |
| **Semantic Kernel** | Média | 3-4 meses | Alta | Ecossistema Microsoft |
| **StackSpot** | Baixa | 1-2 meses | Alta | Já integrado, expandir |
| **Vertex AI** | Média | 2-3 meses | Média | Google Cloud clientes |
| **Amazon Q** | Alta | 4-5 meses | Média | API mais restritiva |
| **LangChain/CrewAI** | Baixa | 1-2 meses | Média | Open-source, flexível |
| **Devin API** | Baixa | 1 mês | Baixa | Já integrado como skill |
| **Cursor/Windsurf** | Baixa | 1 mês | Baixa | Via MCP (compartilhado) |
| **Total Estimado** | — | **18-25 meses** | — | **Equipe de 4 = 5-6 meses** |

---

## 9. Roadmap de Portabilidade

### Fase 1: MCP-First (Meses 1-2)
- Converter todas as skills para MCP Servers
- Benefício: portabilidade automática para Claude, Copilot, Cursor, Windsurf
- Esforço: 2 pessoa-meses
- Resultado: 6 skills disponíveis em 4 plataformas

### Fase 2: OpenAI + Semantic Kernel (Meses 3-4)
- Criar adapters OpenAI (Function calling + Assistants API)
- Criar plugins Semantic Kernel (C#)
- Esforço: 4 pessoa-meses
- Resultado: 6 skills em OpenAI + Microsoft ecosystem

### Fase 3: StackSpot + Vertex (Meses 5-6)
- Expandir Quick Commands no StackSpot
- Criar OpenAPI tools para Vertex AI
- Esforço: 3 pessoa-meses
- Resultado: Cobertura de 8 plataformas

### Fase 4: Open-Source + Marketplace (Meses 7-8)
- Publicar LangChain Tools e CrewAI Tools no PyPI
- Publicar Extensions no GitHub Marketplace
- Publicar Quick Commands no StackSpot Marketplace
- Publicar GPT Actions no GPT Store
- Esforço: 2 pessoa-meses
- Resultado: Skills disponíveis em marketplaces públicos

---

## 10. Recomendações

### 10.1 Stack Recomendado para ForgeSquad Multi-Platform

| Camada | Ferramenta | Justificativa |
|--------|-----------|---------------|
| **Orquestração primária** | Claude Code | Melhor raciocínio, MCP, Agent SDK |
| **IDE Productivity** | GitHub Copilot Enterprise | Adoção universal, deep IDE |
| **Infraestrutura** | StackSpot / Antigravity | IaC templates, enterprise knowledge |
| **Coding Autônomo** | Devin ou OpenAI Codex | Tasks de longa duração |
| **Enterprise Workflows** | Copilot Studio + Semantic Kernel | M365, Power Platform |
| **Open-Source** | LangChain/CrewAI | Flexibilidade, self-hosted |
| **Fallback** | Amazon Q ou Gemini | Workloads específicos |

### 10.2 Prioridades de Desenvolvimento

1. **MCP-first**: Portabilidade automática para 4+ plataformas
2. **OpenAPI adapters**: Compatibilidade com StackSpot e Vertex
3. **Semantic Kernel plugins**: Acesso ao ecossistema Microsoft
4. **LangChain tools**: Flexibilidade open-source
5. **Marketplace publishing**: Distribuição e adoção

### 10.3 Investimento Total para Multi-Platform

| Item | Custo |
|------|-------|
| Equipe de Platform (4 pessoas × 8 meses) | R$ 960,000 (~$192,000) |
| Licenças de desenvolvimento (todas plataformas) | $15,000 |
| Infraestrutura de CI/CD e testing | $8,000 |
| **Total** | **~$215,000** |
| **Resultado** | Skills em 10 plataformas, 4 marketplaces |

---

## 11. Glossário

| Termo | Definição |
|-------|-----------|
| **MCP** | Model Context Protocol — protocolo aberto da Anthropic para conectar LLMs a ferramentas |
| **Function Calling** | Capacidade do LLM de invocar funções externas com parâmetros estruturados |
| **Tool Use** | Uso genérico de ferramentas por agentes (inclui function calling, browser, terminal) |
| **Extension** | Plugin que estende capacidades de um agente (GitHub Copilot Extensions, Gemini Extensions) |
| **Quick Command** | Skill no StackSpot: YAML + template que executa com contexto AI |
| **Knowledge Source** | Base de conhecimento organizacional no StackSpot |
| **Plugin** | Módulo de funcionalidade no Semantic Kernel (C#/Python) |
| **Action** | Operação executável em Copilot Studio ou StackSpot |
| **Playbook** | Conjunto de instruções para o Devin executar autonomamente |
| **Agent Compute Unit (ACU)** | Unidade de consumo do Devin para tasks computacionais |
| **Topic** | Fluxo conversacional no Copilot Studio |
| **Connector** | Integração pré-construída no Power Platform / Copilot Studio |
| **Grounding** | Ancoragem de respostas em dados reais (Vertex AI) |
| **RAG** | Retrieval-Augmented Generation — geração aumentada por recuperação de dados |

---

*Documento gerado por ForgeSquad | Março 2026*
*Versão 1.0 — Atualizar trimestralmente com novos preços e capacidades*
