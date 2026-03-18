# DOCUMENTO DE ARQUITETURA PARA REGISTRO DE PATENTE

**Protocolo de Deposito:** Pedido de Patente de Invencao
**Data de Elaboracao:** 17 de marco de 2026
**Classificacao Internacional:** G06F 8/00 (Engenharia de Software); G06N 20/00 (Inteligencia Artificial)

---

## 1. TITULO DA INVENCAO

**ForgeSquad: Framework de Orquestracao Multi-Agente para Engenharia de Software com Pipeline Deterministico, Checkpoints Human-in-the-Loop e Integracao Plugavel de Ferramentas de IA**

---

## 2. RESUMO

A presente invencao refere-se a um framework de orquestracao multi-agente denominado ForgeSquad, projetado para automatizar e coordenar o ciclo de vida completo de engenharia de software — desde a elicitacao de requisitos ate a publicacao em producao e sustentacao. O sistema utiliza agentes de inteligencia artificial especializados, cada um com persona, principios operacionais e anti-padroes definidos em formato declarativo (YAML frontmatter + Markdown), orquestrados por um motor de pipeline deterministico com nove fases e vinte passos sequenciais. A invencao introduz um mecanismo inovador de checkpoints human-in-the-loop que garante a supervisao humana em sete pontos de decisao criticos, um sistema de veto e review loops com retorno automatico a passos anteriores, a omnipresenca de um agente arquiteto em todas as fases do ciclo de vida, e um motor de skills plugavel que permite integrar ferramentas externas de desenvolvimento (Devin, GitHub Copilot, StackSpot, Kiro, Jira, SonarQube) de forma modular e desacoplada. O framework resolve o problema fundamental da fragmentacao de ferramentas de IA na engenharia de software, onde cada ferramenta opera de forma isolada sem visao de ciclo de vida, e da ausencia de controle humano sistematico em processos de desenvolvimento assistidos por inteligencia artificial.

---

## 3. CAMPO DA INVENCAO

A presente invencao situa-se no campo da inteligencia artificial aplicada a engenharia de software, especificamente na intersecao de:

- **Sistemas multi-agente (MAS):** Coordenacao de multiplos agentes de IA com especializacoes distintas, comunicando-se atraves de handoffs estruturados e artefatos compartilhados.
- **Engenharia de software assistida por IA:** Automacao de atividades do ciclo de vida de desenvolvimento de software utilizando modelos de linguagem de grande porte (LLMs).
- **Orquestracao de workflows:** Motores de pipeline deterministicos com maquina de estados, dependencias entre passos e pontos de controle humano.
- **Engenharia de prompts declarativa:** Definicao de personas, comportamentos e restricoes de agentes de IA atraves de configuracao declarativa em vez de codigo imperativo.
- **Integracao de ferramentas de desenvolvimento:** Arquitetura plugavel para incorporar ferramentas de IA e plataformas de desenvolvimento de software existentes em um fluxo unificado.

---

## 4. ESTADO DA TECNICA

### 4.1 Ferramentas Existentes e Suas Limitacoes

O estado da tecnica em ferramentas de IA para engenharia de software compreende diversas solucoes, cada uma focada em um aspecto isolado do ciclo de vida de desenvolvimento:

**4.1.1 GitHub Copilot (Microsoft/GitHub)**
Assistente de programacao em pares baseado em IA que fornece sugestoes de codigo em tempo real. Limitacoes: opera exclusivamente na fase de implementacao; nao possui visao de ciclo de vida; nao gera requisitos, arquitetura, testes ou documentacao de forma coordenada; nao possui mecanismo de revisao arquitetural ou quality gates.

**4.1.2 Devin (Cognition AI)**
Agente autonomo de engenharia de software capaz de implementar funcionalidades completas. Limitacoes: executa tarefas de codificacao isoladamente; nao participa de fases anteriores (requisitos, arquitetura) nem posteriores (documentacao, deploy); nao possui mecanismo de coordenacao com outros agentes especializados.

**4.1.3 Kiro (AWS)**
Ferramenta de IA para geracao de requisitos e especificacoes. Limitacoes: foca exclusivamente na fase de requisitos; nao conecta os requisitos gerados a um pipeline de implementacao, teste e deploy.

**4.1.4 StackSpot**
Plataforma de infraestrutura como codigo com templates e stacks pre-construidos. Limitacoes: opera na camada de infraestrutura sem conexao com o ciclo de desenvolvimento de software.

**4.1.5 Sistemas Genéricos de Orquestracao Multi-Agente (CrewAI, AutoGen, LangGraph)**
Frameworks genericos para orquestracao de agentes de IA. Limitacoes: nao sao especializados em engenharia de software; nao possuem pipeline de ciclo de vida de software predefinido; nao incorporam checkpoints human-in-the-loop obrigatorios; nao possuem sistema de veto arquitetural; nao definem catalogo de papeis de engenharia (arquiteto, tech lead, QA, etc.).

### 4.2 Lacuna Identificada no Estado da Tecnica

Nenhuma solucao existente oferece:
1. Orquestracao multi-agente especializada em engenharia de software com cobertura de ciclo de vida completo (requisitos a sustentacao).
2. Checkpoints human-in-the-loop obrigatorios e sistematicos integrados ao pipeline.
3. Omnipresenca do agente arquiteto em todas as fases como guardiao da integridade estrutural.
4. Sistema de veto com review loops e retorno automatico a passos anteriores.
5. Motor de skills plugavel que unifica ferramentas de IA heterogeneas em um fluxo coerente.
6. Definicao declarativa de personas de agentes com princípios operacionais, anti-padroes e vocabulario de dominio.
7. Dashboard de monitoramento em tempo real da execucao do pipeline multi-agente.
8. Geracao automatica de relatorios gerenciais em cada checkpoint.

---

## 5. PROBLEMA TECNICO

O problema tecnico resolvido pela presente invencao compreende tres dimensoes fundamentais:

**5.1 Fragmentacao de Ferramentas de IA**
As ferramentas de IA atuais para engenharia de software operam como silos isolados. Um engenheiro que utiliza Kiro para requisitos, Copilot para codigo, Devin para tarefas autonomas e SonarQube para qualidade precisa manualmente coordenar as saidas de cada ferramenta, transferir contexto entre elas e garantir consistencia — um processo propenso a erros, perda de informacao e ineficiencia.

**5.2 Ausencia de Supervisao Humana Sistematica**
Os agentes de IA existentes executam tarefas sem pontos de controle obrigatorios para validacao humana. Decisoes criticas — como a aprovacao de uma arquitetura de software ou a autorizacao de deploy em producao — sao frequentemente delegadas integralmente a sistemas automatizados sem mecanismos formais de revisao e aprovacao humana.

**5.3 Falta de Governanca Arquitetural Continua**
Em projetos de software assistidos por IA, nao existe um mecanismo que garanta que decisoes arquiteturais sejam respeitadas ao longo de todo o ciclo de vida. Implementacoes podem divergir da arquitetura aprovada sem que exista um processo sistematico de verificacao continua.

---

## 6. SOLUCAO PROPOSTA

A solucao proposta e o framework ForgeSquad, composto pelos seguintes subsistemas interconectados:

1. **Sistema de Personas de Agentes:** Definicao declarativa de agentes especializados em papeis de engenharia de software (Arquiteto, Tech Lead, Business Analyst, Desenvolvedores, QA, Tech Writer, Project Manager) com persona, principios, anti-padroes e vocabulario de dominio.

2. **Motor de Pipeline Deterministico:** Execucao sequencial de 20 passos organizados em 9 fases, com dependencias explicitas entre passos, modos de execucao diferenciados (inline/subagent) e geracao de artefatos em cada passo.

3. **Sistema de Checkpoints Human-in-the-Loop:** 7 pontos de decisao obrigatorios onde a execucao e pausada para aprovacao humana, incluindo briefing do projeto, aprovacao de requisitos, revisao arquitetural, aprovacao de sprint, checkpoint de implementacao, go/no-go para producao e encerramento.

4. **Maquina de Estados:** Gerenciamento formal de estado do pipeline (idle, running, checkpoint, completed, failed) com persistencia em arquivo JSON e atualizacao antes de cada passo.

5. **Sistema de Veto e Review Loops:** Mecanismo de rejeicao com retorno automatico a passos anteriores, limitado a um numero maximo de ciclos de revisao, com escalacao para o usuario apos exaustao dos ciclos.

6. **Motor de Skills Plugavel:** Arquitetura de integracao modular para ferramentas externas, com resolucao automatica de dependencias, verificacao de disponibilidade e fallback gracioso para capacidades nativas.

7. **Omnipresenca do Arquiteto:** O agente Arquiteto participa de todas as 9 fases do pipeline como guardiao da integridade arquitetural.

8. **Sistema de Injecao de Boas Praticas:** Catalogo de 8 documentos de boas praticas injetados no contexto dos agentes conforme a fase de execucao.

9. **Dashboard de Monitoramento em Tempo Real:** Interface HTML que consome o arquivo state.json a cada 2 segundos para exibir o progresso da execucao com animacoes de handoff entre agentes.

