# ForgeSquad — Release & Distribution System

> **SHARED FILE** — instruções para versionamento, release e distribuição do ForgeSquad.

## Estrutura de Versão

ForgeSquad segue **Semantic Versioning** (SemVer):

```
MAJOR.MINOR.PATCH
  │     │     └─ Correções de bugs, ajustes de prompts, fixes de steps
  │     └────── Novos agentes, novos steps, novas skills, novos best-practices
  └──────────── Mudanças breaking (estrutura de diretórios, formato de YAML, pipeline incompatível)
```

**Exemplos:**
- `1.0.0` → Release inicial (Genesis)
- `1.1.0` → Adição do Finance Advisor (Ricardo)
- `1.1.1` → Fix no prompt do Finance Advisor
- `2.0.0` → Reestruturação do formato de pipeline (breaking change)

## Arquivos de Versão

| Arquivo | Contém | Quando atualizar |
|---------|--------|-----------------|
| `_forgesquad/config.yaml` | `version`, `release_date`, `codename` | A cada release |
| `CHANGELOG.md` | Histórico detalhado de mudanças | A cada release |
| `squads/*/squad.yaml` | `version` do squad | Quando o squad muda |

## O que é "Core" vs "Squad"

### Core (distribuído para todos os projetos)
```
_forgesquad/
├── config.yaml              ← versão do framework
├── core/
│   ├── architect.agent.yaml ← agente base do arquiteto
│   ├── runner.pipeline.md   ← motor de pipeline
│   ├── skills.engine.md     ← motor de skills
│   ├── release.md           ← este arquivo
│   ├── best-practices/      ← guias de boas práticas
│   └── prompts/             ← prompts compartilhados
├── _memory/
│   ├── company.md           ← contexto da empresa (NÃO distribuir)
│   ├── tech-stack.md        ← stack tecnológica (NÃO distribuir)
│   └── preferences.md       ← preferências (NÃO distribuir)

.claude/skills/forgesquad/
└── SKILL.md                 ← entry point do skill

skills/                      ← integrações de ferramentas
├── devin/SKILL.md
├── copilot/SKILL.md
├── stackspot/SKILL.md
├── kiro/SKILL.md
├── jira-sync/SKILL.md
└── sonarqube/SKILL.md

docs/
├── index.html               ← landing page
└── dashboard.html            ← dashboard interativo

CLAUDE.md                    ← instruções do projeto
CHANGELOG.md                 ← histórico de versões
```

### Squad (específico por projeto — NÃO distribuir como core)
```
squads/{nome}/
├── squad.yaml               ← definição do squad
├── squad-party.csv          ← personas dos agentes
├── agents/                  ← agentes customizados
├── pipeline/                ← pipeline e steps
├── output/                  ← artefatos gerados (NUNCA distribuir)
├── reports/                 ← relatórios (NUNCA distribuir)
└── _memory/                 ← memória do squad (NUNCA distribuir)
```

### Templates (distribuídos como exemplos)
```
templates/                   ← templates de squad para novos projetos
squads/forge-engineering/    ← squad de referência (pode ser distribuído como template)
```

## Como Criar uma Nova Release

### Passo 1: Atualizar versão

Edite `_forgesquad/config.yaml`:
```yaml
version: "X.Y.Z"
release_date: "YYYY-MM-DD"
codename: "NomeDoRelease"
```

### Passo 2: Atualizar CHANGELOG

Adicione uma nova seção no topo do `CHANGELOG.md`:
```markdown
## [X.Y.Z] — YYYY-MM-DD — "Codename"

### Adicionado
- ...

### Alterado
- ...

### Removido
- ...
```

### Passo 3: Gerar pacote de distribuição

Execute o comando de empacotamento (adaptar ao seu sistema):

```bash
# Criar diretório de release
RELEASE_DIR="/tmp/forgesquad-release-X.Y.Z"
mkdir -p "$RELEASE_DIR"

# Copiar core (sem dados sensíveis)
cp -r _forgesquad "$RELEASE_DIR/"
cp -r .claude/skills/forgesquad "$RELEASE_DIR/.claude/skills/forgesquad"
cp -r skills "$RELEASE_DIR/"
cp -r docs "$RELEASE_DIR/"
cp -r templates "$RELEASE_DIR/"
cp CLAUDE.md "$RELEASE_DIR/"
cp CHANGELOG.md "$RELEASE_DIR/"

# Limpar dados sensíveis
echo "<!-- NOT CONFIGURED -->" > "$RELEASE_DIR/_forgesquad/_memory/company.md"
echo "<!-- NOT CONFIGURED -->" > "$RELEASE_DIR/_forgesquad/_memory/tech-stack.md"
echo "<!-- NOT CONFIGURED -->" > "$RELEASE_DIR/_forgesquad/_memory/preferences.md"

# Copiar squad de referência como template
cp -r squads/forge-engineering "$RELEASE_DIR/templates/forge-engineering"

# Limpar outputs e reports do template
rm -rf "$RELEASE_DIR/templates/forge-engineering/output/"*
rm -rf "$RELEASE_DIR/templates/forge-engineering/reports/"*
rm -rf "$RELEASE_DIR/templates/forge-engineering/_memory/"*

# Empacotar
cd /tmp && tar -czf "forgesquad-X.Y.Z.tar.gz" "forgesquad-release-X.Y.Z/"
echo "Release empacotada: /tmp/forgesquad-X.Y.Z.tar.gz"
```

