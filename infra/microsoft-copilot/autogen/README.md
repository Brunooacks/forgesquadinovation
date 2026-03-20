# ForgeSquad com Microsoft AutoGen

## Guia Passo a Passo — Abordagem C (Research-grade)

**Framework:** Microsoft AutoGen 0.4+ (Python)
**LLM Backend:** Azure OpenAI Service (GPT-4o, GPT-4o-mini)

---

## Indice

1. [Pre-Requisitos](#pre-requisitos)
2. [Setup do Ambiente](#setup)
3. [Arquitetura](#arquitetura)
4. [Definicao de Agentes](#agentes)
5. [Group Chat Configuration](#group-chat)
6. [Tool Use Integration](#tools)
7. [Pipeline Execution](#pipeline)
8. [Human-in-the-Loop](#checkpoints)
9. [Execucao](#execucao)

---

## 1. Pre-Requisitos

### Software
- Python 3.11+
- pip / uv (package manager)
- Docker (opcional, para desenvolvimento local)
- Azure CLI (`az`)

### Servicos Azure
- Azure OpenAI Service com deployments:
  - `forgesquad-gpt4o` (GPT-4o)
  - `forgesquad-gpt4o-mini` (GPT-4o-mini)

### Instalacao

```bash
# Criar ambiente virtual
python -m venv .venv
source .venv/bin/activate  # Linux/Mac
# .venv\Scripts\activate   # Windows

# Instalar AutoGen
pip install "autogen-agentchat~=0.4" "autogen-ext[azure,docker]~=0.4"

# Dependencias adicionais
pip install azure-cosmos pyyaml httpx python-dotenv
```

---

## 2. Setup do Ambiente

### Variaveis de Ambiente

Crie um arquivo `.env`:

```env
AZURE_OPENAI_ENDPOINT=https://your-resource.openai.azure.com/
AZURE_OPENAI_API_KEY=your-api-key
AZURE_OPENAI_GPT4O_DEPLOYMENT=forgesquad-gpt4o
AZURE_OPENAI_GPT4O_MINI_DEPLOYMENT=forgesquad-gpt4o-mini
AZURE_OPENAI_API_VERSION=2024-08-01-preview

COSMOS_ENDPOINT=https://your-cosmos.documents.azure.com:443/
COSMOS_KEY=your-key
COSMOS_DATABASE=forgesquad

TEAMS_WEBHOOK_URL=https://your-teams-webhook
```

---

## 3. Arquitetura

```
autogen/
  |-- agents/
  |     |-- squad.py           # All 9 agents + GroupChat
  |     |-- approval_gate.py   # Human-in-the-loop checkpoints
  |-- tools/
  |     |-- devin_tools.py     # Devin AI integration
  |     |-- architecture_tools.py  # C4, ADR tools
  |     |-- compliance_tools.py    # Regulatory validation
  |-- config/
  |     |-- pipeline.yaml      # Pipeline definition
  |     |-- llm_config.py      # Model configurations
  |-- main.py                  # Entry point
  |-- requirements.txt
```

### Fluxo de Execucao

```
main.py
  |
  +-- Carrega configuracao (.env, pipeline.yaml)
  +-- Cria model clients (GPT-4o, GPT-4o-mini)
  +-- Registra tools (functions) para cada agente
  +-- Cria 9 AssistantAgents
  +-- Para cada fase do pipeline:
  |     +-- Seleciona agentes da fase
  |     +-- Cria GroupChat com speaker selection
  |     +-- Executa conversa ate terminacao
  |     +-- Se checkpoint: HumanProxyAgent solicita aprovacao
  |     +-- Registra no audit trail
  +-- Gera relatorio final
```

---

## 4. Definicao de Agentes

Cada agente e um `AssistantAgent` do AutoGen com:
- **System message:** Instrucoes de comportamento
- **LLM config:** Modelo e parametros
- **Tools:** Funcoes que o agente pode chamar

Veja implementacao completa em `agents/squad.py`.

### Mapeamento de Modelos

| Agente | Modelo | Justificativa |
|--------|--------|---------------|
| Architect | GPT-4o | Raciocinio complexo |
| Tech Lead | GPT-4o | Decisoes tecnicas |
| Dev Backend | GPT-4o | Geracao de codigo |
| Dev Frontend | GPT-4o | Geracao de codigo |
| Finance Advisor | GPT-4o | Compliance critico |
| BA | GPT-4o-mini | Documentacao |
| QA | GPT-4o-mini | Testes |
| Tech Writer | GPT-4o-mini | Documentacao |
| PM | GPT-4o-mini | Relatorios |

---

## 5. Group Chat Configuration

O AutoGen usa `GroupChat` para coordenar multiplos agentes:

```python
group_chat = GroupChat(
    agents=[architect, tech_lead, ba, ...],
    messages=[],
    max_round=20,
    speaker_selection_method="auto",  # LLM decides who speaks
    allow_repeat_speaker=False
)
```

### Speaker Selection

O AutoGen suporta 3 metodos:
- **"auto"**: LLM decide quem fala proximo (recomendado)
- **"round_robin"**: Cada agente fala na ordem
- **Custom function**: Logica personalizada por fase

---

## 6. Tool Use Integration

Ferramentas sao funcoes Python decoradas com `@tool`:

```python
@tool
def generate_c4_diagram(description: str, level: str = "container") -> str:
    """Generates a C4 Model diagram."""
    ...
```

Cada agente recebe as ferramentas relevantes ao seu papel.

---

## 7. Pipeline Execution

O pipeline e definido em YAML e executado sequencialmente:

```yaml
phases:
  - name: Discovery
    agents: [PM, BA, Architect]
    steps: [...]
    checkpoint: { enabled: true, number: 1 }
```

---

## 8. Human-in-the-Loop

O `HumanProxyAgent` do AutoGen permite checkpoints:

```python
human = UserProxyAgent(
    name="HumanApprover",
    human_input_mode="ALWAYS",  # Always ask human
    code_execution_config=False
)
```

Veja `agents/approval_gate.py` para implementacao completa.

---

## 9. Execucao

```bash
# Executar pipeline completo
python main.py --project "Meu Projeto" --squad "default"

# Executar fase especifica
python main.py --project "Meu Projeto" --phase 3

# Modo auto-approve (testes)
python main.py --project "Meu Projeto" --auto-approve
```