10. **Geracao Automatica de Relatorios:** O agente Project Manager gera relatorios de status em cada checkpoint com metricas de progresso, artefatos gerados, decisoes tomadas, riscos e proximos passos.

---

## 7. DESCRICAO DETALHADA DA INVENCAO

### 7.1 Arquitetura Geral do Sistema

O ForgeSquad e composto por quatro camadas arquiteturais:

**Camada 1 — Interface de Comando (Skill Layer)**
Ponto de entrada do sistema, implementado como uma skill de IDE (Claude Code, Cursor, VS Code). Responsavel pelo roteamento de comandos, onboarding de novos usuarios e exibicao de menus interativos. O roteamento de comandos segue a tabela:

| Comando | Acao |
|---------|------|
| `/forgesquad` | Exibir menu principal |
| `/forgesquad create` | Carregar Arquiteto para fluxo de criacao |
| `/forgesquad run <nome>` | Carregar Pipeline Runner para execucao |
| `/forgesquad report <nome>` | Gerar relatorio do PM |
| `/forgesquad edit <nome>` | Carregar Arquiteto para edicao |
| `/forgesquad skills` | Exibir menu de ferramentas |
| `/forgesquad analyze <path>` | Carregar Arquiteto para engenharia reversa |
| `/forgesquad list` | Listar squads existentes |
| `/forgesquad delete <nome>` | Confirmar e remover squad |
| `/forgesquad settings` | Exibir/editar preferencias |

**Camada 2 — Nucleo de Orquestracao (Core Layer)**
Contem o Pipeline Runner, o Skills Engine, o agente Arquiteto core e o catalogo de boas praticas. Esta camada e compartilhada entre todos os ambientes de execucao e nao contem logica especifica de IDE.

**Camada 3 — Squads (Composition Layer)**
Instancias configuradas de equipes de engenharia, cada uma com seus agentes personalizados, pipeline especifico, dados de referencia e memoria persistente.

**Camada 4 — Integracao de Ferramentas (Skills Layer)**
Conectores modulares para ferramentas externas (Devin, Copilot, StackSpot, Kiro, Jira, SonarQube), cada um encapsulado em um diretorio com arquivo de configuracao SKILL.md.

A estrutura de diretorios reflete esta arquitetura em quatro camadas:

```
projeto/
  _forgesquad/                    # Camada 2: Nucleo
    config.yaml                   # Configuracao de tiers de modelos
    _memory/                      # Contexto persistente
      company.md                  # Perfil da empresa
      tech-stack.md               # Stack tecnologica
      preferences.md              # Preferencias do usuario
    core/                         # Motor central
      architect.agent.yaml        # Agente Arquiteto core
      runner.pipeline.md          # Motor de Pipeline
      skills.engine.md            # Motor de Skills
      best-practices/             # Catalogo de boas praticas
        _catalog.yaml             # Indice do catalogo
        api-design.md
        code-review.md
        testing.md
        documentation.md
        requirements.md
        deployment.md
        security.md
        observability.md
  skills/                         # Camada 4: Integracao
    devin/SKILL.md
    copilot/SKILL.md
    stackspot/SKILL.md
    kiro/SKILL.md
    jira-sync/SKILL.md
    sonarqube/SKILL.md
  squads/                         # Camada 3: Composicao
    {nome-do-squad}/
      squad.yaml                  # Configuracao do squad
      squad-party.csv             # Tabela de personas
      _memory/memories.md         # Memoria do squad
      agents/                     # Definicoes de agentes
        {papel}.agent.md
      pipeline/
        pipeline.yaml             # Definicao do pipeline
        steps/                    # Arquivos de passos
          step-{NN}-{nome}.md
        data/                     # Dados de referencia
          coding-standards.md
          architecture-guidelines.md
          testing-strategy.md
          definition-of-done.md
          definition-of-ready.md
          deployment-checklist.md
      output/                     # Artefatos gerados
      reports/                    # Relatorios do PM
  .claude/skills/forgesquad/      # Camada 1: Interface
    SKILL.md                      # Ponto de entrada
  docs/                           # Dashboard e documentacao
    dashboard.html
```

### 7.2 Sistema de Personas de Agentes

A invencao introduz um sistema declarativo de definicao de personas para agentes de IA especializados em engenharia de software. Cada agente e definido em dois niveis:

**Nivel 1 — Tabela de Identificacao (squad-party.csv)**
Formato CSV com campos: id, name, icon, role, path, execution, skills. Este nivel permite consulta rapida das propriedades de todos os agentes do squad:

```csv
id,name,icon,role,path,execution,skills
architect,Arq. Sofia Sistemas,<icone>,Projeta arquitetura...,./agents/architect.agent.md,inline,"web_search,web_fetch"
tech-lead,TL Rafael Review,<icone>,Coordena tecnicamente...,./agents/tech-lead.agent.md,inline,"copilot,devin"
business-analyst,BA Clara Requisitos,<icone>,Engenharia de requisitos...,./agents/business-analyst.agent.md,inline,"kiro,web_search"
dev-backend,Dev Bruno Backend,<icone>,Implementa APIs...,./agents/dev-backend.agent.md,subagent,"devin,copilot,stackspot"
dev-frontend,Dev Fernanda Front,<icone>,Implementa componentes UI...,./agents/dev-frontend.agent.md,subagent,"devin,copilot"
qa-engineer,QA Quesia Quality,<icone>,Define estrategia de testes...,./agents/qa-engineer.agent.md,inline,"devin,copilot"
tech-writer,TW Daniela Docs,<icone>,Produz documentacao tecnica...,./agents/tech-writer.agent.md,subagent,"web_search"
project-manager,PM Pedro Progress,<icone>,Gera relatorios de status...,./agents/project-manager.agent.md,inline,"jira-sync"
```

**Nivel 2 — Definicao Completa de Persona (*.agent.md)**
Cada agente possui um arquivo Markdown com YAML frontmatter contendo:

```yaml
---
base_agent: {tipo}           # Tipo base do catalogo
id: "{caminho/unico}"        # Identificador unico
name: "{Nome Completo}"      # Nome da persona
title: "{Titulo Profissional}"
icon: "{icone}"
squad: "{nome-do-squad}"
execution: inline|subagent   # Modo de execucao
skills:                      # Ferramentas habilitadas
  - skill1
  - skill2
tasks:                       # Tarefas atribuidas
  - tasks/tarefa1.md
  - tasks/tarefa2.md
---
```

O corpo do arquivo Markdown contem quatro secoes padronizadas:

1. **Calibration:** Responsabilidade principal, visao de atuacao e integracoes com ferramentas.
2. **Additional Principles:** Principios operacionais numerados que guiam o comportamento do agente.
3. **Anti-Patterns:** Lista de comportamentos proibidos que o agente deve evitar.
4. **Domain Vocabulary:** Glossario de termos do dominio de atuacao do agente.

O catalogo padrao de agentes da invencao compreende oito papeis:

| ID | Papel | Tipo | Presenca |
|----|-------|------|----------|
| architect | Arquiteto de Solucoes | architect | Obrigatorio (todas as fases) |
| tech-lead | Tech Lead | tech_lead | Obrigatorio |
| business-analyst | Analista de Negocios | business_analyst | Configuravel |
| dev-backend | Desenvolvedor Backend | developer_backend | Configuravel |
| dev-frontend | Desenvolvedor Frontend | developer_frontend | Configuravel |
| qa-engineer | Engenheiro de QA | qa_engineer | Obrigatorio |
| tech-writer | Technical Writer | tech_writer | Configuravel |
| project-manager | Gerente de Projeto | project_manager | Obrigatorio |

### 7.3 Motor de Pipeline

O motor de pipeline e o componente central de orquestracao do ForgeSquad. Ele executa um pipeline de engenharia de software composto por 20 passos organizados em 9 fases, cada fase representando uma etapa do ciclo de vida de desenvolvimento de software.

**Tabela Completa de Fases, Passos e Tipos:**

