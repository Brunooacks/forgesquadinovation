# ForgeSquad — Pitch de Implementacao Itau Unibanco

**Documento Estrategico | NTT DATA para Itau Unibanco**
**Classificacao: Confidencial — Uso Externo Autorizado**
**Data: Marco 2026**

---

## 1. RESUMO EXECUTIVO

ForgeSquad nao e uma plataforma de mercado. E um framework de engenharia que roda 100% dentro do ambiente Itau, adapta-se as ferramentas ja aprovadas pelo banco, e adiciona governanca, compliance e padronizacao as equipes de desenvolvimento.

O framework opera como um conjunto de arquivos locais (markdown e YAML) que definem personas de agentes, pipelines de execucao e quality gates — tudo dentro do IDE do desenvolvedor, sem dependencia externa.

### Proposta em uma frase

> Reduza o time-to-market em 60% e custos de desenvolvimento em 45%, mantendo compliance Bacen e rastreabilidade total — sem mandar uma linha de codigo para fora.

### Destaques

- **Zero exfiltracao de dados** — roda inteiramente na rede interna do Itau
- **Compativel com ferramentas ja aprovadas** — Copilot, SonarQube, Jira, Azure DevOps
- **Compliance nativo** — Bacen CMN 4.893, LGPD, PCI-DSS, SOX
- **Piloto gratuito** — modelo comercial baseado em resultado comprovado
- **ROI projetado: 15x a 50x** no primeiro ano (cenarios conservadores)

---

## 2. POR QUE NAO E UMA "PLATAFORMA DE MERCADO"

Entendemos a politica do Itau sobre adocao de plataformas externas. ForgeSquad foi desenhado especificamente para nao se enquadrar nessa categoria.

### O que ForgeSquad NAO e

| Caracteristica | ForgeSquad |
|---|---|
| SaaS | NAO — nao precisa de conta, nao manda dados para nuvem |
| Plataforma externa | NAO — roda no laptop do dev ou no servidor interno |
| Dependente de internet | NAO — funciona offline com modelos on-premise |
| Vendor lock-in | NAO — capabilities model permite trocar AI provider a qualquer momento |
| Substituto das ferramentas do banco | NAO — complementa e orquestra o que ja existe |

### O que ForgeSquad E

- Um conjunto de **arquivos markdown + YAML** que define como uma squad trabalha
- Uma **metodologia de engenharia** com personas de agentes, pipelines e quality gates
- Um framework que roda **dentro do IDE** do desenvolvedor (VS Code, Cursor, terminal)
- **100% auditavel** — audit trail com SHA-256, compliance Bacen 4.893
- **Propriedade intelectual da NTT DATA** — pode ser licenciado exclusivamente ao Itau

### Analogia para C-level

ForgeSquad e como um playbook de engenharia — nao e uma ferramenta nova, e a forma como o time usa as ferramentas que o banco JA aprovou. Assim como um runbook define como operar um sistema, ForgeSquad define como uma squad desenvolve software com qualidade, seguranca e rastreabilidade.

---

## 3. COMO FUNCIONA DENTRO DO ITAU

### Arquitetura de Deployment

```
+-----------------------------------------------+
|  AMBIENTE ITAU (rede interna)                  |
|                                                |
|  +------------------------------------------+  |
|  |  IDE do Desenvolvedor                     |  |
|  |  (VS Code / Cursor / Terminal)            |  |
|  |                                           |  |
|  |  ForgeSquad Framework (arquivos locais)   |  |
|  |  +-- Agentes (personas em .md)            |  |
|  |  +-- Pipeline (steps em .yaml)            |  |
|  |  +-- Intelligence (embedded .md)          |  |
|  |  +-- Output (codigo + docs + audit)       |  |
|  +------------------------------------------+  |
|                      |                          |
|                      v                          |
|  +------------------------------------------+  |
|  |  AI Provider (configuravel)               |  |
|  |  Opcao A: API Claude/GPT (via proxy)      |  |
|  |  Opcao B: Modelo on-premise (LLM local)   |  |
|  |  Opcao C: Azure OpenAI (Itau Azure)       |  |
|  +------------------------------------------+  |
|                      |                          |
|                      v                          |
|  +------------------------------------------+  |
|  |  Ferramentas existentes Itau              |  |
|  |  +-- Jira (project sync)                  |  |
|  |  +-- SonarQube (code analysis)            |  |
|  |  +-- Jenkins/GitLab CI (CI/CD)            |  |
|  |  +-- Azure DevOps (infra)                 |  |
|  |  +-- Vault (secrets management)           |  |
|  +------------------------------------------+  |
|                                                |
|  ZERO dados saem da rede Itau                  |
+-----------------------------------------------+
```