### Passo 4: Validar o pacote

Antes de distribuir:
- [ ] Versão em config.yaml está correta
- [ ] CHANGELOG.md está atualizado
- [ ] Nenhum dado sensível incluído (company.md, tech-stack.md, output/, reports/)
- [ ] Todos os skills referenciados existem
- [ ] Dashboard funciona em modo Demo
- [ ] SKILL.md entry point está presente
- [ ] CLAUDE.md está atualizado

## Como Instalar ForgeSquad em um Novo Projeto

### Instalação Fresh (novo projeto)

```bash
# 1. Extrair o pacote na raiz do projeto
cd /path/to/meu-projeto
tar -xzf forgesquad-X.Y.Z.tar.gz --strip-components=1

# 2. Verificar estrutura
ls _forgesquad/ .claude/skills/forgesquad/ skills/ docs/

# 3. Abrir Claude Code no projeto
# O CLAUDE.md será carregado automaticamente

# 4. Iniciar onboarding
# Digitar: /forgesquad
# O sistema detectará que company.md não está configurado e iniciará o onboarding
```

### Instalação em Projeto Existente (com ForgeSquad anterior)

```bash
# 1. Backup dos dados do projeto
cp -r _forgesquad/_memory /tmp/forgesquad-memory-backup
cp -r squads /tmp/forgesquad-squads-backup

# 2. Extrair nova versão (sobrescreve core, mantém squads)
cd /path/to/meu-projeto
tar -xzf forgesquad-X.Y.Z.tar.gz --strip-components=1 \
  --exclude='squads/*' \
  --exclude='_forgesquad/_memory/*'

# 3. Restaurar memória (se não sobrescrita)
# Os arquivos _memory/ e squads/ são preservados pelo --exclude

# 4. Verificar compatibilidade
# Digitar: /forgesquad
# O sistema carregará a nova versão com os dados existentes
```

## Como Atualizar Squads Existentes

Quando uma nova versão do ForgeSquad adiciona agentes ou steps, os squads existentes
precisam ser atualizados manualmente:

### Opção 1: Re-criar o squad (recomendado)

```
/forgesquad create "mesma descrição do projeto"
```

O Architect usará os novos agentes e steps disponíveis.

### Opção 2: Atualizar manualmente

1. Adicionar novo agente ao `squad.yaml` → seção `agents:`
2. Adicionar nova linha ao `squad-party.csv`
3. Copiar o arquivo `.agent.md` para `squads/{nome}/agents/`
4. Adicionar novos steps ao `pipeline/pipeline.yaml`
5. Copiar os arquivos de step para `pipeline/steps/`
6. Atualizar `depends_on` dos steps adjacentes

### Opção 3: Usar o editor integrado

```
/forgesquad edit meu-squad
```

O Architect guiará a adição de novos agentes e steps.

## Estratégia de Distribuição

### Para times internos (NTT DATA)

| Método | Quando usar | Como |
|--------|------------|------|
| **OneDrive/SharePoint** | Times pequenos, mesmo tenant | Compartilhar pasta ou .tar.gz via OneDrive |
| **Git repository** | Times técnicos, CI/CD | Repo privado no Azure DevOps ou GitHub Enterprise |
| **Azure Artifacts** | Distribuição corporativa | Publicar como pacote universal no Azure Artifacts |
| **Teams/Wiki** | Documentação | Publicar CHANGELOG e guia de instalação no Teams |

### Para distribuição externa

| Método | Quando usar | Como |
|--------|------------|------|
| **GitHub público** | Open source | Repo público com releases e tags |
| **npm/pip** | CLI tool | Empacotar como CLI instalável |
| **Docker** | Ambiente completo | Container com Claude Code + ForgeSquad pré-configurado |

## Compatibilidade entre Versões

| De → Para | Compatível? | Ação necessária |
|-----------|-------------|-----------------|
| 1.0.x → 1.1.x | Sim | Atualizar core, squads opcionalmente |
| 1.x → 2.x | Parcial | Seguir guia de migração do CHANGELOG |
| Qualquer → Qualquer | Memória preservada | `_memory/` nunca é sobrescrita em updates |

## Checklist de Release

- [ ] Versão incrementada em `config.yaml`
- [ ] CHANGELOG.md atualizado com todas as mudanças
- [ ] Nenhum dado sensível no pacote (company.md limpo)
- [ ] Todos os novos arquivos incluídos no pacote
- [ ] Dashboard testado em modo Demo
- [ ] Squad de referência (forge-engineering) atualizado
- [ ] Squads de template limpos (sem output/reports)
- [ ] README.md atualizado se necessário
- [ ] Tag de versão criada no git (se usando git)