| Fase | Passo | Nome | Tipo | Agente | Dependencia |
|------|-------|------|------|--------|-------------|
| 1. Requisitos | step-01 | Briefing do Projeto | checkpoint | - | - |
| 1. Requisitos | step-02 | Elicitacao de Requisitos | agent | business-analyst | step-01 |
| 1. Requisitos | step-03 | Aprovacao dos Requisitos | checkpoint | - | step-02 |
| 2. Arquitetura | step-04 | Design de Arquitetura | agent | architect | step-03 |
| 2. Arquitetura | step-05 | Revisao Arquitetural | architectural_review | - | step-04 |
| 3. Planejamento | step-06 | Sprint Planning | agent | tech-lead | step-05 |
| 3. Planejamento | step-07 | Estrategia de Testes | agent | qa-engineer | step-06 |
| 3. Planejamento | step-08 | Aprovacao do Plano | checkpoint | - | step-07 |
| 4. Implementacao | step-09 | Implementacao Backend | agent | dev-backend | step-08 |
| 4. Implementacao | step-10 | Implementacao Frontend | agent | dev-frontend | step-09 |
| 4. Implementacao | step-11 | Checkpoint de Implementacao | checkpoint | - | step-10 |
| 5. Qualidade | step-12 | Testes Automatizados | agent | qa-engineer | step-11 |
| 5. Qualidade | step-13 | Testes de Performance | agent | qa-engineer | step-12 |
| 6. Code Review | step-14 | Code Review | code_review | tech-lead | step-13 |
| 6. Code Review | step-15 | Revisao Arquitetural do Codigo | agent | architect | step-14 |
| 7. Documentacao | step-16 | Documentacao Tecnica | agent | tech-writer | step-15 |
| 8. Deploy | step-17 | Go/No-Go para Producao | checkpoint | - | step-16 |
| 8. Deploy | step-18 | Deploy em Producao | agent | dev-backend | step-17 |
| 9. Sustentacao | step-19 | Relatorio Final | agent | project-manager | step-18 |
| 9. Sustentacao | step-20 | Encerramento | checkpoint | - | step-19 |

**Algoritmo de Execucao do Pipeline Runner:**

1. Carregar squad.yaml, squad-party.csv, contexto da empresa e memoria do squad.
2. Ler pipeline.yaml para obter a definicao do pipeline.
3. Resolver skills: verificar existencia de cada skill referenciada, instalar se necessario.
4. Carregar configuracao de tiers de modelos (config.yaml).
5. Inicializar pasta de execucao com ID unico (YYYY-MM-DD-HHmmss).
6. Inicializar state.json com estado "idle".
7. Copiar dashboard para output para monitoramento em tempo real.
8. Para cada passo do pipeline:
   a. Atualizar state.json (obrigatorio antes de cada passo).
   b. Ler o arquivo do passo (steps/step-{NN}-{nome}.md).
   c. Verificar o tipo do passo e executar conforme o modo:
      - `checkpoint`: pausar para interacao humana
      - `agent` com `execution: inline`: trocar persona e executar no contexto atual
      - `agent` com `execution: subagent`: despachar como subagente em segundo plano
      - `architectural_review`: carregar Arquiteto para revisao formal
      - `code_review`: carregar Tech Lead + Arquiteto para revisao de codigo
   d. Verificar condicoes de veto apos a execucao.
   e. Se ha handoff para proximo passo, animar a transicao no dashboard.
9. Ao concluir: salvar artefatos, gerar relatorio final, atualizar state.json para "completed".

### 7.4 Maquina de Estados

O ForgeSquad implementa uma maquina de estados formal para gerenciar o ciclo de vida da execucao do pipeline. O estado e persistido em um arquivo JSON (`state.json`) que serve como ponto de integracao entre o Pipeline Runner e o Dashboard de monitoramento.

**Estados do Pipeline:**

```
     +-------+
     | idle  |------> Inicializacao
     +-------+
         |
         v
     +---------+
     | running |<---+
     +---------+    |
         |          |
         v          |
   +------------+   |
   | checkpoint |---+  (usuario aprova -> retoma execucao)
   +------------+
         |
    +----+----+
    |         |
    v         v
+----------+ +--------+
| completed| | failed |
+----------+ +--------+
```

**Estrutura do state.json:**

```json
{
  "squad": "{codigo-do-squad}",
  "status": "idle|running|checkpoint|completed|failed",
  "phase": "{nome-da-fase-atual}",
  "step": {
    "current": 0,
    "total": 20,
    "label": "{nome-do-passo-atual}"
  },
  "agents": [
    {
      "id": "{id-do-agente}",
      "name": "{nome-display}",
      "icon": "{icone}",
      "status": "idle|working|done|blocked",
      "deliverTo": null,
      "desk": { "col": 0, "row": 0 }
    }
  ],
  "handoff": null,
  "metrics": {
    "steps_completed": 0,
    "checkpoints_passed": 0,
    "review_cycles": 0,
    "artifacts_generated": []
  },
  "startedAt": null,
  "updatedAt": "{ISO timestamp}"
}
```

**Transicoes de Estado dos Agentes:**

Os agentes individuais tambem possuem uma maquina de estados interna:

```
idle -> working     (agente e acionado pelo Pipeline Runner)
working -> done     (agente completa o passo com sucesso)
working -> blocked  (agente encontra impedimento)
done -> idle        (reset para proximo acionamento)
blocked -> working  (impedimento resolvido)
```

**Protocolo de Handoff entre Agentes:**

Quando um agente completa um passo e o proximo passo requer um agente diferente, o Pipeline Runner executa o protocolo de handoff:

1. Escrever no state.json: agente atual com status "delivering", proximo agente com status "idle".
2. Aguardar 2 segundos para animacao no dashboard.
3. Escrever no state.json: agente atual com status "done", proximo agente com status "working".

### 7.5 Sistema de Checkpoints Human-in-the-Loop

A invencao define 7 checkpoints obrigatorios onde a execucao do pipeline e interrompida para decisao humana. Este sistema garante que nenhuma decisao critica seja tomada exclusivamente por agentes de IA.

**Tabela de Checkpoints:**

| # | Passo | Nome | Fase | Decisao Requerida |
|---|-------|------|------|-------------------|
| 1 | step-01 | Briefing do Projeto | Requisitos | Confirmacao do escopo e contexto do projeto |
| 2 | step-03 | Aprovacao dos Requisitos | Requisitos | Validacao das user stories e criterios de aceite |
| 3 | step-05 | Revisao Arquitetural | Arquitetura | Aprovacao do design e ADRs |
| 4 | step-08 | Aprovacao do Plano de Sprint | Planejamento | Validacao das tasks, estimativas e estrategia de testes |
| 5 | step-11 | Checkpoint de Implementacao | Implementacao | Verificacao do andamento da implementacao |
| 6 | step-17 | Go/No-Go para Producao | Deploy | Decisao de deploy baseada em metricas de qualidade |
| 7 | step-20 | Encerramento | Sustentacao | Aceite final do projeto e handover |

**Comportamento do Checkpoint:**

1. O Pipeline Runner pausa a execucao e atualiza state.json para status "checkpoint".
2. Apresenta ao usuario um resumo contextualizado com informacoes relevantes para a decisao.
3. Aguarda input explicito do usuario (a pipeline nao avanca sem confirmacao humana).
4. Opcoes de decisao:
   - **Aprovar:** pipeline avanca para o proximo passo.
   - **Solicitar alteracoes:** pipeline retorna ao passo de producao correspondente.
   - **Rejeitar:** pipeline pode retornar a fases anteriores.
5. A decisao e registrada com timestamp e justificativa.
6. O Project Manager gera automaticamente um relatorio de status no checkpoint.

**Estrutura de um Arquivo de Checkpoint (exemplo: step-01-project-briefing.md):**

```yaml
---
step: "01"
name: "Briefing do Projeto"
type: checkpoint
depends_on: null
phase: requirements
---
```

O corpo do arquivo contem instrucoes para o Pipeline Runner sobre:
- Perguntas a fazer ao usuario.
- Comportamento esperado (interacao conversacional, confirmacao explicita).
- Quality Gate (lista de verificacao antes de avancar).
- Formato do artefato de saida esperado.

### 7.6 Motor de Skills

O Motor de Skills (Skills Engine) e o subsistema responsavel pela integracao modular de ferramentas externas ao framework. Cada skill e encapsulada em um diretorio contendo um arquivo SKILL.md com metadados em YAML frontmatter.

**Taxonomia de Skills:**

| Tipo | Descricao | Exemplos |
|------|-----------|----------|
| tool | Ferramenta externa de desenvolvimento | Devin, Copilot, StackSpot, Kiro |
| integration | Integracao com servico externo | Jira, SonarQube |
| native | Capacidade nativa do LLM | web_search, web_fetch |

**Estrutura de uma Skill:**

```yaml
---
name: "Nome da Skill"
description: "Descricao funcional"
type: tool|integration|native
version: "1.0.0"
category: development|infrastructure|requirements|quality|project-management
agents: [lista-de-agentes-autorizados]
---

# Documentacao da skill em Markdown
```

**Catalogo de Skills Pre-Instaladas:**

| Skill | Tipo | Categoria | Agentes Autorizados |
|-------|------|-----------|---------------------|
| Devin | tool | development | dev-backend, dev-frontend, qa-engineer, tech-lead |
| GitHub Copilot | tool | development | dev-backend, dev-frontend, qa-engineer, tech-lead |
| StackSpot | tool | infrastructure | dev-backend, architect |
| Kiro | tool | requirements | business-analyst, architect |
| Jira Sync | integration | project-management | project-manager, tech-lead |
| SonarQube | integration | quality | qa-engineer, tech-lead, architect |

**Algoritmo de Resolucao de Skills:**

1. Pipeline Runner le a secao `skills` do squad.yaml.
2. Para cada skill nao-nativa:
   a. Verificar se `skills/{skill}/SKILL.md` existe.
   b. Se nao existe: perguntar ao usuario se deseja instalar.
   c. Se sim: seguir procedimento de instalacao via Skills Engine.
   d. Se nao: ERRO — interromper pipeline.