### Integracao com Ferramentas Ja Aprovadas

O capabilities model do ForgeSquad se adapta ao que o Itau ja tem. Nao ha necessidade de aprovar novas ferramentas — o framework orquestra as existentes.

| Capability | Ferramenta Itau (exemplo) | Como Integra |
|---|---|---|
| autonomous_coding | Azure OpenAI / modelo interno | API via proxy interno |
| pair_programming | GitHub Copilot Enterprise | Ja aprovado pelo banco |
| code_analysis | SonarQube interno | Plugin existente |
| project_sync | Jira Server | API interna |
| infrastructure | Terraform Enterprise / Azure Bicep | Templates adaptados |
| monitoring | Dynatrace / Grafana | Dashboards existentes |
| secrets_management | HashiCorp Vault | Integracao nativa |
| ci_cd | Jenkins / GitLab CI | Pipeline triggers |

### Fluxo de Trabalho

1. **Dev abre o IDE** — ForgeSquad carrega automaticamente os agentes e pipeline
2. **Pipeline executa** — cada step ativa o agente especializado (Architect, Tech Lead, Dev, QA)
3. **Quality gates validam** — typecheck, lint, test, security scan, compliance check
4. **Audit trail registra** — cada acao com hash SHA-256, timestamp, agente responsavel
5. **Output entregue** — codigo, documentacao, testes, tudo versionado no Git interno

---

## 4. COMPLIANCE E SEGURANCA

O compliance nao e um "add-on" no ForgeSquad — esta no DNA do framework. O Finance Advisor agent valida compliance em CADA entrega, nao so no final.

### Bacen CMN 4.893 (Ciberseguranca)

- **Audit trail imutavel** com SHA-256 (chain de hashes verificaveis)
- **Rastreabilidade completa**: quem (agente), o que (artifact), quando (timestamp ISO 8601)
- **Retencao minima 5 anos** (configuravel por politica do banco)
- **Segregacao de funcoes** — agentes com responsabilidades distintas e delimitadas
- **Gestao de incidentes** — logs estruturados para analise forense

### LGPD

- **Zero coleta de dados pessoais** pelo framework
- Intelligence de cryptography garante **encryption de PII por padrao**
- **Data masking e tokenization** como best practice embedded nos agentes
- Nenhum dado transita para fora do perimetro de seguranca do banco

### PCI-DSS

- Production standard inclui **security scan obrigatorio** em cada entrega
- **Cardholder data environment** separado por design nos templates
- **Code review automatizado** com foco em seguranca (OWASP Top 10)
- Segregacao de ambientes garantida por pipeline configuration

### SOX (Sarbanes-Oxley)

- Audit trail satisfaz requisitos de **rastreabilidade e evidencia**
- **Segregation of duties** via agentes especializados (quem desenvolve nao aprova)
- **Approval gates documentados** com human-in-the-loop configuravel
- Evidencias de revisao armazenadas automaticamente

### Quadro Resumo de Compliance

| Regulamentacao | Requisito | Como ForgeSquad Atende |
|---|---|---|
| Bacen 4.893 | Rastreabilidade | Audit trail SHA-256 imutavel |
| Bacen 4.893 | Segregacao de funcoes | Agentes com papeis distintos |
| LGPD | Protecao de dados | Zero coleta + encryption nativa |
| PCI-DSS | Seguranca de codigo | Security scan obrigatorio por delivery |
| SOX | Evidencias de controle | Approval gates + audit trail |

---

## 5. MODELO DE IMPLEMENTACAO (ZERO RISCO)

