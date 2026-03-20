# ForgeSquad — Guia Unificado de Setup

## Configuracao Completa para as 3 Abordagens

---

## Indice

1. [Pre-Requisitos Gerais](#pre-requisitos-gerais)
2. [Licencas Necessarias](#licencas)
3. [Setup Azure OpenAI (Comum a Todas)](#azure-openai)
4. [Abordagem A: Copilot Studio](#setup-copilot-studio)
5. [Abordagem B: Semantic Kernel](#setup-semantic-kernel)
6. [Abordagem C: AutoGen](#setup-autogen)
7. [Integracao com Microsoft Teams](#teams)
8. [Custos Estimados](#custos)
9. [Checklist Final](#checklist)

---

## 1. Pre-Requisitos Gerais

### Conta Azure
- Azure Subscription ativa (Pay-as-you-go ou Enterprise Agreement)
- Permissao para criar recursos (Contributor ou Owner no Resource Group)
- Azure CLI instalado (`az --version` >= 2.60)

### Microsoft 365
- Tenant Microsoft 365 ativo
- Conta com licenca E3 ou E5
- Acesso ao Teams
- Permissao de administrador (para registrar apps)

### Ferramentas de Desenvolvimento
- Git instalado
- Editor de codigo (VS Code recomendado)
- Docker Desktop (opcional, para desenvolvimento local)

---

## 2. Licencas Necessarias

### Por Abordagem

```
+---------------------------+-----------+-----------+-----------+
| Licenca                   | Copilot   | Semantic  | AutoGen   |
|                           | Studio    | Kernel    |           |
+---------------------------+-----------+-----------+-----------+
| Azure Subscription        | Sim       | Sim       | Sim       |
| Azure OpenAI access       | Sim       | Sim       | Sim       |
| Microsoft 365 E3/E5       | Sim       | Opcional  | Opcional  |
| Copilot Studio            | Sim       | Nao       | Nao       |
| Power Automate Premium    | Sim       | Nao       | Nao       |
| Teams Premium             | Opcional  | Opcional  | Opcional  |
| Dataverse                 | Sim       | Nao       | Nao       |
| Azure Cosmos DB           | Nao       | Sim       | Opcional  |
+---------------------------+-----------+-----------+-----------+
```

### Como Obter Azure OpenAI Access

1. Acesse [https://aka.ms/oai/access](https://aka.ms/oai/access)
2. Preencha o formulario de acesso
3. Aguarde aprovacao (geralmente 1-3 dias uteis)
4. Apos aprovacao, crie o recurso Azure OpenAI

---

## 3. Setup Azure OpenAI (Comum a Todas as Abordagens)

### 3.1 Criar o Recurso

```bash
# Login no Azure
az login

# Criar Resource Group
az group create \
  --name forgesquad-rg \
  --location eastus2

# Criar Azure OpenAI Service
az cognitiveservices account create \
  --name forgesquad-openai \
  --resource-group forgesquad-rg \
  --location eastus2 \
  --kind OpenAI \
  --sku S0 \
  --custom-domain forgesquad-openai

# Obter endpoint e chave
az cognitiveservices account show \
  --name forgesquad-openai \
  --resource-group forgesquad-rg \
  --query "properties.endpoint" -o tsv

az cognitiveservices account keys list \
  --name forgesquad-openai \
  --resource-group forgesquad-rg \
  --query "key1" -o tsv
```

### 3.2 Criar Deployments dos Modelos

```bash
# GPT-4o (Premium tier — agentes criticos)
az cognitiveservices account deployment create \
  --name forgesquad-openai \
  --resource-group forgesquad-rg \
  --deployment-name forgesquad-gpt4o \
  --model-name gpt-4o \
  --model-version "2024-08-06" \
  --model-format OpenAI \
  --sku-name Standard \
  --sku-capacity 80

# GPT-4o-mini (Standard tier — agentes de suporte)
az cognitiveservices account deployment create \
  --name forgesquad-openai \
  --resource-group forgesquad-rg \
  --deployment-name forgesquad-gpt4o-mini \
  --model-name gpt-4o-mini \
  --model-version "2024-07-18" \
  --model-format OpenAI \
  --sku-name Standard \
  --sku-capacity 120
```

### 3.3 Testar Conexao

```bash
ENDPOINT=$(az cognitiveservices account show \
  --name forgesquad-openai \
  --resource-group forgesquad-rg \
  --query "properties.endpoint" -o tsv)

KEY=$(az cognitiveservices account keys list \
  --name forgesquad-openai \
  --resource-group forgesquad-rg \
  --query "key1" -o tsv)

curl "${ENDPOINT}openai/deployments/forgesquad-gpt4o-mini/chat/completions?api-version=2024-08-01-preview" \
  -H "api-key: ${KEY}" \
  -H "Content-Type: application/json" \
  -d '{"messages":[{"role":"user","content":"Say hello ForgeSquad"}],"max_tokens":50}'
```

---

## 4. Setup Copilot Studio

### 4.1 Acessar o Copilot Studio

1. Acesse [https://copilotstudio.microsoft.com](https://copilotstudio.microsoft.com)
2. Faca login com sua conta Microsoft 365
3. Selecione o ambiente correto (Production ou Development)

### 4.2 Configurar Ambiente Dataverse

1. Acesse [https://admin.powerplatform.microsoft.com](https://admin.powerplatform.microsoft.com)
2. Va para **Environments** > Selecione ou crie um ambiente
3. Verifique que o Dataverse esta habilitado
4. Crie as tabelas de audit trail conforme `copilot-studio/README.md`

### 4.3 Criar os 9 Copilots

Para cada agente (Architect, TechLead, BA, etc.):

1. No Copilot Studio, clique **"+ New copilot"**
2. Configure nome, idioma e instrucoes do arquivo YAML correspondente
3. Adicione Knowledge Sources (SharePoint, URLs)
4. Crie Topics para cada fase do pipeline
5. Configure Actions (conectores / Power Automate)
6. Teste no painel de teste integrado
7. Publique

### 4.4 Criar Fluxo Power Automate

1. Acesse [https://make.powerautomate.com](https://make.powerautomate.com)
2. Importe o arquivo `flows/pipeline-orchestrator.json`
   - Ou crie manualmente seguindo as instrucoes
3. Configure as conexoes:
   - Azure OpenAI (HTTP connector)
   - Microsoft Teams
   - Dataverse
   - SharePoint
   - Approvals
4. Configure variaveis de ambiente (endpoints, chaves)
5. Teste o fluxo com dados de exemplo

### 4.5 Publicar no Teams

1. No Copilot Studio, va para **Channels** > **Microsoft Teams**
2. Ative o Teams channel
3. Configure nome e icone do app
4. Publique e distribua via Teams Admin Center

---

## 5. Setup Semantic Kernel

### 5.1 Criar Projeto

```bash
# Clonar o codigo
cd infra/microsoft-copilot/semantic-kernel

# Restaurar pacotes
dotnet restore src/ForgeSquad.Core/ForgeSquad.Core.csproj

# Configurar secrets
cd src/ForgeSquad.Core
dotnet user-secrets init
dotnet user-secrets set "AzureOpenAI:Endpoint" "${ENDPOINT}"
dotnet user-secrets set "AzureOpenAI:ApiKey" "${KEY}"
dotnet user-secrets set "AzureOpenAI:DeploymentGpt4o" "forgesquad-gpt4o"
dotnet user-secrets set "AzureOpenAI:DeploymentGpt4oMini" "forgesquad-gpt4o-mini"
```

### 5.2 Criar Cosmos DB

```bash
# Criar conta Cosmos DB
az cosmosdb create \
  --name forgesquad-cosmos \
  --resource-group forgesquad-rg \
  --locations regionName=eastus2 \
  --default-consistency-level Session

# Criar database
az cosmosdb sql database create \
  --account-name forgesquad-cosmos \
  --resource-group forgesquad-rg \
  --name forgesquad

# Criar containers
az cosmosdb sql container create \
  --account-name forgesquad-cosmos \
  --resource-group forgesquad-rg \
  --database-name forgesquad \
  --name audit-events \
  --partition-key-path /runId \
  --throughput 400

# Obter connection string
az cosmosdb keys list \
  --name forgesquad-cosmos \
  --resource-group forgesquad-rg \
  --type connection-strings \
  --query "connectionStrings[0].connectionString" -o tsv

# Configurar no projeto
dotnet user-secrets set "CosmosDb:Endpoint" "https://forgesquad-cosmos.documents.azure.com:443/"
dotnet user-secrets set "CosmosDb:Key" "your-cosmos-key"
dotnet user-secrets set "CosmosDb:DatabaseName" "forgesquad"
```

### 5.3 Configurar Key Vault (Producao)

```bash
# Criar Key Vault
az keyvault create \
  --name forgesquad-kv \
  --resource-group forgesquad-rg \
  --location eastus2

# Armazenar secrets
az keyvault secret set --vault-name forgesquad-kv --name openai-endpoint --value "${ENDPOINT}"
az keyvault secret set --vault-name forgesquad-kv --name openai-key --value "${KEY}"
az keyvault secret set --vault-name forgesquad-kv --name cosmos-endpoint --value "https://forgesquad-cosmos.documents.azure.com:443/"
az keyvault secret set --vault-name forgesquad-kv --name cosmos-key --value "your-cosmos-key"
```

### 5.4 Executar Localmente

```bash
cd src/ForgeSquad.Core
dotnet run -- --Project:Name "Meu Projeto" --Squad:Name "squad-alpha"
```

### 5.5 Deploy no Azure

```bash
# Criar App Service
az appservice plan create \
  --name forgesquad-plan \
  --resource-group forgesquad-rg \
  --sku B1 \
  --is-linux

az webapp create \
  --name forgesquad-api \
  --resource-group forgesquad-rg \
  --plan forgesquad-plan \
  --runtime "DOTNETCORE:8.0"

# Configurar Managed Identity para Key Vault
az webapp identity assign --name forgesquad-api --resource-group forgesquad-rg
IDENTITY=$(az webapp identity show --name forgesquad-api --resource-group forgesquad-rg --query principalId -o tsv)
az keyvault set-policy --name forgesquad-kv --object-id $IDENTITY --secret-permissions get list

# Deploy
dotnet publish -c Release -o ./publish
az webapp deploy --name forgesquad-api --resource-group forgesquad-rg --src-path ./publish
```

---

## 6. Setup AutoGen

### 6.1 Criar Ambiente

```bash
cd infra/microsoft-copilot/autogen

# Criar ambiente virtual
python -m venv .venv
source .venv/bin/activate

# Instalar dependencias
pip install "autogen-agentchat~=0.4" "autogen-ext[azure]~=0.4"
pip install azure-cosmos pyyaml httpx python-dotenv
```

### 6.2 Configurar Variaveis

```bash
# Criar arquivo .env
cat > .env << 'EOF'
AZURE_OPENAI_ENDPOINT=https://forgesquad-openai.openai.azure.com/
AZURE_OPENAI_API_KEY=your-api-key
AZURE_OPENAI_GPT4O_DEPLOYMENT=forgesquad-gpt4o
AZURE_OPENAI_GPT4O_MINI_DEPLOYMENT=forgesquad-gpt4o-mini
AZURE_OPENAI_API_VERSION=2024-08-01-preview
APPROVAL_MODE=console
EOF
```

### 6.3 Executar

```bash
# Executar pipeline completo
python -c "
import asyncio
from dotenv import load_dotenv
from agents.squad import ForgeSquadPipeline

load_dotenv()

async def main():
    pipeline = ForgeSquadPipeline(auto_approve=False)
    result = await pipeline.execute(
        project_name='Meu Projeto',
        project_description='Descricao do projeto aqui'
    )
    print(f'Status: {result[\"status\"]}')
    print(f'Phases: {len(result[\"phases\"])}')

asyncio.run(main())
"
```

---

## 7. Integracao com Microsoft Teams para Checkpoints

### 7.1 Registrar App no Azure AD

Para qualquer abordagem que use Teams Approvals:

```bash
# Registrar aplicacao
az ad app create \
  --display-name "ForgeSquad" \
  --sign-in-audience AzureADMyOrg

# Obter Application ID
APP_ID=$(az ad app list --display-name "ForgeSquad" --query "[0].appId" -o tsv)

# Criar secret
az ad app credential reset --id $APP_ID --append

# Anotar:
# - Application (client) ID
# - Directory (tenant) ID
# - Client Secret
```

### 7.2 Criar Incoming Webhook no Teams

1. No Teams, va para o canal desejado
2. Clique em **"..."** > **"Connectors"**
3. Selecione **"Incoming Webhook"**
4. Configure nome: "ForgeSquad Pipeline"
5. Copie a URL do webhook

### 7.3 Configurar Approvals no Teams

Para checkpoints usando Teams Approvals (Copilot Studio e Semantic Kernel):

1. Instale o app **"Approvals"** no Teams
2. Verifique que o app esta habilitado no Teams Admin Center
3. Configure o Power Automate para usar o conector "Approvals"

### 7.4 Testar Notificacao

```bash
# Testar webhook do Teams
curl -X POST "$TEAMS_WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d '{
    "type": "message",
    "attachments": [{
      "contentType": "application/vnd.microsoft.card.adaptive",
      "content": {
        "type": "AdaptiveCard",
        "version": "1.4",
        "body": [{
          "type": "TextBlock",
          "text": "ForgeSquad Test Notification",
          "weight": "Bolder"
        }, {
          "type": "TextBlock",
          "text": "Se voce esta vendo esta mensagem, a integracao esta funcionando."
        }]
      }
    }]
  }'
```

---

## 8. Custos Estimados

### 8.1 Custo por Execucao de Pipeline (1 squad completo)

```
+---------------------------+-------------+
| Item                      | Custo Est.  |
+---------------------------+-------------+
| GPT-4o (5 agentes)        |             |
|   Input: ~50k tokens      | R$ 5,00     |
|   Output: ~30k tokens     | R$ 15,00    |
| GPT-4o-mini (4 agentes)   |             |
|   Input: ~40k tokens      | R$ 0,30     |
|   Output: ~25k tokens     | R$ 0,75     |
+---------------------------+-------------+
| TOTAL POR EXECUCAO        | ~R$ 21,00   |
+---------------------------+-------------+
```

### 8.2 Custo Mensal (20 execucoes/mes)

```
+---------------------------+-------------+-------------+-------------+
| Item                      | Copilot St. | Sem. Kernel | AutoGen     |
+---------------------------+-------------+-------------+-------------+
| Azure OpenAI (20 runs)    | R$ 420      | R$ 420      | R$ 420      |
| Copilot Studio License    | R$ 1.200    | -           | -           |
| Power Automate Premium    | R$ 800      | -           | -           |
| Azure App Service (B1)    | -           | R$ 350      | -           |
| Cosmos DB (400 RU/s)      | -           | R$ 150      | -           |
| Dataverse (1GB)           | R$ 200      | -           | -           |
| Azure VM / ACI            | -           | -           | R$ 300      |
| Key Vault                 | -           | R$ 15       | -           |
| App Insights              | -           | R$ 50       | -           |
+---------------------------+-------------+-------------+-------------+
| TOTAL MENSAL              | R$ 2.620    | R$ 985      | R$ 720      |
+---------------------------+-------------+-------------+-------------+
```

*Nota: Custos para uso moderado (20 execucoes/mes). Podem variar significativamente
conforme volume. Azure OpenAI e cobrado por token consumido.*

### 8.3 Custo com Alta Escala (100 execucoes/mes)

```
+---------------------------+-------------+-------------+-------------+
| Item                      | Copilot St. | Sem. Kernel | AutoGen     |
+---------------------------+-------------+-------------+-------------+
| Azure OpenAI              | R$ 2.100    | R$ 2.100    | R$ 2.100    |
| Plataforma / Licencas     | R$ 2.000    | R$ 0        | R$ 0        |
| Infraestrutura            | R$ 600      | R$ 2.000    | R$ 1.500    |
| Outros                    | R$ 400      | R$ 500      | R$ 300      |
+---------------------------+-------------+-------------+-------------+
| TOTAL MENSAL              | R$ 5.100    | R$ 4.600    | R$ 3.900    |
+---------------------------+-------------+-------------+-------------+
```

---

## 9. Checklist Final

### Antes de Iniciar

- [ ] Azure Subscription ativa
- [ ] Azure OpenAI access aprovado
- [ ] Deployments GPT-4o e GPT-4o-mini criados
- [ ] Testou conexao com Azure OpenAI (curl)
- [ ] Microsoft 365 tenant configurado (se usar Teams)

### Copilot Studio

- [ ] Licenca Copilot Studio ativa
- [ ] Licenca Power Automate Premium ativa
- [ ] Dataverse configurado com tabelas de audit
- [ ] 9 Copilots criados com instrucoes
- [ ] Topics configurados para cada fase
- [ ] Power Automate flow importado e configurado
- [ ] Aprovacoes Teams testadas
- [ ] Copilots publicados no Teams

### Semantic Kernel

- [ ] .NET 8 SDK instalado
- [ ] Projeto restaurado (`dotnet restore`)
- [ ] User secrets configurados
- [ ] Cosmos DB criado com containers
- [ ] Key Vault configurado (producao)
- [ ] Executou localmente com sucesso
- [ ] App Service criado (producao)
- [ ] CI/CD pipeline configurado

### AutoGen

- [ ] Python 3.11+ instalado
- [ ] Ambiente virtual criado e ativado
- [ ] Dependencias instaladas (`pip install`)
- [ ] Arquivo .env configurado
- [ ] Executou pipeline de teste com auto-approve
- [ ] Testou checkpoints no modo console

### Integracao Teams

- [ ] App registrado no Azure AD
- [ ] Incoming Webhook criado no Teams
- [ ] Testou notificacao via webhook
- [ ] Approvals app instalado no Teams
- [ ] Testou fluxo completo de aprovacao

---

## Troubleshooting

### Erro: "Azure OpenAI resource not found"
- Verifique se o endpoint esta correto (inclui `https://` e `/`)
- Verifique se o deployment name esta correto

### Erro: "Rate limit exceeded"
- Aumente a capacidade do deployment no Azure Portal
- Implemente retry com exponential backoff

### Erro: "Cosmos DB request timeout"
- Verifique se o endpoint esta correto
- Verifique se o firewall permite acesso
- Aumente RU/s se necessario

### Erro: "Teams webhook 403"
- Verifique se o webhook esta ativo
- Verifique se o conector nao expirou
- Recrie o webhook se necessario

### Erro: "Copilot Studio topic not triggering"
- Verifique as trigger phrases
- Teste no painel de teste do Copilot Studio
- Verifique se o copilot esta publicado