3. Ler SKILL.md e verificar campo `type` no frontmatter.
4. Se type: mcp, verificar configuracao de MCP.
5. Ao acionar um agente, verificar se o agente esta na lista `agents` da skill.
6. Injetar instrucoes da skill no contexto do agente.
7. Se skill indisponivel em runtime: fallback para capacidades nativas com aviso.

### 7.7 Sistema de Injecao de Boas Praticas

O ForgeSquad inclui um subsistema de injecao contextual de boas praticas de engenharia de software. Um catalogo de 8 documentos de boas praticas e mantido no diretorio `_forgesquad/core/best-practices/`, e cada documento e injetado no contexto do agente relevante no momento de sua execucao.

**Catalogo de Boas Praticas:**

```yaml
practices:
  - id: api-design
    name: "API Design Best Practices"
    agents: [dev-backend, architect]
  - id: code-review
    name: "Code Review Guidelines"
    agents: [tech-lead, architect]
  - id: testing
    name: "Testing Best Practices"
    agents: [qa-engineer]
  - id: documentation
    name: "Technical Documentation Standards"
    agents: [tech-writer]
  - id: requirements
    name: "Requirements Engineering"
    agents: [business-analyst]
  - id: deployment
    name: "Deployment & CI/CD"
    agents: [dev-backend, architect]
  - id: security
    name: "Security Best Practices"
    agents: [architect, qa-engineer]
  - id: observability
    name: "Observability & Monitoring"
    agents: [architect, dev-backend]
```

**Mecanismo de Injecao:**

1. Cada arquivo de passo do pipeline pode conter um campo `best_practice` no frontmatter.
2. Quando o Pipeline Runner carrega um passo, verifica a presenca deste campo.
3. Se presente, le o arquivo de boas praticas correspondente em `_forgesquad/core/best-practices/`.
4. Concatena o conteudo de boas praticas ao contexto do agente antes da execucao.
5. O agente executa com conhecimento contextual das melhores praticas relevantes para a tarefa.

Adicionalmente, cada squad pode conter documentos de referencia proprios na pasta `pipeline/data/`, incluindo:
- `coding-standards.md` — Padroes de codificacao do projeto.
- `architecture-guidelines.md` — Diretrizes arquiteturais.
- `testing-strategy.md` — Estrategia de testes.
- `definition-of-done.md` — Criterios de conclusao.
- `definition-of-ready.md` — Criterios de prontidao.
- `deployment-checklist.md` — Lista de verificacao de deploy.

### 7.8 Omnipresenca do Arquiteto

Um aspecto inovador da invencao e o principio de omnipresenca do agente Arquiteto. Diferentemente de processos tradicionais onde o arquiteto participa apenas da fase de design, no ForgeSquad o Arquiteto esta presente em todas as 9 fases do ciclo de vida:

| Fase | Participacao do Arquiteto |
|------|---------------------------|
| 1. Requisitos | Avaliar viabilidade tecnica dos requisitos; identificar NFRs |
| 2. Arquitetura | Projetar a arquitetura do sistema; criar ADRs |
| 3. Planejamento | Validar tasks tecnicas; garantir alinhamento com a arquitetura |
| 4. Implementacao | Disponivel para consultas; validar decisoes tecnicas emergentes |
| 5. Qualidade | Definir criterios de qualidade arquitetural |
| 6. Code Review | Revisao arquitetural do codigo (step-15); verificar conformidade |
| 7. Documentacao | Revisar ADRs; validar documentacao tecnica |
| 8. Deploy | Validar checklist de deploy; avaliar riscos arquiteturais |
| 9. Sustentacao | Avaliar divida tecnica; recomendar evolucoes |

O agente Arquiteto core e definido no arquivo `_forgesquad/core/architect.agent.yaml` com os seguintes principios imutaveis:

- YAGNI — nunca criar agentes ou passos desnecessarios.
- Responsabilidade Unica — cada agente com exatamente uma responsabilidade clara.
- Checkpoints em todo ponto critico de decisao.
- O Arquiteto participa de TODAS as fases.
- Pesquisa e analise usam execucao subagent; tarefas criativas/implementacao usam inline.
- Pipeline mais simples possivel que alcance o objetivo.
- Todo squad deve ter agente QA e Tech Writer.
- Carregar contexto da empresa e tech stack para personalizar cada squad.
- Maximo de 5 perguntas de descoberta ao usuario.
- Considerar sempre requisitos nao-funcionais.
- Gerar ADRs para decisoes significativas.

### 7.9 Sistema de Veto e Review Loops

O ForgeSquad implementa um sistema de controle de qualidade baseado em condicoes de veto e ciclos de revisao que impedem a progressao de artefatos com qualidade insuficiente.

**Condicoes de Veto:**

1. Cada arquivo de passo pode conter uma secao `## Veto Conditions`.
2. Apos a execucao do agente, o Pipeline Runner avalia cada condicao contra o output.
3. Se QUALQUER condicao de veto e acionada:
   a. O usuario e informado sobre a condicao violada.
   b. O agente recebe instrucao de correcao direcionada.
   c. O agente reexecuta com foco na correcao.
   d. Maximo de 2 tentativas de correcao.
   e. Apos 2 falhas: escalacao para o usuario.

**Review Loops:**

1. Passos de revisao (type: code_review) possuem campo `on_reject` apontando para o passo de retorno.
2. Quando o revisor rejeita, a execucao retorna ao passo indicado com o feedback do revisor.
3. O campo `max_review_cycles` limita o numero de ciclos (padrao: 3).
4. Cada ciclo deve ter feedback especifico e acionavel.
5. Se o limite de ciclos e atingido: checkpoint automatico para decisao do usuario.

**Exemplo de Configuracao de Review Loop:**

```yaml
- id: step-14
  name: "Code Review"
  type: code_review
  agent: tech-lead
  on_reject: step-09        # Retorna a implementacao backend
  max_review_cycles: 3       # Maximo 3 ciclos
  phase: review
```

**Classificacao de Findings no Code Review:**

| Severidade | Descricao | Acao |
|------------|-----------|------|
| Blocker | Deve ser corrigido antes de prosseguir | Retorno obrigatorio |
| Major | Deve ser corrigido, pode ser em paralelo | Retorno recomendado |
| Minor | Sugestao de melhoria | Nao bloqueia |
| Info | Observacao educativa | Nao bloqueia |

### 7.10 Dashboard de Monitoramento em Tempo Real

O ForgeSquad inclui um dashboard HTML (`docs/dashboard.html`) que permite monitoramento visual em tempo real da execucao do pipeline multi-agente. O dashboard opera em dois modos:

**Modo Demo:** Simulacao da execucao com dados de demonstracao para apresentacao do framework.

**Modo Live:** Monitoramento em tempo real de uma execucao ativa, consumindo o arquivo `state.json` do squad via polling a cada 2 segundos.

**Funcionalidades do Dashboard:**

1. Visualizacao do escritorio virtual com representacao dos agentes em suas "mesas" de trabalho.
2. Indicadores visuais de status por agente (idle, working, done, blocked).
3. Animacao de handoff — quando um agente "entrega" um artefato para outro, o dashboard exibe a transicao.
4. Barra de progresso do pipeline com fase e passo atuais.
5. Metricas em tempo real (passos concluidos, checkpoints passados, ciclos de revisao).
6. Lista de artefatos gerados.

**Inicializacao do Dashboard pelo Pipeline Runner:**

1. O Pipeline Runner copia `docs/dashboard.html` para `squads/{nome}/output/dashboard.html`.
2. Informa ao usuario a URL local para abrir o dashboard.
3. Atualiza `state.json` antes de cada passo para que o dashboard reflita o progresso.

### 7.11 Geracao Automatica de Relatorios

O agente Project Manager (PM Pedro Progress) gera relatorios automaticamente em dois momentos:

1. **Em cada checkpoint:** Relatorio parcial com progresso ate o checkpoint.
2. **Na conclusao do pipeline:** Relatorio final consolidado.

**Conteudo do Relatorio:**

- Progresso da fase (porcentagem de conclusao).
- Artefatos gerados por fase.
- Decisoes tomadas em checkpoints (com timestamp e justificativa).
- Contagem de ciclos de revisao.
- Riscos e bloqueios identificados.
- Metricas de qualidade (cobertura de testes, findings de code review, SonarQube).
- Proximos passos.

**Armazenamento:** Relatorios sao salvos em `squads/{nome}/reports/{run_id}/report-{step-id}.md`.

**Principios do Project Manager:**

- Transparencia radical: relatorios mostram a realidade sem filtro.
- Metricas com contexto: numeros acompanhados de interpretacao.
- Report enxuto: summary executivo em 2 minutos de leitura.
- Bloqueios como prioridade: impedimentos no topo do relatorio.
- Forecast baseado em dados reais, nao estimativas otimistas.

---

## 8. INVENTARIO COMPLETO DE ARQUIVOS