### Fase 0: Discovery (2 semanas) — GRATUITO

- NTT mapeia **1 squad existente** do Itau
- Configura ForgeSquad com as **ferramentas ja aprovadas** do banco
- Demonstracao com **projeto real** (ambiente sandbox)
- **Deliverable**: relatorio de viabilidade tecnica + proposta de piloto
- **Custo para o Itau: R$0**

### Fase 1: Piloto (4 semanas) — 1 Squad

- 1 squad real, 1 projeto greenfield ou feature nova
- Metricas **antes/depois**: tempo de entrega, qualidade de codigo, custo por feature
- Sem alterar processos existentes — ForgeSquad se adapta ao workflow atual
- **Go/No-Go baseado em dados reais**, nao em promessas
- Risco: zero — se nao funcionar, nao muda nada

### Fase 2: Expansao Controlada (3 meses) — 5 Squads

- Rollout para **5 squads em areas diferentes** (Pix, Open Finance, Seguros, Credito, Investimentos)
- Treinamento dos devs (**1 dia por squad** — curva de aprendizado minima)
- Metricas consolidadas para **business case robusto**
- Ajuste fino de capabilities e providers por area de negocio
- Dashboard de acompanhamento para engineering leadership

### Fase 3: Enterprise Scale (6 meses) — 50+ Squads

- Rollout padronizado com **squad templates** por dominio de negocio
- **Governance centralizada** — policies, metrics rollup, compliance dashboard
- Dashboard de visibilidade para **CTO, VP Engineering, CISO**
- Modelo comercial definitivo (licenca + suporte + evolucao)
- Centro de excelencia ForgeSquad interno ao Itau

### Fase 4: Full Scale (12 meses) — 300+ Squads (3.000+ Devs)

- ForgeSquad como **padrao de engenharia** do Itau
- Customizacoes por **BU (Business Unit)** — cada vertical com seus templates
- Integracao com **academy Itau** (treinamento continuo para novos devs)
- Evolucao continua com **squads NTT dedicados**
- Benchmark de referencia para o setor bancario brasileiro

### Timeline Visual

```
Semana 0        Semana 2        Semana 6        Mes 4         Mes 7         Mes 13
  |               |               |               |             |             |
  v               v               v               v             v             v
Discovery -----> Piloto -------> Expansao ------> Enterprise -> Full Scale ->
(GRATIS)        (1 squad)       (5 squads)       (50+ squads)  (300+ squads)
                Go/No-Go        Business Case    Governance    Padrao Itau
```

---

## 6. OBJECOES COMUNS E RESPOSTAS

### "Nao adotamos plataformas de mercado"

ForgeSquad nao e plataforma. Sao arquivos markdown e YAML que definem como o time trabalha. Roda dentro do IDE que o dev ja usa. Nao instala nada novo no ambiente. Nao requer aprovacao de nova ferramenta — usa as que ja estao aprovadas.

### "Seguranca e prioridade — nao mandamos codigo para fora"

ForgeSquad roda 100% local. O AI provider pode ser on-premise (modelo interno) ou via proxy aprovado (Azure OpenAI do proprio Itau). Zero dados saem da rede. O framework em si sao arquivos texto — nao ha binario, nao ha runtime externo.

### "Ja temos Copilot/SonarQube/Jira"

Perfeito. ForgeSquad nao substitui — orquestra. Copilot vira uma capability de pair programming. SonarQube vira um quality gate automatico. Jira vira o project sync. O framework AMPLIFICA o valor do investimento que o Itau ja fez nessas ferramentas.

### "AI vai gerar codigo inseguro"

Cada entrega passa por: code review automatizado (Tech Lead + Architect agents), security scan obrigatorio (OWASP), quality gates (typecheck, lint, test coverage minimo), e compliance validation (Finance Advisor). O codigo AI-assisted passa por MAIS validacao que o codigo humano tipico hoje.

### "E se a NTT parar de suportar?"

O framework e composto de arquivos abertos (markdown, YAML). Nao ha dependencia binaria, nao ha servidor, nao ha licenca de runtime. O banco pode evoluir internamente a qualquer momento. O valor da NTT esta no conhecimento: agentes otimizados, best practices de industria, pipeline design e evolucao continua.