### 8.1 Camada de Interface (Skill de Entrada)

| # | Arquivo | Descricao |
|---|---------|-----------|
| 1 | `.claude/skills/forgesquad/SKILL.md` | Ponto de entrada do framework; roteamento de comandos; onboarding |

### 8.2 Camada de Nucleo (Core)

| # | Arquivo | Descricao |
|---|---------|-----------|
| 2 | `_forgesquad/config.yaml` | Configuracao de tiers de modelos (powerful/fast) por papel |
| 3 | `_forgesquad/core/architect.agent.yaml` | Agente Arquiteto core com persona, menu, catalogo de agentes e templates de pipeline |
| 4 | `_forgesquad/core/runner.pipeline.md` | Motor de Pipeline Runner com regras de execucao, gerenciamento de estado e error handling |
| 5 | `_forgesquad/core/skills.engine.md` | Motor de Skills com operacoes CRUD, resolucao de dependencias e catalogo pre-instalado |
| 6 | `_forgesquad/core/best-practices/_catalog.yaml` | Indice do catalogo de boas praticas com mapeamento agente-pratica |
| 7 | `_forgesquad/core/best-practices/api-design.md` | Boas praticas de design de API |
| 8 | `_forgesquad/core/best-practices/code-review.md` | Diretrizes de code review |
| 9 | `_forgesquad/core/best-practices/testing.md` | Boas praticas de testes |
| 10 | `_forgesquad/core/best-practices/documentation.md` | Padroes de documentacao tecnica |
| 11 | `_forgesquad/core/best-practices/requirements.md` | Engenharia de requisitos |
| 12 | `_forgesquad/core/best-practices/deployment.md` | Deployment e CI/CD |
| 13 | `_forgesquad/core/best-practices/security.md` | Boas praticas de seguranca |
| 14 | `_forgesquad/core/best-practices/observability.md` | Observabilidade e monitoramento |

### 8.3 Camada de Memoria Persistente

| # | Arquivo | Descricao |
|---|---------|-----------|
| 15 | `_forgesquad/_memory/company.md` | Perfil da empresa do usuario |
| 16 | `_forgesquad/_memory/tech-stack.md` | Stack tecnologica preferida |
| 17 | `_forgesquad/_memory/preferences.md` | Preferencias do usuario (idioma, etc.) |

### 8.4 Camada de Skills (Integracoes)

| # | Arquivo | Descricao |
|---|---------|-----------|
| 18 | `skills/devin/SKILL.md` | Integracao com agente autonomo de codificacao Devin |
| 19 | `skills/copilot/SKILL.md` | Integracao com GitHub Copilot para pair programming |
| 20 | `skills/stackspot/SKILL.md` | Integracao com plataforma de IaC StackSpot |
| 21 | `skills/kiro/SKILL.md` | Integracao com ferramenta de requisitos Kiro |
| 22 | `skills/jira-sync/SKILL.md` | Integracao com Jira para rastreamento de projeto |
| 23 | `skills/sonarqube/SKILL.md` | Integracao com SonarQube para qualidade de codigo |

### 8.5 Squad: forge-engineering — Configuracao

| # | Arquivo | Descricao |
|---|---------|-----------|
| 24 | `squads/forge-engineering/squad.yaml` | Configuracao do squad de engenharia completo |
| 25 | `squads/forge-engineering/squad-party.csv` | Tabela de personas de todos os agentes |
| 26 | `squads/forge-engineering/_memory/memories.md` | Memoria persistente do squad |

### 8.6 Squad: forge-engineering — Agentes

| # | Arquivo | Descricao |
|---|---------|-----------|
| 27 | `squads/forge-engineering/agents/architect.agent.md` | Persona Arq. Sofia Sistemas |
| 28 | `squads/forge-engineering/agents/tech-lead.agent.md` | Persona TL Rafael Review |
| 29 | `squads/forge-engineering/agents/business-analyst.agent.md` | Persona BA Clara Requisitos |
| 30 | `squads/forge-engineering/agents/dev-backend.agent.md` | Persona Dev Bruno Backend |
| 31 | `squads/forge-engineering/agents/dev-frontend.agent.md` | Persona Dev Fernanda Front |
| 32 | `squads/forge-engineering/agents/qa-engineer.agent.md` | Persona QA Quesia Quality |
| 33 | `squads/forge-engineering/agents/tech-writer.agent.md` | Persona TW Daniela Docs |
| 34 | `squads/forge-engineering/agents/project-manager.agent.md` | Persona PM Pedro Progress |

### 8.7 Squad: forge-engineering — Pipeline

| # | Arquivo | Descricao |
|---|---------|-----------|
| 35 | `squads/forge-engineering/pipeline/pipeline.yaml` | Definicao do pipeline com 20 passos e 9 fases |
| 36 | `squads/forge-engineering/pipeline/steps/step-01-project-briefing.md` | Checkpoint: Briefing do Projeto |
| 37 | `squads/forge-engineering/pipeline/steps/step-02-requirements.md` | Agente: Elicitacao de Requisitos |
| 38 | `squads/forge-engineering/pipeline/steps/step-03-approve-requirements.md` | Checkpoint: Aprovacao dos Requisitos |
| 39 | `squads/forge-engineering/pipeline/steps/step-04-architecture-design.md` | Agente: Design de Arquitetura |
| 40 | `squads/forge-engineering/pipeline/steps/step-05-architecture-review.md` | Checkpoint: Revisao Arquitetural |
| 41 | `squads/forge-engineering/pipeline/steps/step-06-sprint-planning.md` | Agente: Sprint Planning |
| 42 | `squads/forge-engineering/pipeline/steps/step-07-test-strategy.md` | Agente: Estrategia de Testes |
| 43 | `squads/forge-engineering/pipeline/steps/step-08-approve-plan.md` | Checkpoint: Aprovacao do Plano |
| 44 | `squads/forge-engineering/pipeline/steps/step-09-backend-impl.md` | Agente: Implementacao Backend |
| 45 | `squads/forge-engineering/pipeline/steps/step-10-frontend-impl.md` | Agente: Implementacao Frontend |
| 46 | `squads/forge-engineering/pipeline/steps/step-11-impl-checkpoint.md` | Checkpoint: Implementacao |
| 47 | `squads/forge-engineering/pipeline/steps/step-12-automated-tests.md` | Agente: Testes Automatizados |
| 48 | `squads/forge-engineering/pipeline/steps/step-13-performance-tests.md` | Agente: Testes de Performance |
| 49 | `squads/forge-engineering/pipeline/steps/step-14-code-review.md` | Code Review: Tech Lead |
| 50 | `squads/forge-engineering/pipeline/steps/step-15-arch-code-review.md` | Agente: Revisao Arquitetural do Codigo |
| 51 | `squads/forge-engineering/pipeline/steps/step-16-documentation.md` | Agente: Documentacao Tecnica |
| 52 | `squads/forge-engineering/pipeline/steps/step-17-go-nogo.md` | Checkpoint: Go/No-Go para Producao |
| 53 | `squads/forge-engineering/pipeline/steps/step-18-deploy.md` | Agente: Deploy em Producao |
| 54 | `squads/forge-engineering/pipeline/steps/step-19-final-report.md` | Agente: Relatorio Final |
| 55 | `squads/forge-engineering/pipeline/steps/step-20-closure.md` | Checkpoint: Encerramento |

### 8.8 Squad: forge-engineering — Dados de Referencia

| # | Arquivo | Descricao |
|---|---------|-----------|
| 56 | `squads/forge-engineering/pipeline/data/coding-standards.md` | Padroes de codificacao |
| 57 | `squads/forge-engineering/pipeline/data/architecture-guidelines.md` | Diretrizes arquiteturais |
| 58 | `squads/forge-engineering/pipeline/data/testing-strategy.md` | Estrategia de testes |
| 59 | `squads/forge-engineering/pipeline/data/definition-of-done.md` | Criterios de conclusao |
| 60 | `squads/forge-engineering/pipeline/data/definition-of-ready.md` | Criterios de prontidao |
| 61 | `squads/forge-engineering/pipeline/data/deployment-checklist.md` | Checklist de deploy |

### 8.9 Squad: tokenops (Squad Adicional)

| # | Arquivo | Descricao |
|---|---------|-----------|
| 62 | `squads/tokenops/squad.yaml` | Configuracao do squad TokenOps |
| 63 | `squads/tokenops/squad-party.csv` | Tabela de personas |
| 64 | `squads/tokenops/_memory/memories.md` | Memoria do squad |
| 65-72 | `squads/tokenops/agents/*.agent.md` | Agentes do squad (8 agentes) |
| 73 | `squads/tokenops/pipeline/pipeline.yaml` | Pipeline do squad |
| 74-93 | `squads/tokenops/pipeline/steps/step-*.md` | Passos do pipeline (20 passos) |
| 94-99 | `squads/tokenops/pipeline/data/*.md` | Dados de referencia (6 arquivos) |

### 8.10 Documentacao e Infraestrutura

| # | Arquivo | Descricao |
|---|---------|-----------|
| 100 | `docs/dashboard.html` | Dashboard de monitoramento em tempo real |
| 101 | `docs/index.html` | Pagina index da documentacao |
| 102 | `docs/serve.py` | Servidor Python para o dashboard |
| 103 | `docs/server.rb` | Servidor Ruby para o dashboard |
| 104 | `CLAUDE.md` | Instrucoes do projeto para o LLM |
| 105 | `README.md` | Documentacao do projeto |
| 106 | `.gitignore` | Regras de exclusao do Git |

**Total de arquivos inventariados: 106 arquivos**

---

## 9. DIAGRAMAS DE ARQUITETURA

### 9.1 Diagrama de Componentes do Sistema

```
+===============================================================+
|                       ForgeSquad Framework                      |
+===============================================================+
|                                                                 |
|  +-------------------+     +----------------------------+       |
|  | CAMADA 1:         |     | CAMADA 4:                  |       |
|  | Interface         |     | Integracao de Ferramentas   |       |
|  |                   |     |                            |       |
|  | /forgesquad       |     | +--------+ +--------+     |       |
|  | (SKILL.md)        |     | | Devin  | |Copilot |     |       |
|  | - Roteamento      |     | +--------+ +--------+     |       |
|  | - Onboarding      |     | +--------+ +--------+     |       |
|  | - Menus           |     | |StackSpt| | Kiro   |     |       |
|  +--------+----------+     | +--------+ +--------+     |       |
|           |                | +--------+ +--------+     |       |
|           v                | |Jira Syn| |SonarQub|     |       |
|  +--------+----------+     | +--------+ +--------+     |       |
|  | CAMADA 2:         |     +-------------+--------------+       |
|  | Nucleo            |                   |                      |
|  |                   |                   |                      |
|  | +---------------+ |    +--------------v-----------+          |
|  | |Pipeline Runner| |    | Skills Engine             |          |
|  | | (9 fases,     +----->| - Resolucao de skills     |          |
|  | |  20 passos)   | |    | - Verificacao de deps     |          |
|  | +-------+-------+ |    | - Fallback nativo         |          |
|  |         |          |    +--------------------------+          |
|  | +-------v-------+ |                                          |
|  | |State Machine  | |    +---------------------------+         |
|  | |(state.json)   +----->| Dashboard (HTML)          |         |
|  | +---------------+ |    | - Polling 2s              |         |
|  |                   |    | - Modo Demo/Live          |         |
|  | +---------------+ |    +---------------------------+         |
|  | |Architect Core | |                                          |
|  | |(omnipresente) | |    +---------------------------+         |
|  | +---------------+ |    | Best Practices Catalog    |         |
|  |                   |    | (8 documentos)            |         |
|  | +---------------+ |    +---------------------------+         |
|  | |Model Config   | |                                          |
|  | |(config.yaml)  | |    +---------------------------+         |
|  | +---------------+ |    | Memory (company, tech,    |         |
|  +-------------------+    |  preferences)             |         |
|                           +---------------------------+         |
|  +----------------------------------------------------------+  |
|  | CAMADA 3: Squads (Composicao)                             |  |
|  |                                                           |  |
|  | +------------------+  +------------------+                |  |
|  | | forge-engineering|  | tokenops         |  ...           |  |
|  | |                  |  |                  |                |  |
|  | | squad.yaml       |  | squad.yaml       |                |  |
|  | | squad-party.csv  |  | squad-party.csv  |                |  |
|  | | agents/ (8)      |  | agents/ (8)      |                |  |
|  | | pipeline/ (20)   |  | pipeline/ (20)   |                |  |
|  | | data/ (6)        |  | data/ (6)        |                |  |
|  | | output/          |  | output/          |                |  |
|  | | reports/         |  | reports/         |                |  |
|  | +------------------+  +------------------+                |  |
|  +----------------------------------------------------------+  |
+===============================================================+
```

### 9.2 Diagrama de Fluxo do Pipeline

```
FASE 1: REQUISITOS              FASE 2: ARQUITETURA
+----------+    +----------+    +----------+    +----------+
|  step-01 |--->|  step-02 |--->|  step-03 |--->|  step-04 |
| BRIEFING |    | REQUISIT |    | APROVAC. |    | DESIGN   |
|checkpoint|    | BA Clara |    |checkpoint|    | Arq Sofia|
+----------+    +----------+    +----------+    +----+-----+
                                                     |
                                                     v
FASE 3: PLANEJAMENTO                            +----------+
+----------+    +----------+    +----------+    |  step-05 |
|  step-08 |<---|  step-07 |<---|  step-06 |<---|  REVISAO |
| APROVAC. |    | TEST STR |    | SPRINT   |    |arch_revw |
|checkpoint|    | QA Quesia|    | TL Rafael|    +----------+
+----+-----+    +----------+    +----------+
     |
     v
FASE 4: IMPLEMENTACAO           FASE 5: QUALIDADE
+----------+    +----------+    +----------+    +----------+
|  step-09 |--->|  step-10 |--->|  step-11 |--->|  step-12 |
| BACKEND  |    | FRONTEND |    | CHECKPT  |    | AUTO TST |
| Dev Bruno|    |Dev Fernan|    |checkpoint|    | QA Quesia|
+----------+    +----------+    +----------+    +----+-----+
     ^                                               |
     |                                               v
     |          FASE 6: CODE REVIEW             +----------+
     |          +----------+    +----------+    |  step-13 |
     +<---------|  step-14 |<---|  step-15 |<---|  PERF TST|
   on_reject    |CODE REVW |    | ARCH REV |    | QA Quesia|
   (max 3x)     | TL Rafael|    | Arq Sofia|    +----------+
                |code_revw |    +----------+
                +----+-----+
                     |
                     v
FASE 7: DOCS        FASE 8: DEPLOY              FASE 9: SUSTENTACAO
+----------+    +----------+    +----------+    +----------+    +----------+
|  step-16 |--->|  step-17 |--->|  step-18 |--->|  step-19 |--->|  step-20 |
| DOCUMEN  |    | GO/NO-GO |    |  DEPLOY  |    | RELATOR  |    | ENCERRAM |
| TW Daniel|    |checkpoint|    | Dev Bruno|    | PM Pedro |    |checkpoint|
+----------+    +----------+    +----------+    +----------+    +----------+
```

### 9.3 Diagrama da Maquina de Estados

```
                    Inicializacao
                         |
                         v
                    +----------+
            +------>|   IDLE   |
            |       +-----+----+
            |             |
            |        run command
            |             |
            |             v
            |       +----------+
            |   +-->| RUNNING  |<---------+
            |   |   +-----+----+          |
            |   |         |               |
            |   |    step completo        |
            |   |    (proximo e           |
            |   |     checkpoint?)        |
            |   |         |               |
            |   |    +----+----+          |
            |   |    |         |          |
            |   |   Nao       Sim         |
            |   |    |         |          |
            |   |    |         v          |
            |   |    |  +------------+    |
            |   |    |  | CHECKPOINT |----+
            |   |    |  +-----+------+  usuario
            |   |    |        |         aprova
            |   |    |   usuario
            |   |    |   rejeita
            |   |    |        |
            |   |    |        v
            |   |    |  retorno a
            |   |    |  passo anterior
            |   |    |        |
            |   +----+--------+
            |
            |   pipeline completo     erro fatal
            |         |                    |
            |         v                    v
            |   +-----------+       +----------+
            +---|COMPLETED  |       |  FAILED  |
                +-----------+       +----------+
```

### 9.4 Diagrama de Interacao entre Agentes

```
                        +-------------------+
                        |  Pipeline Runner  |
                        | (Orquestrador)    |
                        +---------+---------+
                                  |
           +----------+-----------+----------+----------+
           |          |           |          |          |
           v          v           v          v          v
    +----------+ +----------+ +----------+ +------+ +------+
    |Arq. Sofia| |TL Rafael | |BA Clara  | |QA    | |PM    |
    |Arquiteta | |Tech Lead | |Analista  | |Quesia| |Pedro |
    +----+-----+ +----+-----+ +----+-----+ +--+---+ +--+---+
         |             |            |           |        |
    TODAS AS      +----+----+       |           |        |
    FASES         |         |       |           |        |
         |        v         v       |           |        |
         |   +--------+ +--------+ |           |        |
         |   |Dev     | |Dev     | |           |        |
         |   |Bruno   | |Fernanda| |           |        |
         |   |Backend | |Frontend| |           |        |
         |   +---+----+ +---+----+ |           |        |
         |       |           |     |           |        |
         |       +-----+-----+    |           |        |
         |             |          |           |        |
         v             v          v           v        v
    +---------+   +---------+ +--------+ +--------+ +--------+
    |ADRs     |   |Codigo   | |User    | |Test    | |Status  |
    |Arch.Doc |   |Backend  | |Stories | |Report  | |Reports |
    |Reviews  |   |Frontend | |AC      | |Perf.Rp | |Metrics |
    +---------+   +---------+ +--------+ +--------+ +--------+
         |             |          |           |        |
         +-------------+----------+-----------+--------+
                                  |
                                  v
                        +-------------------+
                        |  TW Daniela Docs  |
                        |  (Documentacao)   |
                        +-------------------+
                                  |
                                  v
                        +-------------------+
                        | API Docs, Runbook,|
                        | Release Notes,ADRs|
                        +-------------------+
```