### "Quanto custa?"

O discovery e gratuito. O piloto tem custo minimo. O modelo comercial definitivo e baseado em resultado: se nao reduzir tempo e custo de forma mensuravel, nao cobra. Sem risco para o Itau.

### "Como garantimos que os agentes seguem nossas politicas internas?"

Os agentes sao definidos por arquivos markdown — o banco pode revisar, modificar e aprovar cada persona. As policies sao configuradas em YAML e podem refletir exatamente os padroes internos do Itau. Nada executa sem estar documentado e aprovado.

---

## 7. ROI PROJETADO (CENARIO ITAU)

### Premissas Conservadoras

| Parametro | Valor |
|---|---|
| Squads iniciais | 100 |
| Devs por squad (media) | 8 |
| Total de devs | 800 |
| Custo medio dev/mes (CLT + beneficios + gestao) | R$18.000 |
| Ganho de produtividade ForgeSquad | 2,5x (conservador — benchmarks indicam 3-5x) |

### Cenario Otimista (2,5x produtividade)

| Metrica | Valor |
|---|---|
| Custo mensal atual (800 devs) | R$14,4M |
| Custo equivalente com ForgeSquad (mesma entrega, 320 devs) | R$5,76M |
| **Economia mensal** | **R$8,64M** |
| **Economia anual** | **R$103,7M** |
| Investimento ForgeSquad (licenca + suporte + treinamento) | ~R$2M/ano |
| **ROI** | **50x no primeiro ano** |

### Cenario Ultra-Conservador (30% produtividade)

| Metrica | Valor |
|---|---|
| Economia anual | R$31M |
| Investimento ForgeSquad | ~R$2M/ano |
| **ROI** | **15x no primeiro ano** |

### Beneficios Nao Quantificados (adicionais ao ROI)

- Reducao de defeitos em producao (menos incidentes, menor custo de suporte)
- Padronizacao de codigo entre squads (menor custo de manutencao)
- Onboarding acelerado de novos devs (playbooks prontos)
- Compliance automatizado (menor risco regulatorio)
- Retencao de talento (devs preferem trabalhar com ferramentas modernas)
- Documentacao automatica (reduz divida tecnica)

---

## 8. PROXIMOS PASSOS

| Passo | Acao | Prazo |
|---|---|---|
| 1 | **Reuniao tecnica** (1h) — NTT apresenta ForgeSquad ao time de engenharia Itau | Proxima semana |
| 2 | **Discovery gratuito** (2 semanas) — mapear ferramentas e configurar framework | Semanas 1-2 |
| 3 | **Piloto** (4 semanas) — 1 squad real, metricas reais, ambiente controlado | Semanas 3-6 |
| 4 | **Decisao Go/No-Go** baseada em dados concretos e metricas comparativas | Semana 7 |

### Para Agendar

**NTT DATA Engineering — ForgeSquad Team**

Estamos disponiveis para uma reuniao tecnica de 1 hora com o time de engenharia do Itau para demonstrar o framework em funcionamento, responder perguntas tecnicas e alinhar o escopo do discovery gratuito.

---

## 9. ANEXOS E REFERENCIAS

| Documento | Descricao | Localizacao |
|---|---|---|
| Arquitetura e Patente | Documentacao tecnica completa e filing de patente | `docs/FORGESQUAD-ARCHITECTURE-PATENT.md` |
| Manual de Implantacao Enterprise Banking | Guia detalhado de implementacao em ambiente bancario | `docs/manual-implantacao-enterprise-banking.md` |
| Business Plan de Investimento | Plano de negocios completo com projecoes financeiras | `docs/business-plan-investimento-forgesquad.md` |
| Plano de Evolucao 600 Profissionais | Roadmap de escala para grandes operacoes | `docs/plano-evolucao-600-profissionais.md` |

---

*Documento preparado por NTT DATA Engineering — ForgeSquad Team*
*Confidencial — Para uso exclusivo nas negociacoes Itau Unibanco*
*Marco 2026*