### 9.5 Diagrama de Integracao de Skills

```
+================================================================+
|                     Skills Engine                                |
|                                                                  |
|  Resolucao: squad.yaml -> skills[] -> skills/{nome}/SKILL.md    |
|                                                                  |
|  +------------------+    +------------------+                    |
|  | TIPO: tool        |    | TIPO: integration |                    |
|  |                  |    |                  |                    |
|  | +------+  +----+ |    | +------+ +-----+ |                    |
|  | |Devin |  |Copi| |    | |Jira  | |Sonar| |                    |
|  | |      |  |lot | |    | |Sync  | |Qube | |                    |
|  | +--+---+  +-+--+ |    | +--+---+ +--+--+ |                    |
|  |    |        |     |    |    |        |     |                    |
|  | +--+---+  +-+--+ |    | +--+---+    |     |                    |
|  | |Stack |  |Kiro| |    | |      |    |     |                    |
|  | |Spot  |  |    | |    | |      |    |     |                    |
|  | +------+  +----+ |    | +------+    |     |                    |
|  +--------+---------+    +-----+-------+-----+                    |
|           |                    |       |                          |
|      +----+----+          +----+--+ +--+---+                     |
|      |         |          |       | |      |                     |
|      v         v          v       v v      v                     |
|  +------+ +--------+ +------+ +------+ +------+                 |
|  |dev-  | |dev-    | |PM    | |QA    | |Archi-|                 |
|  |back  | |front   | |Pedro | |Quesia| |tect  |                 |
|  +------+ +--------+ +------+ +------+ +------+                 |
|                                                                  |
|  TIPO: native                                                    |
|  +------------------+                                            |
|  | web_search       | -> Todos os agentes com skills: native     |
|  | web_fetch        |                                            |
|  +------------------+                                            |
|                                                                  |
|  FALLBACK: Se skill indisponivel -> capacidade nativa + aviso    |
+================================================================+
```

### 9.6 Diagrama de Configuracao de Tiers de Modelos

```
+========================================+
|         Model Tier Configuration        |
+========================================+
|                                        |
|  TIER: powerful (raciocinio profundo)  |
|  +----------------------------------+ |
|  | Orquestrador (Pipeline Runner)   | |
|  | Arquiteto (Sofia)                | |
|  | Tech Lead (Rafael)               | |
|  | Business Analyst (Clara)         | |
|  | Dev Backend (Bruno)              | |
|  | Dev Frontend (Fernanda)          | |
|  | QA Engineer (Quesia)             | |
|  +----------------------------------+ |
|                                        |
|  TIER: fast (padronizacao rapida)      |
|  +----------------------------------+ |
|  | Tech Writer (Daniela)            | |
|  | Project Manager (Pedro)          | |
|  +----------------------------------+ |
|                                        |
|  Mapeamento por IDE:                   |
|  Claude Code: powerful=opus, fast=haiku|
|  Cursor:      powerful=opus, fast=haiku|
|  Copilot:     powerful=gpt-4o,        |
|               fast=gpt-4o-mini         |
+========================================+
```

---

## 10. REIVINDICACOES

### Reivindicacoes Independentes

**Reivindicacao 1.** Framework de orquestracao multi-agente para engenharia de software, CARACTERIZADO POR compreender: (a) um sistema de definicao declarativa de personas de agentes especializados em papeis de engenharia de software, cada persona definida por frontmatter YAML com metadados operacionais e corpo Markdown com calibracao, principios, anti-padroes e vocabulario de dominio; (b) um motor de pipeline deterministico que executa sequencialmente passos organizados em fases do ciclo de vida de desenvolvimento de software, com dependencias explicitas entre passos e modos de execucao diferenciados; (c) um sistema de checkpoints human-in-the-loop que pausa a execucao em pontos de decisao criticos para aprovacao humana obrigatoria; (d) uma maquina de estados com persistencia em arquivo para rastreamento de progresso; e (e) um motor de skills plugavel para integracao modular de ferramentas externas de desenvolvimento.

**Reivindicacao 2.** Metodo de orquestracao multi-agente para automacao de ciclo de vida de engenharia de software, CARACTERIZADO POR compreender as etapas de: (a) inicializar o pipeline com carregamento de contexto da empresa, stack tecnologica, memoria do squad e resolucao de skills; (b) executar sequencialmente passos de pipeline com verificacao de dependencias e troca de personas de agentes; (c) pausar a execucao em checkpoints predefinidos para coleta de decisao humana; (d) aplicar condicoes de veto sobre outputs de agentes com retentativas automaticas; (e) executar review loops com retorno a passos anteriores quando output e rejeitado; (f) gerar relatorios gerenciais automaticamente em cada checkpoint; e (g) persistir o estado da execucao para monitoramento em tempo real.

**Reivindicacao 3.** Sistema de definicao declarativa de personas de agentes de inteligencia artificial para engenharia de software, CARACTERIZADO POR compreender: (a) um formato hibrido YAML-Markdown onde o frontmatter YAML define metadados operacionais (id, nome, tipo, modo de execucao, skills autorizadas, tarefas atribuidas) e o corpo Markdown define calibracao comportamental, principios operacionais, anti-padroes proibidos e vocabulario de dominio; (b) um catalogo de papeis predefinidos (arquiteto, tech lead, analista de negocios, desenvolvedor backend, desenvolvedor frontend, engenheiro QA, tech writer, gerente de projeto); e (c) uma tabela CSV (squad-party.csv) para consulta rapida das propriedades de todos os agentes do squad.

### Reivindicacoes Dependentes

**Reivindicacao 4.** Framework conforme reivindicacao 1, CARACTERIZADO POR o motor de pipeline compreender exatamente nove fases (Requisitos, Arquitetura, Planejamento, Implementacao, Qualidade, Code Review, Documentacao, Deploy, Sustentacao) com exatamente vinte passos sequenciais.

**Reivindicacao 5.** Framework conforme reivindicacao 1, CARACTERIZADO POR o sistema de checkpoints compreender exatamente sete pontos de decisao obrigatorios: briefing do projeto, aprovacao de requisitos, revisao arquitetural, aprovacao do plano de sprint, checkpoint de implementacao, go/no-go para producao e encerramento.

**Reivindicacao 6.** Framework conforme reivindicacao 1, CARACTERIZADO POR implementar o principio de omnipresenca do agente arquiteto, pelo qual o agente com papel de arquiteto participa ativamente em todas as nove fases do ciclo de vida como guardiao da integridade arquitetural do sistema.

**Reivindicacao 7.** Framework conforme reivindicacao 1, CARACTERIZADO POR o motor de pipeline suportar dois modos de execucao de agentes: (a) modo inline, onde o agente executa no contexto da conversa atual com troca de persona; e (b) modo subagent, onde o agente e despachado como processo em segundo plano com contexto completo e verificacao de output na conclusao.

**Reivindicacao 8.** Framework conforme reivindicacao 1, CARACTERIZADO POR a maquina de estados compreender cinco estados do pipeline (idle, running, checkpoint, completed, failed) e quatro estados de agente (idle, working, done, blocked), com protocolo de handoff que inclui animacao de entrega entre agentes com delay configuravel.

**Reivindicacao 9.** Framework conforme reivindicacao 1, CARACTERIZADO POR o sistema de veto compreender: (a) secoes de condicoes de veto definidas nos arquivos de passo; (b) avaliacao automatica de cada condicao contra o output do agente; (c) mecanismo de retentativa com correcao direcionada, limitado a maximo de duas tentativas; e (d) escalacao para o usuario apos exaustao das tentativas.

**Reivindicacao 10.** Framework conforme reivindicacao 1, CARACTERIZADO POR o sistema de review loops compreender: (a) campo on_reject no passo de revisao apontando para o passo de retorno; (b) transferencia automatica do feedback do revisor para o agente responsavel; (c) limite maximo de ciclos de revisao (max_review_cycles); e (d) escalacao para checkpoint humano apos exaustao dos ciclos.

**Reivindicacao 11.** Framework conforme reivindicacao 1, CARACTERIZADO POR o motor de skills implementar tres tipos de skills (tool, integration, native), cada skill encapsulada em diretorio contendo arquivo SKILL.md com frontmatter YAML (name, description, type, version, category, agents) e corpo Markdown com documentacao de uso, e com algoritmo de resolucao que verifica existencia, autoriza agentes, injeta instrucoes e implementa fallback gracioso para capacidades nativas.

**Reivindicacao 12.** Framework conforme reivindicacao 1, CARACTERIZADO POR incluir um sistema de injecao contextual de boas praticas de engenharia de software, compreendendo um catalogo indexado de documentos de boas praticas (api-design, code-review, testing, documentation, requirements, deployment, security, observability) mapeados a agentes especificos e injetados no contexto do agente no momento de execucao conforme campo best_practice no frontmatter do passo.

**Reivindicacao 13.** Framework conforme reivindicacao 1, CARACTERIZADO POR incluir um dashboard de monitoramento em tempo real implementado como pagina HTML que consome o arquivo state.json via polling periodico, exibindo escritorio virtual com representacao dos agentes, indicadores de status, animacoes de handoff, barra de progresso e metricas, operando em dois modos (Demo e Live).

**Reivindicacao 14.** Framework conforme reivindicacao 1, CARACTERIZADO POR implementar um sistema de configuracao de tiers de modelos de linguagem, onde cada papel de agente e associado a um tier (powerful ou fast) que e resolvido para o modelo concreto conforme o ambiente de execucao (Claude Code, Cursor, Copilot), garantindo que papeis que requerem raciocinio profundo (orquestrador, arquiteto, tech lead, analista, desenvolvedores, QA) utilizem modelos de maior capacidade e papeis de padronizacao (tech writer, project manager) utilizem modelos mais eficientes.

**Reivindicacao 15.** Framework conforme reivindicacao 1, CARACTERIZADO POR implementar um sistema de memoria persistente em tres niveis: (a) memoria global da empresa (company.md, tech-stack.md, preferences.md) carregada em todas as execucoes; (b) memoria do squad (memories.md) com aprendizados acumulados de execucoes anteriores; e (c) dados de referencia do pipeline (coding-standards, architecture-guidelines, testing-strategy, definition-of-done, definition-of-ready, deployment-checklist) carregados conforme a fase de execucao.

**Reivindicacao 16.** Metodo conforme reivindicacao 2, CARACTERIZADO POR a etapa de checkpoint Go/No-Go para producao compilar e apresentar um dashboard consolidado contendo status de testes (unitarios, integracao, E2E, performance, cobertura), status de reviews (code review, revisao arquitetural, ciclos), qualidade de codigo (blockers, majors, divida tecnica), documentacao (API docs, runbook, release notes) e riscos remanescentes, emitindo recomendacao (GO, GO com condicoes, NO-GO) para decisao do usuario.

**Reivindicacao 17.** Framework conforme reivindicacao 1, CARACTERIZADO POR suportar tres templates de pipeline predefinidos: (a) Greenfield, com fases de requisitos, design arquitetural, planejamento, implementacao, teste, code review, documentacao, deploy e sustentacao; (b) Brownfield, com fases adicionais de engenharia reversa, avaliacao arquitetural e migracao; e (c) Sustaining, com fases de triagem de incidentes, analise de causa raiz, implementacao de correcao, teste, code review, deploy e post-mortem.

---

## 11. VANTAGENS DA INVENCAO

A presente invencao apresenta as seguintes vantagens em relacao ao estado da tecnica:

**11.1 Cobertura de Ciclo de Vida Completo**
Diferentemente de ferramentas isoladas que cobrem apenas uma fase (Copilot para codificacao, Kiro para requisitos), o ForgeSquad orquestra o ciclo de vida completo de requisitos a sustentacao com um unico framework, eliminando a fragmentacao de ferramentas e a perda de contexto entre fases.

**11.2 Supervisao Humana Sistematica**
Os 7 checkpoints obrigatorios garantem que nenhuma decisao critica e tomada exclusivamente por agentes de IA. O sistema impoe governanca sem burocracia, equilibrando automacao com controle humano.

**11.3 Governanca Arquitetural Continua**
A omnipresenca do Arquiteto em todas as 9 fases garante que decisoes arquiteturais sejam respeitadas desde os requisitos ate a sustentacao, prevenindo a divergencia entre design e implementacao.

**11.4 Qualidade Garantida por Design**
O sistema de veto, review loops com retorno automatico, condicoes de veto com retentativas e classificacao de findings (Blocker/Major/Minor/Info) implementam controle de qualidade nativo no pipeline, nao como etapa posterior.

**11.5 Integracao Modular de Ferramentas**
O motor de skills permite integrar qualquer ferramenta de desenvolvimento existente de forma plugavel, sem alterar o nucleo do framework. O fallback gracioso para capacidades nativas garante que o pipeline execute mesmo quando ferramentas externas estao indisponiveis.

**11.6 Definicao Declarativa de Agentes**
O formato YAML+Markdown para definicao de personas permite criar e personalizar agentes sem programacao, tornando o framework acessivel a equipes sem expertise em IA. Os anti-padroes documentados previnem comportamentos indesejados.

**11.7 Monitoramento em Tempo Real**
O dashboard HTML com polling do state.json permite que stakeholders acompanhem a execucao do pipeline visualmente, com animacoes de handoff entre agentes, sem necessidade de acesso ao ambiente de desenvolvimento.

**11.8 Relatorios Gerenciais Automaticos**
A geracao automatica de relatorios pelo Project Manager em cada checkpoint elimina o trabalho manual de reportar progresso, garantindo transparencia para stakeholders.

**11.9 Memoria Persistente**
O sistema de memoria em tres niveis (empresa, squad, pipeline) garante que o contexto organizacional, aprendizados anteriores e padroes do projeto sejam preservados entre execucoes, permitindo melhoria continua.

**11.10 Reprodutibilidade**
A natureza declarativa do pipeline (pipeline.yaml, steps/*.md, agents/*.agent.md) garante que squads podem ser reproduzidos, compartilhados e versionados como codigo, permitindo evolucao controlada dos processos de engenharia.

---

## 12. APLICACOES INDUSTRIAIS

A presente invencao possui aplicabilidade industrial nos seguintes dominios:

**12.1 Desenvolvimento de Software Empresarial**
Equipes de engenharia de software em empresas de medio e grande porte podem utilizar o ForgeSquad para automatizar e padronizar seus processos de desenvolvimento, garantindo aderencia a padroes de qualidade, governanca arquitetural e rastreabilidade de decisoes.

**12.2 Consultorias de Tecnologia**
Empresas de consultoria podem utilizar o framework para padronizar a entrega de projetos de software para clientes, criando squads reutilizaveis com pipelines customizados por tipo de projeto (greenfield, brownfield, sustentacao).

**12.3 Software Houses e Fabricas de Software**
Organizacoes com multiplos projetos simultaneos podem utilizar o ForgeSquad para garantir consistencia de processos, qualidade e documentacao entre diferentes equipes e projetos.

**12.4 Educacao e Treinamento**
Instituicoes de ensino podem utilizar o framework como ferramenta pedagogica para ensinar processos de engenharia de software, demonstrando o ciclo de vida completo com agentes especializados em cada papel.

**12.5 Conformidade e Auditoria**
Organizacoes em setores regulamentados (financeiro, saude, governamental) podem utilizar o sistema de checkpoints, ADRs e relatorios automaticos como evidencia de conformidade com processos de governanca de software.

**12.6 DevOps e Platform Engineering**
Equipes de plataforma podem utilizar a integracao com StackSpot e o motor de skills para padronizar a provisao de infraestrutura e pipelines de CI/CD como parte do ciclo de desenvolvimento.

**12.7 Gestao de Projetos de Software**
Gerentes de projeto podem utilizar o sistema de relatorios automaticos e o dashboard de monitoramento para acompanhar o progresso de entregas de software assistidas por IA sem necessidade de interacao direta com o ambiente de desenvolvimento.

---

## ANEXO A: GLOSSARIO DE TERMOS

| Termo | Definicao |
|-------|-----------|
| ADR | Architecture Decision Record — documento que registra decisao arquitetural |
| Checkpoint | Ponto de pausa obrigatoria no pipeline para decisao humana |
| DoD | Definition of Done — criterios de conclusao de uma task |
| DoR | Definition of Ready — criterios para uma story entrar em sprint |
| Frontmatter | Secao YAML no inicio de um arquivo Markdown com metadados |
| Handoff | Transferencia de contexto e artefatos entre agentes |
| Human-in-the-Loop | Padrão onde decisoes de IA requerem validacao humana |
| LLM | Large Language Model — modelo de linguagem de grande porte |
| MAS | Multi-Agent System — sistema com multiplos agentes cooperativos |
| NFR | Non-Functional Requirement — requisito de qualidade |
| Pipeline | Sequencia ordenada de passos de execucao |
| Persona | Identidade e comportamento atribuido a um agente de IA |
| Skill | Modulo de integracao com ferramenta externa |
| Squad | Instancia configurada de equipe de engenharia multi-agente |
| State Machine | Maquina de estados que controla o ciclo de vida da execucao |
| Subagent | Agente executado em segundo plano com contexto independente |
| Tier | Nivel de capacidade do modelo de linguagem (powerful/fast) |
| Veto | Condicao que impede a progressao de output de qualidade insuficiente |

---

**FIM DO DOCUMENTO**

**Data:** 17 de marco de 2026
**Elaborado por:** Equipe ForgeSquad
**Classificacao:** Confidencial — Uso exclusivo para registro de propriedade intelectual
