# Manual de Implantação — ForgeSquad Enterprise Banking Edition

**Versão:** 1.0.0
**Data:** 20 de março de 2026
**Classificação:** Confidencial — Uso Interno
**Público-alvo:** CTOs, Diretores de Engenharia, Arquitetos de Soluções, Equipes de DevOps e Segurança
**Revisão:** Documento sujeito a revisão trimestral conforme ciclo de compliance regulatório

---

## Índice — Parte 1 (Seções 1 a 8)

1. [Visão Geral](#1-visão-geral)
2. [Pré-requisitos](#2-pré-requisitos)
3. [Arquitetura para Ambiente Bancário](#3-arquitetura-para-ambiente-bancário)
4. [Compliance e Regulamentação](#4-compliance-e-regulamentação)
5. [Instalação Step-by-Step](#5-instalação-step-by-step)
6. [Integrações Enterprise](#6-integrações-enterprise)
7. [Configuração de Compliance](#7-configuração-de-compliance)
8. [Casos de Uso Bancários](#8-casos-de-uso-bancários)

---

## 1. Visão Geral

### 1.1 O que é o ForgeSquad

O **ForgeSquad** é um framework de orquestração multi-agente projetado para automatizar e coordenar o ciclo de vida completo de engenharia de software — desde a elicitação de requisitos até a publicação em produção e sustentação. O sistema utiliza **9 agentes de inteligência artificial especializados**, cada um com persona, princípios operacionais e anti-padrões definidos em formato declarativo (YAML frontmatter + Markdown), orquestrados por um motor de pipeline determinístico.

### 1.2 Por que ForgeSquad para o Setor Bancário

O setor bancário opera sob as exigências regulatórias mais rigorosas do mercado. Cada decisão de engenharia carrega implicações de compliance, risco operacional e segurança da informação. O ForgeSquad foi projetado para atender essas exigências com:

- **Pipeline Determinístico com 10 fases e 24 passos sequenciais:** Cada etapa do ciclo de vida é rastreável, auditável e reproduzível — requisito fundamental para instituições reguladas pelo Banco Central do Brasil.
- **9 Checkpoints com Human Approval Gates:** Decisões críticas — como aprovação de arquitetura, autorização de deploy em produção e validação de requisitos de segurança — exigem aprovação humana obrigatória, garantindo governança e responsabilidade (accountability).
- **Audit Trail com SHA-256:** Cada ação executada pelo framework gera um registro imutável com hash criptográfico, atendendo aos requisitos de auditoria do Bacen, SOX e PCI DSS.
- **Omnipresença do Agente Arquiteto:** O agente Architect participa de todas as fases do ciclo de vida, garantindo integridade estrutural e aderência às decisões arquiteturais aprovadas — essencial para ambientes de core banking.

### 1.3 Agentes Disponíveis

| # | Agente | Responsabilidade no Contexto Bancário |
|---|--------|---------------------------------------|
| 1 | **Architect** | Desenho de soluções, decisões arquiteturais, governança de tech stack, quality gates |
| 2 | **Tech Lead** | Coordenação técnica, padrões de código, planejamento de sprints, revisão de PRs |
| 3 | **Business Analyst** | Engenharia de requisitos, user stories, critérios de aceite, engenharia reversa |
| 4 | **Developer (Backend)** | Implementação backend, APIs, bancos de dados, integrações com core banking |
| 5 | **Developer (Frontend)** | Implementação frontend, UI/UX, design responsivo, portais de internet banking |
| 6 | **QA Engineer** | Estratégia de testes, automação, regressão, testes de performance e segurança |
| 7 | **Tech Writer** | Documentação técnica, API docs, runbooks, ADRs, manuais regulatórios |
| 8 | **Project Manager** | Relatórios de status, acompanhamento de progresso, gestão de riscos |
| 9 | **Finance Advisor** | Análise financeira, TCO, ROI, compliance financeiro, modelos de custo |

### 1.4 Público-alvo deste Manual

Este manual é destinado a:

- **CTOs e Diretores de Tecnologia** que avaliam a adoção do ForgeSquad em suas organizações bancárias
- **Arquitetos de Soluções** responsáveis pelo desenho da implantação em infraestrutura bancária
- **Engenheiros de Plataforma** que executarão a instalação e configuração
- **Equipes de Segurança da Informação** que validarão os controles de segurança
- **Equipes de Compliance** que verificarão a aderência regulatória
- **Gerentes de Operações** que acompanharão o monitoramento e operação do framework

---

## 2. Pré-requisitos

### 2.1 Requisitos de Infraestrutura

#### 2.1.1 Servidores de Aplicação (mínimo por nó)

| Recurso | Mínimo | Recomendado | Produção HA |
|---------|--------|-------------|-------------|
| CPU | 8 cores (x86_64) | 16 cores | 32 cores |
| RAM | 32 GB DDR4 | 64 GB DDR4 ECC | 128 GB DDR4 ECC |
| Armazenamento | 500 GB SSD NVMe | 1 TB SSD NVMe | 2 TB SSD NVMe (RAID 10) |
| IOPS | 10.000 | 30.000 | 50.000+ |
| Rede | 1 Gbps | 10 Gbps | 25 Gbps (redundante) |

#### 2.1.2 Sistema Operacional

| SO | Versão | Suporte |
|----|--------|---------|
| Red Hat Enterprise Linux | 8.8+ / 9.x | Totalmente suportado (recomendado para bancos) |
| Ubuntu Server | 22.04 LTS / 24.04 LTS | Totalmente suportado |
| Oracle Linux | 8.x / 9.x | Suportado |
| SUSE Linux Enterprise | 15 SP5+ | Suportado com limitações |

> **Nota:** Ambientes Windows Server não são suportados para os componentes de backend do ForgeSquad. Clientes Windows podem acessar a interface web e as APIs REST normalmente.

#### 2.1.3 Software Base

| Componente | Versão Mínima | Observação |
|------------|--------------|------------|
| Kubernetes | 1.28+ | EKS, AKS, OpenShift 4.14+ ou on-premises |
| Docker / containerd | 24.0+ / 1.7+ | Runtime de containers |
| Helm | 3.14+ | Gerenciador de pacotes Kubernetes |
| PostgreSQL | 15+ | Banco de dados principal (suporte a Patroni para HA) |
| Redis | 7.2+ | Cache e filas de mensagens internas |
| Apache Kafka | 3.6+ | Event streaming para pipeline e audit trail |
| HashiCorp Vault | 1.15+ | Gestão de segredos (alternativa: CyberArk Conjur) |
| Cert-Manager | 1.13+ | Gestão automatizada de certificados TLS |

### 2.2 Requisitos de Rede

#### 2.2.1 Conectividade

- **Acesso à DMZ:** O ForgeSquad API Gateway deve residir na DMZ com acesso controlado à zona de aplicação interna.
- **DNS Interno:** Entradas DNS para todos os microserviços do ForgeSquad (mínimo 12 registros A/CNAME).
- **Load Balancer:** L4/L7 com suporte a TLS termination (F5 BIG-IP, HAProxy, NGINX Plus, AWS ALB/NLB).
- **Proxy Corporativo:** Configuração de proxy para acesso a registries de containers externos (se aplicável).
- **NTP:** Sincronização de tempo obrigatória com fonte confiável (Stratum 1 ou 2). Desvio máximo tolerado: 50ms.

#### 2.2.2 Portas e Protocolos

| Porta | Protocolo | Serviço | Direção |
|-------|-----------|---------|---------|
| 443 | HTTPS/TLS 1.3 | API Gateway | Inbound (DMZ → App Zone) |
| 6443 | HTTPS | Kubernetes API Server | Internal |
| 5432 | TCP/TLS | PostgreSQL | Internal |
| 6379 | TCP/TLS | Redis | Internal |
| 9092-9094 | TCP/TLS | Kafka Brokers | Internal |
| 8200 | HTTPS | HashiCorp Vault | Internal |
| 8443 | HTTPS | ForgeSquad Admin Console | Internal |
| 9090 | HTTP | Prometheus Metrics | Internal |
| 3000 | HTTPS | Grafana Dashboards | Internal |

#### 2.2.3 Configuração de Firewall

```
# Regras mínimas de firewall (exemplo iptables/nftables)
# DMZ → Application Zone
ALLOW TCP 443   FROM dmz_subnet   TO app_subnet    # API Gateway
ALLOW TCP 8443  FROM admin_subnet TO app_subnet    # Admin Console

# Application Zone → Data Zone
ALLOW TCP 5432  FROM app_subnet   TO data_subnet   # PostgreSQL
ALLOW TCP 6379  FROM app_subnet   TO data_subnet   # Redis
ALLOW TCP 9092  FROM app_subnet   TO data_subnet   # Kafka

# Application Zone → Core Banking Zone
ALLOW TCP 1414  FROM app_subnet   TO core_subnet   # IBM MQ
ALLOW TCP 8080  FROM app_subnet   TO core_subnet   # Core Banking API

# DENY ALL não listado acima
DENY ALL FROM any TO any
```

### 2.3 Requisitos de Segurança

- **Certificados PKI:** Certificados X.509 emitidos por CA interna da instituição (RSA 4096-bit ou ECDSA P-384).
- **HSM (Hardware Security Module):** Integração com HSM para armazenamento de chaves mestras (Thales Luna, nCipher nShield, AWS CloudHSM).
- **mTLS (Mutual TLS):** Capacidade de TLS mútuo entre todos os componentes do ForgeSquad. Todas as comunicações internas devem utilizar mTLS com certificados de serviço rotacionados a cada 90 dias.
- **RBAC:** Modelo de controle de acesso baseado em roles integrado ao Active Directory da instituição.
- **Criptografia em Repouso:** AES-256-GCM para todos os dados persistidos (PostgreSQL TDE, volume encryption).
- **Criptografia em Trânsito:** TLS 1.3 obrigatório para todas as comunicações. TLS 1.2 aceito apenas para integração com sistemas legados do core banking, com cipher suites restritas.

### 2.4 Equipe Necessária

| Papel | Quantidade | Responsabilidade na Implantação |
|-------|-----------|-------------------------------|
| Engenheiro de Plataforma / SRE | 2 | Provisionamento de infraestrutura, Kubernetes, Helm |
| Engenheiro de Segurança | 1 | Certificados, Vault, mTLS, revisão de segurança |
| DBA | 1 | PostgreSQL HA, backups, tunning, Kafka clusters |
| Engenheiro de Rede | 1 | VLANs, firewall, DNS, load balancer, proxy |
| Arquiteto de Soluções | 1 | Desenho da implantação, integrações, validação |
| Gerente de Projeto | 1 | Coordenação, timeline, stakeholders |

### 2.5 Checklist de Pré-requisitos

| # | Item | Status | Responsável | Prazo |
|---|------|--------|-------------|-------|
| 1 | Servidores provisionados (mín. 3 nós worker) | ☐ | Plataforma | Semana 1 |
| 2 | Kubernetes cluster operacional | ☐ | Plataforma | Semana 1 |
| 3 | VLANs e subnets configuradas (5 zonas) | ☐ | Rede | Semana 1 |
| 4 | Regras de firewall aplicadas | ☐ | Rede/Segurança | Semana 1 |
| 5 | DNS entries criadas | ☐ | Rede | Semana 1 |
| 6 | Load balancer configurado | ☐ | Rede | Semana 1 |
| 7 | Certificados PKI emitidos pela CA interna | ☐ | Segurança | Semana 2 |
| 8 | HSM provisionado e acessível | ☐ | Segurança | Semana 2 |
| 9 | HashiCorp Vault instalado e unsealed | ☐ | Plataforma | Semana 2 |
| 10 | PostgreSQL HA cluster operacional | ☐ | DBA | Semana 2 |
| 11 | Redis Sentinel cluster operacional | ☐ | DBA | Semana 2 |
| 12 | Kafka cluster operacional (mín. 3 brokers) | ☐ | DBA | Semana 2 |
| 13 | Active Directory: service accounts criadas | ☐ | Segurança | Semana 2 |
| 14 | Proxy corporativo configurado para registries | ☐ | Rede | Semana 1 |
| 15 | NTP sincronizado em todos os nós | ☐ | Plataforma | Semana 1 |
| 16 | Aprovação do Change Advisory Board (CAB) | ☐ | Gerente de Projeto | Semana 0 |

---

## 3. Arquitetura para Ambiente Bancário

### 3.1 Modelo de Zonas de Rede

A arquitetura do ForgeSquad em ambiente bancário segue o modelo de defesa em profundidade (defense-in-depth) com **5 zonas de rede segregadas**, cada uma com nível de segurança e controle de acesso distintos.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                     ZONA 1 — INTERNET                               │    │
│  │                                                                     │    │
│  │   Usuários Externos ──► CDN ──► WAF ──► DDoS Protection            │    │
│  │                                                                     │    │
│  └───────────────────────────┬─────────────────────────────────────────┘    │
│                              │ HTTPS 443 (TLS 1.3)                         │
│                              ▼                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                     ZONA 2 — DMZ                                    │    │
│  │                                                                     │    │
│  │   ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐     │    │
│  │   │ API Gateway  │  │  Reverse     │  │  ForgeSquad          │     │    │
│  │   │ (Kong/APIM)  │  │  Proxy       │  │  Web Dashboard       │     │    │
│  │   │              │  │  (NGINX+)    │  │  (Read-Only View)    │     │    │
│  │   └──────┬───────┘  └──────┬───────┘  └──────────┬───────────┘     │    │
│  │          │                 │                      │                 │    │
│  └──────────┼─────────────────┼──────────────────────┼─────────────────┘    │
│             │ mTLS            │ mTLS                 │ mTLS                 │
│             ▼                 ▼                      ▼                      │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                  ZONA 3 — APPLICATION ZONE                          │    │
│  │                                                                     │    │
│  │   ┌────────────────────────────────────────────────────────────┐    │    │
│  │   │              ForgeSquad Core Engine                         │    │    │
│  │   │                                                            │    │    │
│  │   │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────────┐ │    │    │
│  │   │  │Architect │ │Tech Lead │ │   BA     │ │Dev Backend   │ │    │    │
│  │   │  │  Agent   │ │  Agent   │ │  Agent   │ │   Agent      │ │    │    │
│  │   │  └──────────┘ └──────────┘ └──────────┘ └──────────────┘ │    │    │
│  │   │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────────┐ │    │    │
│  │   │  │   Dev    │ │   QA     │ │  Tech    │ │     PM       │ │    │    │
│  │   │  │Frontend  │ │Engineer  │ │  Writer  │ │   Agent      │ │    │    │
│  │   │  └──────────┘ └──────────┘ └──────────┘ └──────────────┘ │    │    │
│  │   │  ┌──────────────┐ ┌────────────────┐ ┌────────────────┐  │    │    │
│  │   │  │Finance       │ │ Pipeline       │ │ Approval       │  │    │    │
│  │   │  │Advisor Agent │ │ Runner Engine  │ │ Gate Manager   │  │    │    │
│  │   │  └──────────────┘ └────────────────┘ └────────────────┘  │    │    │
│  │   └────────────────────────────────────────────────────────────┘    │    │
│  │                                                                     │    │
│  │   ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐     │    │
│  │   │ Admin        │  │ Audit Trail  │  │ Skill Integration    │     │    │
│  │   │ Console      │  │ Service      │  │ Engine (Devin,       │     │    │
│  │   │ (8443)       │  │ (SHA-256)    │  │ Copilot, StackSpot)  │     │    │
│  │   └──────────────┘  └──────┬───────┘  └──────────────────────┘     │    │
│  │                            │                                        │    │
│  └────────────────────────────┼────────────────────────────────────────┘    │
│                               │ mTLS                                        │
│                               ▼                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                  ZONA 4 — CORE BANKING ZONE                         │    │
│  │                                                                     │    │
│  │   ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐     │    │
│  │   │ Core Banking │  │ IBM MQ /     │  │ ESB / Integration    │     │    │
│  │   │ System       │  │ Kafka Bridge │  │ Layer                │     │    │
│  │   │ (Temenos,    │  │              │  │                      │     │    │
│  │   │  Finastra,   │  │              │  │                      │     │    │
│  │   │  Topaz)      │  │              │  │                      │     │    │
│  │   └──────────────┘  └──────────────┘  └──────────────────────┘     │    │
│  │                                                                     │    │
│  │   ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐     │    │
│  │   │ PIX / SPI    │  │ Open Finance │  │ Anti-Fraud           │     │    │
│  │   │ Gateway      │  │ APIs         │  │ Engine               │     │    │
│  │   └──────────────┘  └──────────────┘  └──────────────────────┘     │    │
│  │                                                                     │    │
│  └───────────────────────────┬─────────────────────────────────────────┘    │
│                              │ mTLS + Encrypted                             │
│                              ▼                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                     ZONA 5 — DATA ZONE                              │    │
│  │                                                                     │    │
│  │   ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐     │    │
│  │   │ PostgreSQL   │  │ Redis        │  │ Apache Kafka         │     │    │
│  │   │ HA Cluster   │  │ Sentinel     │  │ Cluster              │     │    │
│  │   │ (Patroni)    │  │ Cluster      │  │ (3+ brokers)         │     │    │
│  │   └──────────────┘  └──────────────┘  └──────────────────────┘     │    │
│  │                                                                     │    │
│  │   ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐     │    │
│  │   │ Backup       │  │ Audit Log    │  │ HSM                  │     │    │
│  │   │ Storage      │  │ Archive      │  │ (Chaves Mestras)     │     │    │
│  │   │ (Encrypted)  │  │ (Append-Only)│  │                      │     │    │
│  │   └──────────────┘  └──────────────┘  └──────────────────────┘     │    │
│  │                                                                     │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 3.2 Posicionamento de Componentes por Zona

#### Zona 1 — Internet
- CDN para assets estáticos do dashboard (CloudFront, Akamai)
- WAF (Web Application Firewall) com regras OWASP Top 10
- Proteção DDoS (AWS Shield, Cloudflare, F5 Silverline)

#### Zona 2 — DMZ
- **API Gateway (Kong Enterprise / Azure API Management):** Ponto de entrada para todas as requisições externas. Rate limiting, autenticação OAuth 2.0, throttling.
- **Reverse Proxy (NGINX Plus):** Terminação TLS, roteamento de requisições para a zona de aplicação.
- **ForgeSquad Web Dashboard (Read-Only):** Visão de status do pipeline para stakeholders com acesso externo. Sem capacidade de execução de ações.

#### Zona 3 — Application Zone
- **ForgeSquad Core Engine:** Todos os 9 agentes de IA, Pipeline Runner Engine, Approval Gate Manager.
- **Admin Console:** Interface administrativa completa (porta 8443). Acesso restrito à rede interna.
- **Audit Trail Service:** Serviço de registro de auditoria com hash SHA-256. Cada entrada é encadeada com a anterior, formando uma cadeia de integridade verificável.
- **Skill Integration Engine:** Motor de integração plugável com ferramentas externas (Devin, GitHub Copilot, StackSpot, Kiro, Jira, SonarQube).

#### Zona 4 — Core Banking Zone
- **Core Banking System:** Integração com sistemas centrais (Temenos T24, Finastra, Topaz/Stefanini).
- **IBM MQ / Kafka Bridge:** Middleware de mensageria para comunicação assíncrona com o core banking.
- **ESB / Integration Layer:** Barramento de integração para orquestração de serviços legados.
- **PIX / SPI Gateway:** Integração com o Sistema de Pagamentos Instantâneos do Banco Central.
- **Open Finance APIs:** Endpoints de Open Finance Brasil conforme especificação da estrutura de governança.
- **Anti-Fraud Engine:** Motor de detecção de fraudes com integração ao ForgeSquad para automação de regras.

#### Zona 5 — Data Zone
- **PostgreSQL HA Cluster (Patroni):** Banco de dados principal com replicação síncrona e failover automático.
- **Redis Sentinel Cluster:** Cache distribuído e filas de mensagens internas do ForgeSquad.
- **Apache Kafka Cluster:** Event streaming para pipeline de agentes e audit trail.
- **Backup Storage (Encrypted):** Armazenamento de backups com criptografia AES-256-GCM.
- **Audit Log Archive (Append-Only):** Repositório imutável de logs de auditoria com retenção mínima de 5 anos.
- **HSM (Hardware Security Module):** Armazenamento físico de chaves criptográficas mestras.

### 3.3 Arquitetura de Alta Disponibilidade (HA)

O ForgeSquad em ambiente bancário deve operar em modo **active-active** com suporte multi-datacenter:

```
┌─────────────────────┐         ┌─────────────────────┐
│   DATACENTER A      │         │   DATACENTER B      │
│   (Primário)        │◄───────►│   (Secundário)      │
│                     │  Link   │                     │
│  ┌───────────────┐  │ Dedicado│  ┌───────────────┐  │
│  │ K8s Cluster A │  │ 10Gbps │  │ K8s Cluster B │  │
│  │ (3 masters,   │  │ (Dark  │  │ (3 masters,   │  │
│  │  6+ workers)  │  │  Fiber)│  │  6+ workers)  │  │
│  └───────────────┘  │         │  └───────────────┘  │
│                     │         │                     │
│  ┌───────────────┐  │         │  ┌───────────────┐  │
│  │ PostgreSQL    │  │ Repl.  │  │ PostgreSQL    │  │
│  │ Primary       │──┼────────┼──│ Standby       │  │
│  └───────────────┘  │ Sync   │  └───────────────┘  │
│                     │         │                     │
│  ┌───────────────┐  │         │  ┌───────────────┐  │
│  │ Kafka Cluster │  │ Mirror │  │ Kafka Cluster │  │
│  │ (3 brokers)   │──┼────────┼──│ (3 brokers)   │  │
│  └───────────────┘  │ Maker  │  └───────────────┘  │
│                     │         │                     │
│  ┌───────────────┐  │         │  ┌───────────────┐  │
│  │ Redis         │  │ Repl.  │  │ Redis         │  │
│  │ Primary       │──┼────────┼──│ Replica       │  │
│  └───────────────┘  │         │  └───────────────┘  │
│                     │         │                     │
│  ┌───────────────┐  │         │  ┌───────────────┐  │
│  │ Vault HA      │  │ Raft   │  │ Vault HA      │  │
│  │ (3 nodes)     │──┼────────┼──│ (2 nodes)     │  │
│  └───────────────┘  │         │  └───────────────┘  │
└─────────────────────┘         └─────────────────────┘
```

**Especificações de HA:**

| Componente | Estratégia | Failover | Observação |
|-----------|-----------|----------|------------|
| Kubernetes | Multi-master (3+3) | Automático (< 30s) | Pod anti-affinity entre zonas |
| PostgreSQL | Patroni active-standby | Automático (< 10s) | Replicação síncrona entre DCs |
| Redis | Sentinel (3+3) | Automático (< 5s) | Sentinel em ambos os DCs |
| Kafka | MirrorMaker 2 | Manual (< 2min) | Replicação cross-DC assíncrona |
| Vault | Raft consensus (5 nós) | Automático (< 15s) | Quorum distribuído |
| ForgeSquad Agents | Kubernetes HPA | Automático (< 30s) | Scale 2-10 réplicas por agente |

### 3.4 Arquitetura de Disaster Recovery (DR)

| Métrica | SLA | Justificativa |
|---------|-----|--------------|
| **RPO (Recovery Point Objective)** | < 5 minutos | Replicação síncrona de PostgreSQL + Kafka offset tracking |
| **RTO (Recovery Time Objective)** | < 30 minutos | Failover automático de K8s + DNS update + warm standby |
| **Disponibilidade** | 99.95% | Equivalente a ~4.4 horas de downtime/ano |

**Procedimento de DR:**

1. **Detecção:** Monitoramento Dynatrace/Prometheus detecta indisponibilidade do DC primário.
2. **Decisão:** Alerta automático para equipe de operações. Aprovação humana para failover (ou automático após 5 min sem resposta).
3. **Failover DNS:** Atualização de DNS para apontar para DC secundário (TTL: 30 segundos).
4. **Promoção PostgreSQL:** Patroni promove standby para primary automaticamente.
5. **Kafka Switch:** Consumidores redirecionados para cluster Kafka do DC secundário.
6. **Validação:** Smoke tests automatizados verificam integridade do ForgeSquad no DC secundário.
7. **Notificação:** Alerta para stakeholders sobre ativação de DR.

---

## 4. Compliance e Regulamentação

### 4.1 Banco Central do Brasil (Bacen)

#### 4.1.1 Resolução CMN 4.893/2021 — Política de Segurança Cibernética

A Resolução CMN 4.893 estabelece requisitos para a política de segurança cibernética e para a contratação de serviços de processamento e armazenamento de dados e de computação em nuvem por instituições financeiras.

**Mapeamento ForgeSquad → CMN 4.893:**

| Artigo | Requisito | Controle ForgeSquad |
|--------|-----------|-------------------|
| Art. 3º, I | Autenticação, criptografia, prevenção e detecção de intrusão | mTLS entre componentes, TLS 1.3, IDS/IPS na DMZ |
| Art. 3º, II | Mecanismos de rastreabilidade | Audit Trail com SHA-256, log centralizado |
| Art. 3º, III | Controles de acesso e segmentação de rede | 5 zonas de rede, RBAC, mTLS, network policies K8s |
| Art. 3º, IV | Gestão de vulnerabilidades | Pipeline de QA Agent com scan de vulnerabilidades |
| Art. 4º | Plano de ação e resposta a incidentes | Runbooks automatizados, integração ServiceNow |
| Art. 11 | Contratação de serviços em nuvem | Suporte a deployment on-premises e nuvem privada |
| Art. 12 | Comunicação ao Bacen | Relatórios gerados pelo PM Agent em formato regulatório |

#### 4.1.2 Circular BCB 3.909/2018 — Risco Cibernético

A Circular 3.909 complementa a Resolução CMN 4.893 com requisitos específicos sobre gerenciamento de risco cibernético.

**Controles ForgeSquad:**

- **Identificação de Ativos:** O Architect Agent mantém catálogo atualizado de todos os componentes e suas dependências (CMDB sync via ServiceNow).
- **Avaliação de Risco:** O Finance Advisor Agent realiza análise de risco operacional para cada decisão arquitetural.
- **Monitoramento Contínuo:** Métricas de segurança exportadas para Splunk/ELK em tempo real.
- **Resposta a Incidentes:** Integração com playbooks de resposta automatizada via ServiceNow Security Operations.
- **Testes de Segurança:** QA Engineer Agent executa testes de segurança (SAST, DAST, SCA) em cada pipeline.

### 4.2 BIAN v12 — Banking Industry Architecture Network

O BIAN (Banking Industry Architecture Network) define uma arquitetura de referência para serviços bancários. O ForgeSquad mapeia seus agentes para os service domains do BIAN:

| Service Domain BIAN | Agente ForgeSquad | Integração |
|---------------------|-------------------|------------|
| SD-Operations Administration | Project Manager | Status reports, progress tracking |
| SD-System Development | Architect + Dev Backend + Dev Frontend | Ciclo de vida de desenvolvimento |
| SD-IT Standards | Tech Lead | Padrões de código, governança tech stack |
| SD-Software Maintenance | QA Engineer | Testes, regressão, manutenção |
| SD-Document Management | Tech Writer | Documentação técnica, ADRs |
| SD-Business Analysis | Business Analyst | Requisitos, user stories |
| SD-Compliance Reporting | Finance Advisor | Compliance financeiro, relatórios |
| SD-Information Security | Architect (Security Gates) | Quality gates de segurança |
| SD-Risk Management | Finance Advisor + Architect | Gestão de risco operacional |

O ForgeSquad implementa a camada de **Service Domain Orchestration** do BIAN, permitindo que squads de agentes operem alinhados à arquitetura de referência bancária.

### 4.3 Basel III / Basel IV — Risco Operacional

O framework de Basileia exige controles robustos de risco operacional para processos de TI em instituições financeiras.

**Mapeamento ForgeSquad → Basel III/IV:**

| Requisito Basel | Controle ForgeSquad |
|-----------------|-------------------|
| Risco Operacional (Pilar I) | Audit Trail imutável, Human Approval Gates para decisões críticas |
| Gestão de Risco de Modelo (SR 11-7) | Versionamento de prompts de agentes, validação de outputs por Architect |
| Controles Internos (Pilar II) | 9 checkpoints obrigatórios no pipeline, segregação de funções (agentes) |
| Divulgação (Pilar III) | Relatórios automatizados do PM Agent, exportação para reguladores |
| Continuidade de Negócios | Arquitetura HA active-active, DR com RPO < 5min |

**Risco de Modelo (Model Risk Management):**

O ForgeSquad trata seus agentes de IA como "modelos" sob a perspectiva regulatória. Cada agente possui:

1. **Documentação de Modelo:** Persona, princípios operacionais, anti-padrões e limitações documentados.
2. **Validação Independente:** O Architect Agent valida outputs de todos os outros agentes (validação cruzada).
3. **Monitoramento de Performance:** Métricas de qualidade de output por agente (accuracy, consistency, hallucination rate).
4. **Versionamento:** Cada alteração em prompt de agente é versionada com Git e SHA-256.
5. **Backtesting:** Comparação periódica de outputs de agentes com benchmarks manuais.

### 4.4 Open Finance Brasil

O ForgeSquad suporta o desenvolvimento e operação de APIs de Open Finance Brasil conforme as especificações da Estrutura Inicial do Open Finance (EIOF).

**Áreas de atuação do ForgeSquad no Open Finance:**

| Fase Open Finance | Agente ForgeSquad | Entrega |
|-------------------|-------------------|---------|
| Especificação de APIs | Business Analyst | Mapeamento de endpoints, schemas, consent flows |
| Implementação de APIs | Dev Backend | Desenvolvimento de APIs REST conforme OpenAPI 3.0 |
| Testes de Certificação | QA Engineer | Testes automatizados conforme suíte de certificação EIOF |
| Documentação | Tech Writer | Documentação de APIs, guias de integração |
| Consent Management | Architect | Design de arquitetura de consentimento FAPI-compliant |
| Monitoramento de SLA | Project Manager | Tracking de SLAs regulatórios (disponibilidade, latência) |

**Requisitos de API Open Finance suportados:**

- FAPI 1.0 Advanced (Financial-grade API Security Profile)
- OAuth 2.0 com PKCE e Pushed Authorization Requests (PAR)
- mTLS para autenticação de certificados de cliente
- Consent lifecycle management (criação, consulta, revogação)
- Webhooks para notificação de eventos
- Rate limiting conforme especificação regulatória

### 4.5 PIX — Sistema de Pagamentos Instantâneos

O ForgeSquad suporta o desenvolvimento de integrações com o ecossistema PIX do Banco Central do Brasil:

**Requisitos SPI (Sistema de Pagamentos Instantâneos):**

| Requisito | Valor | Controle ForgeSquad |
|-----------|-------|-------------------|
| Disponibilidade | 99.999% (< 5.26 min downtime/ano) | Arquitetura HA active-active, DR automatizado |
| Latência máxima (end-to-end) | < 10 segundos | Performance testing pelo QA Agent, APM monitoring |
| Segurança de transações | Criptografia ponta-a-ponta | mTLS + TLS 1.3 + HSM para chaves |
| Antifraude | Monitoramento em tempo real | Integração com Anti-Fraud Engine |
| Reconciliação | Automática, T+0 | Audit Trail + Kafka event sourcing |

**Requisitos PSP (Prestador de Serviço de Pagamento):**

- Homologação no ambiente de testes do Bacen (PILOTO PIX)
- Integração com DICT (Diretório de Identificadores de Contas Transacionais)
- Suporte a Pix Copia e Cola, QR Code Estático e Dinâmico
- Mecanismo Especial de Devolução (MED)
- Relatórios LBTR para o Bacen

### 4.6 PCI DSS v4.0

O ForgeSquad implementa controles alinhados aos 12 requisitos do PCI DSS v4.0 para ambientes que processam dados de cartão:

| # | Requisito PCI DSS v4.0 | Controle ForgeSquad |
|---|------------------------|-------------------|
| 1 | Instalar e manter controles de segurança de rede | 5 zonas de rede segregadas, network policies K8s, mTLS |
| 2 | Aplicar configurações seguras a componentes do sistema | Helm charts com security contexts, Pod Security Standards |
| 3 | Proteger dados armazenados de contas | AES-256-GCM encryption at rest, PostgreSQL TDE |
| 4 | Proteger dados de portador de cartão em trânsito | TLS 1.3 obrigatório, mTLS entre componentes |
| 5 | Proteger contra software malicioso | Container image scanning (Trivy, Snyk), admission controllers |
| 6 | Desenvolver e manter sistemas seguros | Pipeline com SAST/DAST/SCA integrados (QA Agent) |
| 7 | Restringir acesso por necessidade de negócio | RBAC integrado ao AD, least privilege, service accounts |
| 8 | Identificar usuários e autenticar acesso | MFA obrigatório, SSO via SAML 2.0/OIDC, session management |
| 9 | Restringir acesso físico | N/A (responsabilidade do datacenter — complementado por controles lógicos) |
| 10 | Registrar e monitorar todas as atividades | Audit Trail SHA-256, Splunk/ELK, retenção 12+ meses |
| 11 | Testar controles de segurança regularmente | Testes de penetração automatizados, vulnerability scanning |
| 12 | Suportar segurança com políticas organizacionais | Documentação gerada pelo Tech Writer Agent, treinamento |

### 4.7 LGPD — Lei Geral de Proteção de Dados

A Lei 13.709/2018 (LGPD) impõe requisitos específicos para o tratamento de dados pessoais por instituições financeiras.

**Artigos 46-49 — Medidas de Segurança:**

| Artigo | Requisito | Controle ForgeSquad |
|--------|-----------|-------------------|
| Art. 46 | Medidas técnicas e administrativas para proteção de dados pessoais | Criptografia AES-256, mTLS, RBAC, mascaramento de PII |
| Art. 47 | Segurança desde a concepção (privacy by design) | Architect Agent incorpora privacy by design em todas as decisões |
| Art. 48 | Comunicação de incidentes à ANPD | Integração ServiceNow para workflow de notificação de incidentes |
| Art. 49 | Boas práticas e governança | Audit Trail, Human Approval Gates, documentação automatizada |

**Papel do DPO (Data Protection Officer):**

O ForgeSquad suporta o DPO da instituição com:

- **Data Mapping automatizado:** O Business Analyst Agent identifica e cataloga fluxos de dados pessoais em cada projeto.
- **DPIA (Data Protection Impact Assessment):** Template automatizado gerado pelo Tech Writer Agent para novos projetos que envolvam dados pessoais.
- **Registro de Atividades de Tratamento (ROPA):** Documentação automatizada de todas as atividades de tratamento realizadas pelo ForgeSquad.
- **Mascaramento de PII:** Configuração automática de mascaramento de dados pessoais em logs, audit trail e ambientes não-produtivos.

### 4.8 SOX — Sarbanes-Oxley

Para instituições financeiras listadas em bolsa (ou subsidiárias de grupos listados), o ForgeSquad atende aos requisitos de controles internos da SOX:

| Seção SOX | Requisito | Controle ForgeSquad |
|-----------|-----------|-------------------|
| Seção 302 | Certificação de controles internos | Human Approval Gates documentam aprovações de responsáveis |
| Seção 404 | Avaliação de controles internos | Audit Trail imutável com SHA-256, rastreabilidade completa |
| Seção 409 | Divulgação em tempo real | PM Agent gera relatórios em tempo real em cada checkpoint |
| Seção 802 | Preservação de registros | Retenção de 5+ anos, append-only log, backup encrypted |

**Segregação de Funções (SoD):**

O ForgeSquad implementa segregação de funções nativa através da separação de agentes:

- Quem **desenvolve** (Dev Backend/Frontend) não **aprova** (Architect/Tech Lead).
- Quem **testa** (QA Engineer) não **implementa** (Dev Backend/Frontend).
- Quem **aprova deploy** (Human Approval Gate) não é quem **desenvolveu** (Dev Backend/Frontend).
- Cada aprovação em Human Approval Gate registra o usuário aprovador, timestamp e hash da decisão.

### 4.9 Matriz de Compliance Consolidada

| Regulamentação | Agente Principal | Controle Principal | Evidência | Frequência de Auditoria |
|----------------|-----------------|-------------------|-----------|------------------------|
| CMN 4.893 | Architect | mTLS, 5 zonas, Audit Trail | Logs SHA-256 | Anual (Bacen) |
| Circular 3.909 | QA Engineer | SAST/DAST, vulnerability scan | Relatórios de scan | Semestral |
| BIAN v12 | Architect | Service domain mapping | Documentação arquitetural | Anual |
| Basel III/IV | Finance Advisor | Risk assessment, model validation | Risk reports | Trimestral |
| Open Finance | Dev Backend | FAPI 1.0, APIs certificadas | Certificação EIOF | Conforme regulatório |
| PIX/SPI | Dev Backend | HA 99.999%, latência < 10s | APM metrics | Contínuo (Bacen) |
| PCI DSS v4.0 | Architect | 12 requisitos mapeados | ASV scans, pen tests | Anual (QSA) |
| LGPD | Business Analyst | Data mapping, PII masking | ROPA, DPIA | Anual (ANPD) |
| SOX | PM Agent | SoD, Audit Trail, aprovações | Trilha de auditoria | Anual (auditoria externa) |

---

## 5. Instalação Step-by-Step

### 5.1 Preparação do Ambiente

#### 5.1.1 Provisionamento de Infraestrutura

**Opção A — Kubernetes On-Premises (OpenShift / Rancher / Vanilla K8s)**

```bash
# 1. Verificar pré-requisitos dos nós
for node in k8s-master-{1..3} k8s-worker-{1..6}; do
    ssh $node "echo '=== $HOSTNAME ===' && \
    cat /etc/os-release | grep PRETTY_NAME && \
    nproc && free -h | head -2 && \
    df -h / | tail -1 && \
    timedatectl status | grep 'NTP synchronized'"
done

# 2. Criar namespace dedicado para ForgeSquad
kubectl create namespace forgesquad-system
kubectl create namespace forgesquad-data
kubectl create namespace forgesquad-monitoring

# 3. Aplicar labels de zona nos nós
kubectl label node k8s-worker-1 k8s-worker-2 k8s-worker-3 \
    forgesquad.io/zone=application
kubectl label node k8s-worker-4 k8s-worker-5 \
    forgesquad.io/zone=data
kubectl label node k8s-worker-6 \
    forgesquad.io/zone=monitoring

# 4. Aplicar Pod Security Standards
kubectl label namespace forgesquad-system \
    pod-security.kubernetes.io/enforce=restricted \
    pod-security.kubernetes.io/audit=restricted \
    pod-security.kubernetes.io/warn=restricted

# 5. Criar Resource Quotas
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ResourceQuota
metadata:
  name: forgesquad-quota
  namespace: forgesquad-system
spec:
  hard:
    requests.cpu: "32"
    requests.memory: 64Gi
    limits.cpu: "64"
    limits.memory: 128Gi
    pods: "100"
    services: "30"
    persistentvolumeclaims: "20"
EOF
```

**Opção B — Cloud Gerenciado (EKS / AKS)**

```bash
# EKS (AWS)
eksctl create cluster \
    --name forgesquad-banking \
    --region sa-east-1 \
    --version 1.29 \
    --nodegroup-name workers \
    --node-type m6i.4xlarge \
    --nodes 6 \
    --nodes-min 3 \
    --nodes-max 12 \
    --managed \
    --with-oidc \
    --ssh-access \
    --ssh-public-key forgesquad-key \
    --vpc-private-subnets "subnet-app-a,subnet-app-b,subnet-app-c" \
    --vpc-public-subnets "subnet-dmz-a,subnet-dmz-b,subnet-dmz-c"

# AKS (Azure)
az aks create \
    --resource-group rg-forgesquad-banking \
    --name aks-forgesquad-banking \
    --location brazilsouth \
    --kubernetes-version 1.29 \
    --node-count 6 \
    --node-vm-size Standard_D16s_v5 \
    --enable-managed-identity \
    --enable-azure-rbac \
    --enable-defender \
    --network-plugin azure \
    --network-policy calico \
    --vnet-subnet-id /subscriptions/.../subnets/app-subnet \
    --enable-private-cluster \
    --zones 1 2 3
```

#### 5.1.2 Configuração de Rede

```bash
# Criar Network Policies para segmentação de zonas no Kubernetes
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all-ingress
  namespace: forgesquad-system
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-forgesquad-internal
  namespace: forgesquad-system
spec:
  podSelector:
    matchLabels:
      app.kubernetes.io/part-of: forgesquad
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: forgesquad-system
    ports:
    - protocol: TCP
      port: 8080
    - protocol: TCP
      port: 8443
    - protocol: TCP
      port: 9090
  egress:
  - to:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: forgesquad-data
    ports:
    - protocol: TCP
      port: 5432
    - protocol: TCP
      port: 6379
    - protocol: TCP
      port: 9092
  - to:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: forgesquad-system
EOF
```

#### 5.1.3 Gestão de Certificados

```bash
# 1. Instalar cert-manager
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install cert-manager jetstack/cert-manager \
    --namespace cert-manager \
    --create-namespace \
    --version v1.14.4 \
    --set installCRDs=true \
    --set global.leaderElection.namespace=cert-manager

# 2. Configurar ClusterIssuer com CA interna do banco
cat <<EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: bank-internal-ca
spec:
  ca:
    secretName: bank-root-ca-keypair
---
apiVersion: v1
kind: Secret
metadata:
  name: bank-root-ca-keypair
  namespace: cert-manager
type: kubernetes.io/tls
data:
  tls.crt: <BASE64_ENCODED_CA_CERT>
  tls.key: <BASE64_ENCODED_CA_KEY>
EOF

# 3. Criar certificados para serviços ForgeSquad
cat <<EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: forgesquad-api-cert
  namespace: forgesquad-system
spec:
  secretName: forgesquad-api-tls
  issuerRef:
    name: bank-internal-ca
    kind: ClusterIssuer
  commonName: forgesquad-api.bank.internal
  dnsNames:
  - forgesquad-api.bank.internal
  - forgesquad-api.forgesquad-system.svc.cluster.local
  - "*.forgesquad-system.svc.cluster.local"
  duration: 2160h    # 90 dias
  renewBefore: 360h  # Renovar 15 dias antes
  privateKey:
    algorithm: ECDSA
    size: 384
  usages:
  - server auth
  - client auth
EOF
```

#### 5.1.4 Entradas DNS

```
; Registros DNS internos para ForgeSquad
; Arquivo de zona: bank.internal

; API Gateway (DMZ)
forgesquad-api.bank.internal.        IN A     10.100.1.10
forgesquad-api.bank.internal.        IN A     10.100.1.11  ; HA

; Admin Console (Internal)
forgesquad-admin.bank.internal.      IN A     10.100.2.10

; Dashboard (DMZ)
forgesquad-dashboard.bank.internal.  IN A     10.100.1.20

; Serviços internos (Application Zone)
forgesquad-engine.bank.internal.     IN A     10.100.2.20
forgesquad-audit.bank.internal.      IN A     10.100.2.21
forgesquad-skills.bank.internal.     IN A     10.100.2.22
forgesquad-pipeline.bank.internal.   IN A     10.100.2.23

; Data Zone
forgesquad-db.bank.internal.         IN A     10.100.3.10
forgesquad-db.bank.internal.         IN A     10.100.3.11  ; Standby
forgesquad-redis.bank.internal.      IN A     10.100.3.20
forgesquad-kafka.bank.internal.      IN A     10.100.3.30
forgesquad-kafka.bank.internal.      IN A     10.100.3.31
forgesquad-kafka.bank.internal.      IN A     10.100.3.32

; Vault
forgesquad-vault.bank.internal.      IN A     10.100.2.30
```

### 5.2 Instalação Core

#### 5.2.1 Helm Chart Deployment

```bash
# 1. Adicionar repositório Helm do ForgeSquad
helm repo add forgesquad https://charts.forgesquad.io
helm repo update

# 2. Baixar e personalizar values para ambiente bancário
helm show values forgesquad/forgesquad-enterprise > values-banking.yaml

# 3. Editar values-banking.yaml com configurações do banco
cat > values-banking.yaml <<'EOF'
global:
  environment: production
  edition: enterprise-banking
  domain: bank.internal
  tls:
    enabled: true
    issuerRef:
      name: bank-internal-ca
      kind: ClusterIssuer

# Configuração dos 9 Agentes
agents:
  replicas: 2  # Mínimo 2 para HA
  resources:
    requests:
      cpu: "2"
      memory: 4Gi
    limits:
      cpu: "4"
      memory: 8Gi
  nodeSelector:
    forgesquad.io/zone: application

  architect:
    enabled: true
    replicas: 3  # Agente crítico — 3 réplicas
    omnipresent: true  # Participa de todas as fases
    securityGates: true

  techLead:
    enabled: true
    codeReview:
      enabled: true
      autoApprove: false  # Nunca auto-aprovar em ambiente bancário

  businessAnalyst:
    enabled: true
    reverseEngineering: true
    dataMapping: true  # LGPD data mapping

  devBackend:
    enabled: true
    languages: ["java", "kotlin", "python", "go"]
    frameworks: ["spring-boot", "quarkus", "fastapi"]

  devFrontend:
    enabled: true
    frameworks: ["react", "angular", "vue"]

  qaEngineer:
    enabled: true
    securityTesting:
      sast: true
      dast: true
      sca: true
      pentest: true
    performanceTesting: true

  techWriter:
    enabled: true
    templates: ["adr", "runbook", "api-doc", "regulatory"]

  projectManager:
    enabled: true
    reportFormats: ["pdf", "html", "json"]
    regulatoryReporting: true

  financeAdvisor:
    enabled: true
    riskAssessment: true
    tcoAnalysis: true

# Pipeline Engine
pipeline:
  phases: 10
  steps: 24
  checkpoints: 9
  humanApprovalGates:
    enabled: true
    timeout: 72h  # Timeout para aprovação humana
    escalation:
      enabled: true
      after: 24h
      to: "engineering-director@bank.com"

# Audit Trail
auditTrail:
  enabled: true
  algorithm: SHA-256
  chainVerification: true  # Verificação de integridade da cadeia
  storage:
    type: append-only
    retention: 5y  # 5 anos — requisito Bacen
    encryption: AES-256-GCM

# Banco de Dados
database:
  type: postgresql
  host: forgesquad-db.bank.internal
  port: 5432
  name: forgesquad
  ssl: true
  sslMode: verify-full
  ha:
    enabled: true
    provider: patroni

# Cache
cache:
  type: redis
  host: forgesquad-redis.bank.internal
  port: 6379
  tls: true
  sentinel:
    enabled: true
    masterName: forgesquad-master

# Event Streaming
kafka:
  bootstrapServers: "forgesquad-kafka.bank.internal:9093"
  tls: true
  sasl:
    enabled: true
    mechanism: SCRAM-SHA-512
  topics:
    auditTrail: "forgesquad.audit.trail"
    pipeline: "forgesquad.pipeline.events"
    agents: "forgesquad.agent.communication"
EOF

# 4. Instalar ForgeSquad via Helm
helm install forgesquad forgesquad/forgesquad-enterprise \
    --namespace forgesquad-system \
    --values values-banking.yaml \
    --timeout 15m \
    --wait

# 5. Verificar status da instalação
kubectl get pods -n forgesquad-system -o wide
kubectl get svc -n forgesquad-system
```

#### 5.2.2 Deployment dos Containers de Agentes

```bash
# Verificar que todos os 9 agentes estão running
kubectl get pods -n forgesquad-system -l app.kubernetes.io/component=agent

# Output esperado:
# NAME                                    READY   STATUS    RESTARTS   AGE
# forgesquad-architect-0                  2/2     Running   0          5m
# forgesquad-architect-1                  2/2     Running   0          5m
# forgesquad-architect-2                  2/2     Running   0          5m
# forgesquad-tech-lead-0                  2/2     Running   0          5m
# forgesquad-tech-lead-1                  2/2     Running   0          5m
# forgesquad-business-analyst-0           2/2     Running   0          5m
# forgesquad-business-analyst-1           2/2     Running   0          5m
# forgesquad-dev-backend-0               2/2     Running   0          5m
# forgesquad-dev-backend-1               2/2     Running   0          5m
# forgesquad-dev-frontend-0              2/2     Running   0          5m
# forgesquad-dev-frontend-1              2/2     Running   0          5m
# forgesquad-qa-engineer-0               2/2     Running   0          5m
# forgesquad-qa-engineer-1               2/2     Running   0          5m
# forgesquad-tech-writer-0               2/2     Running   0          5m
# forgesquad-tech-writer-1               2/2     Running   0          5m
# forgesquad-project-manager-0           2/2     Running   0          5m
# forgesquad-project-manager-1           2/2     Running   0          5m
# forgesquad-finance-advisor-0           2/2     Running   0          5m
# forgesquad-finance-advisor-1           2/2     Running   0          5m

# Verificar health checks
for agent in architect tech-lead business-analyst dev-backend dev-frontend \
    qa-engineer tech-writer project-manager finance-advisor; do
    echo "=== $agent ==="
    kubectl exec -n forgesquad-system forgesquad-${agent}-0 -- \
        curl -s http://localhost:8080/health | jq .
done
```

#### 5.2.3 Pipeline Engine Setup

```bash
# Verificar Pipeline Runner Engine
kubectl get pods -n forgesquad-system -l app.kubernetes.io/component=pipeline-runner

# Configurar pipeline com 10 fases, 24 passos e 9 checkpoints
kubectl exec -n forgesquad-system deploy/forgesquad-pipeline-runner -- \
    forgesquad-cli pipeline init \
    --phases 10 \
    --steps 24 \
    --checkpoints 9 \
    --approval-gates enabled \
    --audit-trail enabled \
    --hash-algorithm SHA-256

# Verificar configuração do pipeline
kubectl exec -n forgesquad-system deploy/forgesquad-pipeline-runner -- \
    forgesquad-cli pipeline status
```

#### 5.2.4 Inicialização de Bancos de Dados

```bash
# PostgreSQL — Criar schema e tabelas
kubectl exec -n forgesquad-data deploy/forgesquad-db-primary -- \
    psql -U forgesquad -d forgesquad -f /scripts/init-schema.sql

# Verificar tabelas criadas
kubectl exec -n forgesquad-data deploy/forgesquad-db-primary -- \
    psql -U forgesquad -d forgesquad -c "\dt forgesquad.*"

# Redis — Verificar conectividade e Sentinel
kubectl exec -n forgesquad-data deploy/forgesquad-redis-sentinel-0 -- \
    redis-cli -a $REDIS_PASSWORD --tls \
    --cert /tls/tls.crt --key /tls/tls.key --cacert /tls/ca.crt \
    sentinel master forgesquad-master

# Kafka — Criar tópicos
kubectl exec -n forgesquad-data deploy/forgesquad-kafka-0 -- \
    kafka-topics.sh --create \
    --bootstrap-server localhost:9093 \
    --command-config /etc/kafka/client.properties \
    --topic forgesquad.audit.trail \
    --partitions 12 \
    --replication-factor 3 \
    --config retention.ms=-1 \
    --config cleanup.policy=delete \
    --config min.insync.replicas=2

kubectl exec -n forgesquad-data deploy/forgesquad-kafka-0 -- \
    kafka-topics.sh --create \
    --bootstrap-server localhost:9093 \
    --command-config /etc/kafka/client.properties \
    --topic forgesquad.pipeline.events \
    --partitions 6 \
    --replication-factor 3 \
    --config min.insync.replicas=2

kubectl exec -n forgesquad-data deploy/forgesquad-kafka-0 -- \
    kafka-topics.sh --create \
    --bootstrap-server localhost:9093 \
    --command-config /etc/kafka/client.properties \
    --topic forgesquad.agent.communication \
    --partitions 9 \
    --replication-factor 3 \
    --config min.insync.replicas=2
```

### 5.3 Configuração de Segurança

#### 5.3.1 mTLS entre Todos os Serviços

```bash
# Instalar Istio Service Mesh para mTLS automático
istioctl install --set profile=default \
    --set meshConfig.accessLogFile=/dev/stdout \
    --set meshConfig.enableAutoMtls=true \
    --set values.global.mtls.enabled=true

# Aplicar PeerAuthentication STRICT para o namespace ForgeSquad
cat <<EOF | kubectl apply -f -
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: forgesquad-strict-mtls
  namespace: forgesquad-system
spec:
  mtls:
    mode: STRICT
---
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: forgesquad-data-strict-mtls
  namespace: forgesquad-data
spec:
  mtls:
    mode: STRICT
EOF

# Verificar mTLS está ativo
istioctl proxy-status -n forgesquad-system
```

#### 5.3.2 Integração com Vault / CyberArk

```bash
# HashiCorp Vault — Configurar engine de secrets para ForgeSquad
vault secrets enable -path=forgesquad kv-v2

# Criar políticas de acesso
cat <<EOF | vault policy write forgesquad-agent -
path "forgesquad/data/agents/*" {
  capabilities = ["read"]
}
path "forgesquad/data/pipeline/*" {
  capabilities = ["read"]
}
path "forgesquad/data/integrations/*" {
  capabilities = ["read"]
}
EOF

cat <<EOF | vault policy write forgesquad-admin -
path "forgesquad/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
EOF

# Configurar autenticação Kubernetes
vault auth enable kubernetes
vault write auth/kubernetes/config \
    kubernetes_host="https://kubernetes.default.svc:443" \
    token_reviewer_jwt=@/var/run/secrets/kubernetes.io/serviceaccount/token \
    kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt

vault write auth/kubernetes/role/forgesquad-agent \
    bound_service_account_names=forgesquad-agent-sa \
    bound_service_account_namespaces=forgesquad-system \
    policies=forgesquad-agent \
    ttl=1h

# Armazenar secrets iniciais
vault kv put forgesquad/data/integrations/database \
    host=forgesquad-db.bank.internal \
    port=5432 \
    username=forgesquad \
    password="<GENERATED_SECURE_PASSWORD>" \
    sslmode=verify-full

vault kv put forgesquad/data/integrations/kafka \
    bootstrap_servers=forgesquad-kafka.bank.internal:9093 \
    sasl_username=forgesquad \
    sasl_password="<GENERATED_SECURE_PASSWORD>" \
    sasl_mechanism=SCRAM-SHA-512
```

#### 5.3.3 Rotação Automática de Certificados

```bash
# Cert-manager já configurado na seção 5.1.3
# Verificar renovação automática
kubectl get certificates -n forgesquad-system

# Configurar alerta para certificados próximos da expiração
cat <<EOF | kubectl apply -f -
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: cert-expiry-alert
  namespace: forgesquad-monitoring
spec:
  groups:
  - name: certificate-expiry
    rules:
    - alert: CertificateExpiringSoon
      expr: certmanager_certificate_expiration_timestamp_seconds - time() < 604800
      for: 1h
      labels:
        severity: warning
      annotations:
        summary: "Certificado {{ \$labels.name }} expira em menos de 7 dias"
    - alert: CertificateExpiryCritical
      expr: certmanager_certificate_expiration_timestamp_seconds - time() < 172800
      for: 10m
      labels:
        severity: critical
      annotations:
        summary: "CRÍTICO: Certificado {{ \$labels.name }} expira em menos de 48 horas"
EOF
```

#### 5.3.4 RBAC e Gestão de API Keys

```bash
# Criar ClusterRoles para ForgeSquad
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: forgesquad-operator
rules:
- apiGroups: ["forgesquad.io"]
  resources: ["squads", "pipelines", "agents", "checkpoints"]
  verbs: ["get", "list", "watch", "create", "update", "patch"]
- apiGroups: ["forgesquad.io"]
  resources: ["approvals"]
  verbs: ["get", "list", "watch", "create", "update"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: forgesquad-viewer
rules:
- apiGroups: ["forgesquad.io"]
  resources: ["squads", "pipelines", "agents", "checkpoints", "reports"]
  verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: forgesquad-approver
rules:
- apiGroups: ["forgesquad.io"]
  resources: ["approvals"]
  verbs: ["get", "list", "watch", "create", "update", "patch"]
- apiGroups: ["forgesquad.io"]
  resources: ["checkpoints"]
  verbs: ["get", "list", "watch", "update"]
EOF

# Configurar criptografia em repouso (AES-256)
cat <<EOF | kubectl apply -f -
apiVersion: apiserver.config.k8s.io/v1
kind: EncryptionConfiguration
resources:
- resources:
  - secrets
  - configmaps
  providers:
  - aescbc:
      keys:
      - name: forgesquad-key-1
        secret: <BASE64_ENCODED_32_BYTE_KEY>
  - identity: {}
EOF
```

### 5.4 Configuração de Identidade

#### 5.4.1 Integração AD/LDAP

```bash
# Configurar integração com Active Directory 2019+
kubectl create secret generic forgesquad-ldap-config \
    -n forgesquad-system \
    --from-literal=LDAP_URL="ldaps://ad.bank.internal:636" \
    --from-literal=LDAP_BASE_DN="DC=bank,DC=internal" \
    --from-literal=LDAP_BIND_DN="CN=svc-forgesquad,OU=ServiceAccounts,DC=bank,DC=internal" \
    --from-literal=LDAP_BIND_PASSWORD="<SERVICE_ACCOUNT_PASSWORD>" \
    --from-literal=LDAP_USER_SEARCH_BASE="OU=Users,DC=bank,DC=internal" \
    --from-literal=LDAP_USER_SEARCH_FILTER="(&(objectClass=user)(sAMAccountName={0}))" \
    --from-literal=LDAP_GROUP_SEARCH_BASE="OU=Groups,DC=bank,DC=internal" \
    --from-literal=LDAP_GROUP_SEARCH_FILTER="(&(objectClass=group)(member={0}))"

# Mapeamento de grupos AD → roles ForgeSquad
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: forgesquad-role-mapping
  namespace: forgesquad-system
data:
  role-mapping.yaml: |
    roleMappings:
      - adGroup: "CN=ForgeSquad-Admins,OU=Groups,DC=bank,DC=internal"
        forgeSquadRole: forgesquad-admin
        permissions: ["manage-squads", "manage-agents", "approve-all", "view-audit"]

      - adGroup: "CN=ForgeSquad-Operators,OU=Groups,DC=bank,DC=internal"
        forgeSquadRole: forgesquad-operator
        permissions: ["create-squads", "run-pipelines", "approve-checkpoints"]

      - adGroup: "CN=ForgeSquad-Viewers,OU=Groups,DC=bank,DC=internal"
        forgeSquadRole: forgesquad-viewer
        permissions: ["view-squads", "view-pipelines", "view-reports"]

      - adGroup: "CN=ForgeSquad-Approvers,OU=Groups,DC=bank,DC=internal"
        forgeSquadRole: forgesquad-approver
        permissions: ["approve-checkpoints", "approve-deploy", "view-audit"]

      - adGroup: "CN=Engineering-Directors,OU=Groups,DC=bank,DC=internal"
        forgeSquadRole: forgesquad-executive
        permissions: ["view-reports", "approve-architecture", "approve-go-live"]
EOF
```

#### 5.4.2 SSO — SAML 2.0 / OIDC

```bash
# Configurar SSO com Azure AD (OIDC)
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: forgesquad-oidc-config
  namespace: forgesquad-system
data:
  oidc-config.yaml: |
    oidc:
      issuer: "https://login.microsoftonline.com/<TENANT_ID>/v2.0"
      clientId: "<FORGESQUAD_APP_CLIENT_ID>"
      clientSecretRef:
        name: forgesquad-oidc-secret
        key: client-secret
      redirectUri: "https://forgesquad-admin.bank.internal/auth/callback"
      scopes: ["openid", "profile", "email", "groups"]
      claimMappings:
        username: "preferred_username"
        email: "email"
        groups: "groups"
        displayName: "name"
      sessionConfig:
        maxAge: 8h
        idleTimeout: 30m
        secureCookie: true
        sameSite: Strict

    # Alternativa: SAML 2.0 com ADFS
    saml:
      enabled: false  # Ativar se usar ADFS em vez de Azure AD
      entityId: "https://forgesquad-admin.bank.internal"
      ssoUrl: "https://adfs.bank.internal/adfs/ls"
      certificate: "/certs/adfs-signing.crt"
      attributeMappings:
        username: "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name"
        email: "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress"
        groups: "http://schemas.xmlsoap.org/claims/Group"
EOF
```

#### 5.4.3 MFA (Autenticação Multi-fator)

```bash
# Configurar MFA obrigatório para operações críticas
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: forgesquad-mfa-config
  namespace: forgesquad-system
data:
  mfa-config.yaml: |
    mfa:
      enabled: true
      provider: "azure-ad-conditional-access"  # ou "rsa-securid"

      # Operações que exigem MFA
      requiredFor:
        - "approve-checkpoint"
        - "approve-deploy-production"
        - "approve-architecture-decision"
        - "modify-pipeline-config"
        - "access-audit-trail"
        - "manage-secrets"
        - "modify-agent-config"

      # Providers suportados
      providers:
        azureAD:
          conditionalAccessPolicy: "ForgeSquad-MFA-Policy"
          enforceMFA: true

        rsaSecurID:
          authManagerUrl: "https://rsa-am.bank.internal:5555"
          agentName: "forgesquad-agent"
          configFile: "/etc/rsa/sdconf.rec"

        microsoftAuthenticator:
          enabled: true
          numberMatching: true
          additionalContext: true

      # Sessão MFA
      session:
        stepUpDuration: 15m  # Re-autenticação a cada 15 min para ações críticas
        rememberDevice: false  # Nunca lembrar dispositivo em ambiente bancário
EOF
```

#### 5.4.4 Service Accounts com Rotação

```bash
# Criar service accounts com rotação automática
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: forgesquad-agent-sa
  namespace: forgesquad-system
  annotations:
    forgesquad.io/rotation-period: "90d"
    forgesquad.io/last-rotation: "2026-03-20T00:00:00Z"
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: forgesquad-pipeline-sa
  namespace: forgesquad-system
  annotations:
    forgesquad.io/rotation-period: "90d"
    forgesquad.io/last-rotation: "2026-03-20T00:00:00Z"
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: forgesquad-audit-sa
  namespace: forgesquad-system
  annotations:
    forgesquad.io/rotation-period: "30d"  # Rotação mais frequente para auditoria
    forgesquad.io/last-rotation: "2026-03-20T00:00:00Z"
EOF

# Configurar CronJob para rotação automática de service accounts
cat <<EOF | kubectl apply -f -
apiVersion: batch/v1
kind: CronJob
metadata:
  name: forgesquad-sa-rotation
  namespace: forgesquad-system
spec:
  schedule: "0 2 1 */3 *"  # A cada 3 meses, dia 1, às 02:00
  jobTemplate:
    spec:
      template:
        spec:
          serviceAccountName: forgesquad-admin-sa
          containers:
          - name: sa-rotator
            image: forgesquad/sa-rotator:1.0.0
            command:
            - /bin/sh
            - -c
            - |
              forgesquad-cli sa rotate --namespace forgesquad-system
              forgesquad-cli sa verify --namespace forgesquad-system
              forgesquad-cli audit log --event "service-account-rotation" \
                --status "completed" --timestamp "\$(date -u +%Y-%m-%dT%H:%M:%SZ)"
            env:
            - name: VAULT_ADDR
              value: "https://forgesquad-vault.bank.internal:8200"
          restartPolicy: OnFailure
EOF
```

---

## 6. Integrações Enterprise

### 6.1 ServiceNow — ITSM e Change Management

O ForgeSquad integra-se ao ServiceNow para gerenciamento de mudanças (GMUD), incidentes e sincronização com o CMDB.

**Configuração:**

```yaml
# forgesquad-integrations.yaml — Seção ServiceNow
integrations:
  serviceNow:
    enabled: true
    instance: "https://bankname.service-now.com"
    authentication:
      type: oauth2
      clientId: "<SERVICENOW_CLIENT_ID>"
      clientSecretRef:
        vault: "forgesquad/data/integrations/servicenow"
        key: "client_secret"

    # ITSM — Gerenciamento de Mudanças
    changeManagement:
      enabled: true
      autoCreateChange: true  # Criar GMUD automaticamente em checkpoints de deploy
      changeType: "standard"  # standard, normal, emergency
      approvalGroup: "CAB-ForgeSquad"
      riskAssessment:
        enabled: true
        autoClassify: true  # Finance Advisor calcula risco automaticamente
      templates:
        deploy: "CHG_TEMPLATE_FORGESQUAD_DEPLOY"
        rollback: "CHG_TEMPLATE_FORGESQUAD_ROLLBACK"

    # CMDB — Sincronização de CIs
    cmdb:
      enabled: true
      syncInterval: "30m"
      ciClass: "cmdb_ci_app_server"
      mapping:
        agents: "cmdb_ci_service"
        pipeline: "cmdb_ci_business_app"
        infrastructure: "cmdb_ci_kubernetes_cluster"

    # Incident Management
    incidents:
      enabled: true
      autoCreate: true
      severityMapping:
        critical: "P1"
        high: "P2"
        medium: "P3"
        low: "P4"
      assignmentGroup: "ForgeSquad-Operations"
      escalationPolicy: "ForgeSquad-Escalation"
```

**Fluxo de Change Management:**

1. Pipeline atinge checkpoint de deploy → ForgeSquad cria GMUD no ServiceNow automaticamente.
2. Finance Advisor Agent calcula risco da mudança → classificação automática (baixo/médio/alto).
3. CAB recebe notificação → aprovação no ServiceNow ou diretamente no ForgeSquad.
4. Após aprovação → Pipeline continua com o deploy.
5. Post-deployment → ForgeSquad atualiza GMUD com resultado (sucesso/rollback).

### 6.2 Splunk / ELK — Logs, SIEM e Exportação de Auditoria

```yaml
integrations:
  logging:
    # Opção A: Splunk
    splunk:
      enabled: true
      hecEndpoint: "https://splunk-hec.bank.internal:8088"
      hecTokenRef:
        vault: "forgesquad/data/integrations/splunk"
        key: "hec_token"
      index: "forgesquad_prod"
      sourcetype: "forgesquad:audit"

      # Categorias de logs enviados
      logCategories:
        auditTrail: true          # Todas as ações auditáveis
        pipelineEvents: true      # Eventos de pipeline
        agentCommunication: true  # Comunicação entre agentes
        approvalGates: true       # Aprovações e rejeições
        securityEvents: true      # Eventos de segurança
        performanceMetrics: true  # Métricas de performance

      # SIEM Integration
      siem:
        enabled: true
        correlationRules:
          - name: "unauthorized-approval-attempt"
            severity: critical
          - name: "agent-config-modification"
            severity: high
          - name: "audit-trail-integrity-violation"
            severity: critical

    # Opção B: ELK Stack
    elk:
      enabled: false  # Ativar se usar ELK em vez de Splunk
      elasticsearch:
        hosts: ["https://es-node-1.bank.internal:9200"]
        index: "forgesquad-audit-%{+YYYY.MM.dd}"
        ssl:
          enabled: true
          certificate: "/certs/elk-client.crt"
          key: "/certs/elk-client.key"
      kibana:
        host: "https://kibana.bank.internal:5601"
        dashboards:
          autoImport: true
      logstash:
        hosts: ["logstash.bank.internal:5044"]
```

### 6.3 Dynatrace / AppDynamics — APM e Métricas Customizadas

```yaml
integrations:
  apm:
    # Opção A: Dynatrace
    dynatrace:
      enabled: true
      apiUrl: "https://dynatrace.bank.internal/api/v2"
      apiTokenRef:
        vault: "forgesquad/data/integrations/dynatrace"
        key: "api_token"

      # OneAgent em todos os containers ForgeSquad
      oneAgent:
        enabled: true
        agentGroup: "ForgeSquad-Banking"

      # Métricas customizadas
      customMetrics:
        - name: "forgesquad.pipeline.duration"
          unit: "Millisecond"
          description: "Duração total do pipeline"
        - name: "forgesquad.checkpoint.approval_time"
          unit: "Second"
          description: "Tempo de aprovação em checkpoints"
        - name: "forgesquad.agent.response_time"
          unit: "Millisecond"
          description: "Tempo de resposta por agente"
        - name: "forgesquad.audit.entries_per_minute"
          unit: "Count"
          description: "Entradas de auditoria por minuto"

      # SLOs (Service Level Objectives)
      slos:
        - name: "ForgeSquad API Availability"
          target: 99.95
          metric: "builtin:service.availability"
        - name: "Pipeline Response Time"
          target: 5000  # ms
          metric: "forgesquad.pipeline.duration"

    # Opção B: AppDynamics
    appDynamics:
      enabled: false
      controllerHost: "appdynamics.bank.internal"
      controllerPort: 443
      accountName: "bank-prod"
      applicationName: "ForgeSquad-Banking"
```

### 6.4 Jenkins / GitLab CI — Integração de Pipeline

```yaml
integrations:
  cicd:
    # Jenkins
    jenkins:
      enabled: true
      url: "https://jenkins.bank.internal"
      credentialsRef:
        vault: "forgesquad/data/integrations/jenkins"
        key: "api_token"

      # ForgeSquad como Quality Gate no Jenkins
      qualityGate:
        enabled: true
        webhookUrl: "https://forgesquad-api.bank.internal/webhooks/jenkins"
        stages:
          preBuild:
            agent: architect
            action: "validate-architecture"
          postBuild:
            agent: qa-engineer
            action: "run-quality-checks"
          preDeploy:
            agent: architect
            action: "approve-deploy"
            humanApproval: true

      # Pipelines trigados pelo ForgeSquad
      triggeredPipelines:
        - name: "forgesquad-build-backend"
          job: "ForgeSquad/Build-Backend"
          parameters:
            BRANCH: "{{pipeline.branch}}"
            SQUAD: "{{pipeline.squad}}"
        - name: "forgesquad-build-frontend"
          job: "ForgeSquad/Build-Frontend"

    # GitLab CI
    gitlabCI:
      enabled: false
      url: "https://gitlab.bank.internal"
      tokenRef:
        vault: "forgesquad/data/integrations/gitlab"
        key: "access_token"
```

### 6.5 Jira / Azure DevOps — Sincronização de Work Items

```yaml
integrations:
  projectManagement:
    # Jira
    jira:
      enabled: true
      url: "https://jira.bank.internal"
      authentication:
        type: "personal-access-token"
        tokenRef:
          vault: "forgesquad/data/integrations/jira"
          key: "pat"

      # Sincronização bidirecional
      sync:
        enabled: true
        interval: "5m"
        direction: "bidirectional"

        # Mapeamento de tipos
        typeMapping:
          forgeSquadRequirement: "Story"
          forgeSquadArchitectureDecision: "Technical Task"
          forgeSquadBug: "Bug"
          forgeSquadCheckpoint: "Sub-task"

        # Mapeamento de status
        statusMapping:
          pending: "To Do"
          inProgress: "In Progress"
          awaitingApproval: "In Review"
          approved: "Done"
          rejected: "Reopened"

        # Campos customizados
        customFields:
          squad: "customfield_10100"
          agent: "customfield_10101"
          pipelinePhase: "customfield_10102"
          checkpointId: "customfield_10103"
          auditHash: "customfield_10104"

      # PM Agent gera relatórios com dados do Jira
      reporting:
        burndownChart: true
        velocityTracking: true
        sprintReports: true

    # Azure DevOps
    azureDevOps:
      enabled: false
      organization: "https://dev.azure.com/bankname"
      project: "ForgeSquad"
      patRef:
        vault: "forgesquad/data/integrations/azuredevops"
        key: "pat"
```

### 6.6 Core Banking — API Gateway, IBM MQ, Kafka e Transações

A integração com o core banking é a mais crítica e sensível. O ForgeSquad não acessa diretamente os sistemas de core banking; em vez disso, utiliza uma camada de integração com controles rigorosos.

```yaml
integrations:
  coreBanking:
    enabled: true

    # API Gateway para Core Banking
    apiGateway:
      type: "kong-enterprise"  # ou "apigee", "azure-apim", "aws-api-gateway"
      url: "https://core-api-gw.bank.internal"
      authentication:
        type: mTLS
        clientCertRef:
          vault: "forgesquad/data/integrations/core-banking"
          key: "client_cert"
        clientKeyRef:
          vault: "forgesquad/data/integrations/core-banking"
          key: "client_key"

      # Rate limiting específico para ForgeSquad
      rateLimiting:
        requestsPerMinute: 100
        requestsPerHour: 2000
        burstLimit: 20

      # Endpoints permitidos (whitelist)
      allowedEndpoints:
        - "/api/v1/accounts/query"        # Somente consulta
        - "/api/v1/transactions/query"    # Somente consulta
        - "/api/v1/products/list"         # Catálogo de produtos
        - "/api/v1/customers/query"       # Consulta de clientes (PII mascarado)

      # Endpoints PROIBIDOS (ForgeSquad nunca executa transações financeiras)
      blockedEndpoints:
        - "/api/v1/transactions/create"
        - "/api/v1/transfers/*"
        - "/api/v1/payments/*"
        - "/api/v1/accounts/create"
        - "/api/v1/accounts/close"

    # IBM MQ — Mensageria com Core Banking
    ibmMQ:
      enabled: true
      host: "ibmmq.bank.internal"
      port: 1414
      channel: "FORGESQUAD.SVRCONN"
      queueManager: "QM_CORE_BANKING"
      authentication:
        type: "tls-mutual"
        keystoreRef:
          vault: "forgesquad/data/integrations/ibmmq"
          key: "keystore"

      queues:
        # Filas de entrada (ForgeSquad consome)
        inbound:
          - name: "FORGESQUAD.EVENTS.IN"
            purpose: "Eventos de negócio do core banking"
          - name: "FORGESQUAD.NOTIFICATIONS.IN"
            purpose: "Notificações de transações"

        # Filas de saída (ForgeSquad produz)
        outbound:
          - name: "FORGESQUAD.QUERIES.OUT"
            purpose: "Consultas ao core banking"
          - name: "FORGESQUAD.AUDIT.OUT"
            purpose: "Eventos de auditoria para o core banking"

    # Kafka — Event Streaming com Core Banking
    kafkaBridge:
      enabled: true
      bootstrapServers: "core-kafka.bank.internal:9093"
      securityProtocol: "SASL_SSL"
      saslMechanism: "SCRAM-SHA-512"

      # Tópicos de integração
      topics:
        consume:
          - "core.banking.account.events"
          - "core.banking.transaction.events"
          - "core.banking.product.catalog"
        produce:
          - "forgesquad.core.queries"
          - "forgesquad.core.audit.events"

      # Consumer groups
      consumerGroup: "forgesquad-banking-consumer"

      # Schema Registry (Avro schemas)
      schemaRegistry:
        url: "https://schema-registry.bank.internal:8081"
        compatibility: "BACKWARD"

    # Gestão de Transações
    transactionManagement:
      # ForgeSquad opera em modo READ-ONLY no core banking
      mode: "read-only"

      # Compensação e rollback
      sagaPattern:
        enabled: true
        compensationTimeout: "30s"

      # Circuit breaker para proteger o core banking
      circuitBreaker:
        enabled: true
        failureThreshold: 5
        resetTimeout: "60s"
        halfOpenRequests: 3

      # Timeout para operações no core banking
      timeout:
        connection: "5s"
        read: "30s"
        write: "10s"
```

> **IMPORTANTE:** O ForgeSquad opera em modo **READ-ONLY** com relação ao core banking. O framework **nunca** executa transações financeiras, transferências ou alterações de cadastro diretamente. Essas operações são realizadas pelos desenvolvedores humanos com o suporte dos agentes de IA.

---

## 7. Configuração de Compliance

### 7.1 Audit Trail — Configuração Detalhada

O Audit Trail do ForgeSquad é o pilar central de compliance. Cada ação gera um registro imutável, encadeado com hash SHA-256.

```yaml
compliance:
  auditTrail:
    enabled: true

    # Algoritmo de hash
    hashAlgorithm: "SHA-256"
    chainVerification: true  # Cada registro inclui hash do registro anterior

    # Formato do registro de auditoria
    recordFormat:
      fields:
        - name: "id"
          type: "uuid"
          description: "Identificador único do registro"
        - name: "timestamp"
          type: "iso8601"
          description: "Timestamp UTC com precisão de milissegundos"
        - name: "actor"
          type: "string"
          description: "Usuário ou agente que executou a ação"
        - name: "actorType"
          type: "enum"
          values: ["human", "agent", "system"]
        - name: "action"
          type: "string"
          description: "Ação executada"
        - name: "resource"
          type: "string"
          description: "Recurso afetado"
        - name: "details"
          type: "json"
          description: "Detalhes da ação (input/output)"
        - name: "previousHash"
          type: "string"
          description: "Hash SHA-256 do registro anterior"
        - name: "currentHash"
          type: "string"
          description: "Hash SHA-256 deste registro"
        - name: "signature"
          type: "string"
          description: "Assinatura digital (HSM)"

    # Armazenamento
    storage:
      primary:
        type: "postgresql"
        table: "audit_trail"
        mode: "append-only"  # INSERT apenas, sem UPDATE ou DELETE
        partitioning: "monthly"

      secondary:
        type: "kafka"
        topic: "forgesquad.audit.trail"
        retention: "-1"  # Retenção infinita

      archive:
        type: "s3-compatible"  # MinIO, S3, Azure Blob
        bucket: "forgesquad-audit-archive"
        encryption: "AES-256-GCM"
        lifecycle:
          archiveAfter: "90d"
          storageClass: "GLACIER"  # ou "COLD" para Azure

    # Verificação de integridade
    integrityVerification:
      enabled: true
      schedule: "0 3 * * *"  # Diariamente às 03:00
      alertOnViolation: true
      notifyChannels:
        - type: "email"
          recipients: ["security@bank.internal", "compliance@bank.internal"]
        - type: "servicenow"
          severity: "critical"
```

### 7.2 Retenção de Dados

```yaml
compliance:
  dataRetention:
    # Requisito Bacen: mínimo 5 anos
    auditTrail:
      retention: "5y"
      archiveAfter: "90d"
      deletePolicy: "never"  # Nunca deletar audit trail

    # Logs operacionais
    operationalLogs:
      retention: "2y"
      archiveAfter: "30d"

    # Dados de pipeline
    pipelineData:
      retention: "5y"
      archiveAfter: "180d"

    # Relatórios do PM Agent
    reports:
      retention: "7y"  # SOX exige 7 anos para registros financeiros
      archiveAfter: "365d"

    # Dados de agentes (prompts, outputs)
    agentData:
      retention: "5y"
      archiveAfter: "90d"
      piiMasking: true  # Mascarar PII antes de arquivar
```

### 7.3 Criptografia e Gestão de Chaves

```yaml
compliance:
  encryption:
    # Em repouso
    atRest:
      algorithm: "AES-256-GCM"
      keySource: "hsm"  # Chaves mestras no HSM
      keyRotation:
        enabled: true
        period: "365d"
        autoRotate: true

      # Volumes Kubernetes
      volumeEncryption:
        enabled: true
        provider: "dm-crypt"  # ou "BitLocker" para Azure

    # Em trânsito
    inTransit:
      protocol: "TLS"
      minimumVersion: "1.3"
      allowedCipherSuites:
        - "TLS_AES_256_GCM_SHA384"
        - "TLS_CHACHA20_POLY1305_SHA256"
        - "TLS_AES_128_GCM_SHA256"
      # TLS 1.2 apenas para sistemas legados (core banking)
      legacySupport:
        enabled: true
        minimumVersion: "1.2"
        restrictedTo: ["core-banking-zone"]

    # HSM Integration
    hsm:
      provider: "thales-luna"  # ou "ncipher-nshield", "aws-cloudhsm"
      partitionName: "forgesquad-prod"
      slot: 1
      keyTypes:
        masterKey: "AES-256"
        signingKey: "RSA-4096"
        auditKey: "ECDSA-P384"
```

### 7.4 Classificação de Dados

```yaml
compliance:
  dataClassification:
    levels:
      - name: "public"
        label: "Público"
        controls: ["none"]
        examples: ["documentação pública de APIs", "status do pipeline"]

      - name: "internal"
        label: "Interno"
        controls: ["authentication", "rbac"]
        examples: ["relatórios de squad", "métricas de performance"]

      - name: "confidential"
        label: "Confidencial"
        controls: ["authentication", "rbac", "encryption", "audit-log"]
        examples: ["código-fonte", "decisões arquiteturais", "configurações"]

      - name: "restricted"
        label: "Restrito"
        controls: ["authentication", "rbac", "encryption", "audit-log", "mfa", "pii-masking"]
        examples: ["dados de clientes", "credenciais", "chaves criptográficas"]

    # Mascaramento de PII
    piiHandling:
      enabled: true
      detectionPatterns:
        cpf: '\\d{3}\\.\\d{3}\\.\\d{3}-\\d{2}'
        cnpj: '\\d{2}\\.\\d{3}\\.\\d{3}/\\d{4}-\\d{2}'
        email: '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}'
        telefone: '\\(\\d{2}\\)\\s?\\d{4,5}-\\d{4}'
        cartao: '\\d{4}[\\s-]?\\d{4}[\\s-]?\\d{4}[\\s-]?\\d{4}'
        conta: '\\d{4,6}-[\\dxX]'

      maskingStrategy:
        default: "partial"  # Mostra primeiros e últimos caracteres
        inLogs: "full"      # Mascaramento total em logs
        inAuditTrail: "tokenized"  # Substituir por token reversível (via Vault)

      # Ambientes onde PII é mascarado automaticamente
      enforceIn:
        - "development"
        - "staging"
        - "logs"
        - "audit-trail"
        - "agent-outputs"
```

---

## 8. Casos de Uso Bancários

### 8.1 Modernização de Core Banking

**Problema:** Instituições financeiras brasileiras operam com sistemas de core banking legados (COBOL/mainframe, Temenos, Topaz) que limitam a agilidade e a capacidade de inovação. A modernização desses sistemas é complexa, cara e de alto risco — envolve migração de dados, reescrita de regras de negócio e manutenção de operação contínua.

**Como o ForgeSquad ajuda:**

O ForgeSquad orquestra a modernização em fases controladas com checkpoints obrigatórios em cada etapa crítica:

1. **Business Analyst Agent** realiza engenharia reversa dos módulos legados, documentando regras de negócio, fluxos de dados e dependências.
2. **Architect Agent** projeta a arquitetura de destino (microserviços, event sourcing, CQRS) e define a estratégia de migração (strangler fig pattern).
3. **Dev Backend Agent** implementa os novos microserviços com integração via IBM MQ/Kafka ao sistema legado.
4. **QA Engineer Agent** garante paridade funcional através de testes de regressão comparativa (legado vs. novo).
5. **Finance Advisor Agent** calcula TCO da migração e ROI esperado em cada fase.
6. **Tech Writer Agent** gera documentação regulatória para o Bacen sobre a mudança de sistemas.

**Agentes envolvidos:** Todos os 9 agentes (ciclo completo).

**Benefícios esperados:**

- Redução de 60% no tempo de análise de impacto de mudanças
- Documentação automatizada de regras de negócio legadas
- Rastreabilidade completa de cada decisão de migração (Audit Trail)
- Checkpoints de aprovação humana em cada fase crítica (go/no-go)

### 8.2 Open Finance / Open Banking

**Problema:** A regulamentação do Open Finance Brasil exige que instituições financeiras exponham APIs padronizadas com requisitos rigorosos de segurança (FAPI 1.0), disponibilidade, consentimento e certificação. O desenvolvimento e manutenção dessas APIs é contínuo e regulado.

**Como o ForgeSquad ajuda:**

1. **Business Analyst Agent** mapeia os endpoints obrigatórios conforme especificação da EIOF, gera user stories para cada fase do Open Finance.
2. **Architect Agent** projeta a arquitetura FAPI-compliant com OAuth 2.0, PKCE, PAR e mTLS.
3. **Dev Backend Agent** implementa as APIs REST conforme OpenAPI 3.0, incluindo consent lifecycle management.
4. **QA Engineer Agent** executa a suíte de testes de certificação do Open Finance Brasil automaticamente.
5. **Tech Writer Agent** gera documentação de API no padrão exigido pela EIOF.

**Agentes envolvidos:** Business Analyst, Architect, Dev Backend, QA Engineer, Tech Writer, Project Manager.

**Benefícios esperados:**

- Aceleração de 50% no tempo de certificação de APIs
- Conformidade automática com o padrão FAPI 1.0
- Testes de certificação integrados ao pipeline (execução contínua)
- Documentação regulatória gerada automaticamente

### 8.3 APIs Pix

**Problema:** A integração com o ecossistema Pix exige disponibilidade de 99.999%, latência inferior a 10 segundos, integração com DICT, suporte a QR Code dinâmico, Mecanismo Especial de Devolução (MED) e conformidade com as especificações do SPI.

**Como o ForgeSquad ajuda:**

1. **Architect Agent** projeta a arquitetura de alta disponibilidade para atender ao SLA de 99.999%, incluindo circuit breakers, retry patterns e failover automático.
2. **Dev Backend Agent** implementa as APIs Pix conforme especificação do Bacen, incluindo integração DICT, geração de QR Codes e processamento MED.
3. **QA Engineer Agent** executa testes de carga simulando picos de transações Pix (Black Friday bancário, datas de pagamento).
4. **Finance Advisor Agent** analisa custos de infraestrutura para sustentar o SLA de 99.999%.
5. **Project Manager Agent** monitora SLAs em tempo real e gera alertas proativos.

**Agentes envolvidos:** Architect, Dev Backend, QA Engineer, Finance Advisor, Project Manager.

**Benefícios esperados:**

- Arquitetura validada para 99.999% de disponibilidade
- Testes de carga automatizados para cenários de pico
- Monitoramento proativo de SLAs regulatórios
- Documentação de conformidade com o SPI gerada automaticamente

### 8.4 Risk & Compliance Automation

**Problema:** Bancos precisam manter conformidade contínua com múltiplas regulamentações (Bacen, PCI DSS, LGPD, SOX, Basel III), gerando enormes volumes de relatórios, evidências e controles que são frequentemente manuais e propensos a erros.

**Como o ForgeSquad ajuda:**

1. **Finance Advisor Agent** realiza avaliação contínua de risco operacional para todas as decisões de engenharia.
2. **Architect Agent** valida conformidade arquitetural com os requisitos regulatórios em cada checkpoint.
3. **QA Engineer Agent** executa scans de segurança automatizados (SAST, DAST, SCA) e gera evidências de controle.
4. **Tech Writer Agent** produz relatórios regulatórios em formatos padronizados para cada regulamentação.
5. **Project Manager Agent** consolida o status de compliance em dashboards executivos.

**Agentes envolvidos:** Finance Advisor, Architect, QA Engineer, Tech Writer, Project Manager.

**Benefícios esperados:**

- Redução de 70% no esforço manual de geração de evidências de compliance
- Avaliação de risco automatizada em tempo real
- Relatórios regulatórios gerados automaticamente em cada checkpoint
- Audit Trail imutável atende a requisitos de múltiplas regulamentações simultaneamente

### 8.5 Customer Onboarding Digital

**Problema:** O processo de onboarding digital de clientes bancários (abertura de conta, KYC, verificação de identidade) envolve múltiplos sistemas, requisitos regulatórios (Bacen, LGPD) e experiência do usuário. O desenvolvimento é cross-funcional e complexo.

**Como o ForgeSquad ajuda:**

1. **Business Analyst Agent** mapeia a jornada do cliente, identifica requisitos de KYC/AML e documenta fluxos de consentimento LGPD.
2. **Architect Agent** projeta a arquitetura de onboarding com integração a serviços de verificação de identidade, bureau de crédito e sistemas anti-fraude.
3. **Dev Frontend Agent** implementa a experiência do usuário (mobile-first, acessibilidade WCAG 2.1).
4. **Dev Backend Agent** implementa as APIs de onboarding, integração com serviços externos e orquestração de processos.
5. **QA Engineer Agent** testa fluxos de onboarding em múltiplos dispositivos, cenários de erro e edge cases regulatórios.

**Agentes envolvidos:** Business Analyst, Architect, Dev Frontend, Dev Backend, QA Engineer, Tech Writer.

**Benefícios esperados:**

- Redução de 40% no tempo de desenvolvimento do fluxo de onboarding
- Conformidade LGPD validada automaticamente em cada etapa
- Testes automatizados cobrindo cenários regulatórios (menores de idade, PEPs, sancionados)
- Documentação de fluxos de dados pessoais gerada automaticamente (ROPA)

### 8.6 Anti-Fraud Systems

**Problema:** Sistemas de detecção e prevenção de fraudes bancárias operam em tempo real, processando milhões de transações por dia. A evolução desses sistemas exige desenvolvimento ágil com controles rigorosos de qualidade e segurança — um erro pode gerar falsos positivos (bloqueio indevido de clientes) ou falsos negativos (fraudes não detectadas).

**Como o ForgeSquad ajuda:**

1. **Business Analyst Agent** documenta regras de negócio de detecção de fraude, cenários de ataque conhecidos e requisitos de performance.
2. **Architect Agent** projeta a arquitetura de processamento em tempo real (event streaming com Kafka, CEP engines) com latência inferior a 100ms.
3. **Dev Backend Agent** implementa os engines de regras, modelos de scoring e integrações com sistemas de alerta.
4. **QA Engineer Agent** executa testes com datasets de fraudes conhecidas, simulação de ataques e testes de performance sob carga.
5. **Finance Advisor Agent** analisa o impacto financeiro de taxas de falsos positivos/negativos e recomenda thresholds.

**Agentes envolvidos:** Business Analyst, Architect, Dev Backend, QA Engineer, Finance Advisor, Project Manager.

**Benefícios esperados:**

- Desenvolvimento 50% mais rápido de novas regras de detecção
- Testes automatizados com datasets de fraudes reais (anonimizados)
- Validação de impacto financeiro de cada alteração em regras de fraude
- Rastreabilidade completa de cada mudança em regras de detecção (Audit Trail)

### 8.7 Credit Scoring Models

**Problema:** Modelos de credit scoring são classificados como "modelos" sob a perspectiva regulatória (Basel III SR 11-7), exigindo documentação rigorosa, validação independente, backtesting e monitoramento contínuo. O desenvolvimento desses modelos é multidisciplinar, envolvendo cientistas de dados, engenheiros e equipes de risco.

**Como o ForgeSquad ajuda:**

1. **Business Analyst Agent** documenta os requisitos do modelo, variáveis de entrada, critérios de aceitação e requisitos regulatórios.
2. **Architect Agent** projeta a arquitetura de MLOps (treinamento, deployment, monitoramento) com governança de modelo.
3. **Dev Backend Agent** implementa os pipelines de dados, feature engineering, API de scoring e integração com bureaus de crédito.
4. **QA Engineer Agent** executa testes de validação do modelo (backtesting, stress testing, discriminação estatística, fairness).
5. **Finance Advisor Agent** avalia o impacto financeiro do modelo (expected loss, capital requirements) e valida conformidade com Basel III/IV.
6. **Tech Writer Agent** gera a documentação completa do modelo conforme SR 11-7 (model documentation, validation report, monitoring plan).

**Agentes envolvidos:** Todos os 9 agentes (ciclo completo — classificação regulatória exige governança máxima).

**Benefícios esperados:**

- Documentação de modelo conforme SR 11-7 gerada automaticamente
- Validação independente via segregação de agentes (quem desenvolve ≠ quem valida)
- Backtesting automatizado e monitoramento contínuo de performance do modelo
- Audit Trail completo de cada decisão no ciclo de vida do modelo
- Redução de 60% no tempo de aprovação regulatória de novos modelos

---

## 9. Seguranca e Hardening

A implantacao do ForgeSquad em ambientes bancarios regulados exige uma postura de seguranca em profundidade (defense-in-depth), abrangendo desde o sistema operacional ate a camada de aplicacao. Esta secao detalha os controles obrigatorios para operacao em producao.

### 9.1 Hardening de Sistema Operacional

O ForgeSquad deve ser implantado em servidores com hardening conforme **CIS Benchmark Level 2** para RHEL 8/9 ou Ubuntu 22.04 LTS. Os controles minimos incluem:

| Controle | Descricao | Verificacao |
|----------|-----------|-------------|
| Particoes separadas | `/`, `/var`, `/var/log`, `/var/log/audit`, `/tmp`, `/home` montados separadamente | `df -h`, `mount` |
| Desabilitar servicos desnecessarios | Remover `telnet`, `rsh`, `rlogin`, `tftp`, `talk`, `chargen` | `systemctl list-unit-files` |
| Auditd configurado | Registro de todos os comandos privilegiados e alteracoes de arquivos criticos | `auditctl -l` |
| SSH hardened | Protocolo 2, sem root login, chaves RSA 4096-bit, timeout 300s | `/etc/ssh/sshd_config` |
| Firewall host | iptables/nftables com politica DROP padrao, apenas portas necessarias abertas | `iptables -L -n` |
| AIDE instalado | Verificacao de integridade de arquivos do sistema a cada 4 horas | `aide --check` |
| SELinux/AppArmor | Modo enforcing habilitado com politicas customizadas para os agentes | `getenforce` |
| NTP sincronizado | Chrony configurado com servidores internos, desvio maximo 100ms | `chronyc tracking` |
| Kernel hardening | `sysctl` com parametros de seguranca (ASLR, exec-shield, TCP SYN cookies) | `/etc/sysctl.d/99-forgesquad.conf` |
| Atualizacoes automaticas | Patches de seguranca aplicados automaticamente via WSUS/Satellite | `yum updateinfo security` |

### 9.2 Seguranca de Containers

```yaml
# Politica de seguranca para containers ForgeSquad
securityContext:
  runAsNonRoot: true
  runAsUser: 10001
  runAsGroup: 10001
  readOnlyRootFilesystem: true
  allowPrivilegeEscalation: false
  capabilities:
    drop:
      - ALL
  seccompProfile:
    type: RuntimeDefault
```

**Scanning de imagens:**

- **Trivy** integrado ao pipeline CI/CD para varredura de vulnerabilidades em cada build
- **Aqua Security** para protecao em runtime com politicas de whitelist de processos
- Imagens base permitidas: somente do registro corporativo (Harbor/ECR/ACR)
- Proibido uso de `latest` tag; todas as imagens devem usar digest SHA256
- Varredura semanal de todas as imagens em execucao no cluster

**Runtime protection com Falco:**

```yaml
# Regras Falco customizadas para ForgeSquad
- rule: ForgeSquad Agent Unauthorized Process
  desc: Detecta processos nao autorizados em containers de agentes
  condition: >
    spawned_process and container and
    container.image.repository contains "forgesquad" and
    not proc.name in (node, python, java, sh)
  output: >
    Processo nao autorizado em container ForgeSquad
    (user=%user.name command=%proc.cmdline container=%container.name)
  priority: WARNING
  tags: [forgesquad, security, process]
```

### 9.3 Seguranca de Rede

**Micro-segmentacao:**

| Zona | Origem | Destino | Portas | Protocolo |
|------|--------|---------|--------|-----------|
| DMZ | Internet | WAF/Load Balancer | 443 | HTTPS/TLS 1.3 |
| App Tier | WAF | API Gateway | 8443 | mTLS |
| Agent Network | API Gateway | Agent Mesh | 9090-9099 | gRPC + mTLS |
| Data Tier | Agent Mesh | PostgreSQL/Redis | 5432, 6379 | TLS + IAM Auth |
| Audit Tier | Agent Mesh | Audit Service | 9100 | mTLS |
| Management | Bastion | Todos | 22 (SSH) | SSH + MFA |
| Monitoring | Prometheus/Grafana | Todos | 9090, 3000 | mTLS |

**WAF Rules (OWASP Top 10):**

- SQL Injection: bloqueio + alerta ao SOC
- XSS (Cross-Site Scripting): sanitizacao automatica
- SSRF (Server-Side Request Forgery): whitelist de destinos permitidos
- Rate limiting: 100 req/min por IP, 1000 req/min por tenant
- Geo-blocking: apenas paises autorizados pelo compliance

**DDoS Protection:**

- AWS Shield Advanced / Azure DDoS Protection Standard
- Rate limiting em camadas (L3/L4 e L7)
- Auto-scaling reativo para absorver picos

### 9.4 Seguranca de Banco de Dados

```sql
-- Transparent Data Encryption (TDE)
ALTER DATABASE forgesquad_prod SET ENCRYPTION ON;

-- Row-Level Security para isolamento de squads
CREATE POLICY squad_isolation ON pipeline_executions
  USING (squad_id = current_setting('app.current_squad_id')::uuid);

ALTER TABLE pipeline_executions ENABLE ROW LEVEL SECURITY;

-- Audit logging nativo
ALTER SYSTEM SET pgaudit.log = 'write, ddl, role';
ALTER SYSTEM SET pgaudit.log_catalog = on;
ALTER SYSTEM SET pgaudit.log_relation = on;
ALTER SYSTEM SET pgaudit.log_statement_once = on;
```

- Criptografia em repouso: AES-256 com chaves gerenciadas por HSM (AWS CloudHSM / Azure Dedicated HSM)
- Criptografia em transito: TLS 1.3 obrigatorio para todas as conexoes
- Rotacao de credenciais: automatica a cada 90 dias via Vault
- Backup criptografado: chaves separadas do backup, armazenadas em HSM

### 9.5 Seguranca de API

```yaml
# Configuracao do API Gateway
apiGateway:
  authentication:
    type: OAuth2.0
    provider: corporate-idp
    scopes:
      - forgesquad:read
      - forgesquad:execute
      - forgesquad:admin
    tokenExpiry: 3600  # 1 hora

  mTLS:
    enabled: true
    clientCertValidation: strict
    crlCheck: true
    ocspStapling: true

  rateLimiting:
    global: 10000/min
    perClient: 500/min
    perEndpoint:
      /api/v1/pipelines/execute: 50/min
      /api/v1/agents/invoke: 200/min
      /api/v1/audit/query: 100/min

  inputValidation:
    maxBodySize: 10MB
    contentTypeWhitelist:
      - application/json
      - multipart/form-data
    jsonSchemaValidation: true
    sqlInjectionProtection: true
    xssProtection: true
```

### 9.6 Testes de Penetracao

| Tipo | Frequencia | Escopo | Responsavel |
|------|-----------|--------|-------------|
| Pentest externo | Anual | Superficie de ataque completa | Empresa terceira certificada (CREST/OSCP) |
| Pentest interno | Trimestral | Rede interna, APIs, agentes | Red Team interno + terceiro |
| Scan de vulnerabilidades | Semanal | Infraestrutura + aplicacao | Equipe de seguranca |
| Code review de seguranca | A cada release | Codigo-fonte dos agentes | AppSec team |
| Threat modeling | A cada mudanca arquitetural | Componentes novos/alterados | Arquiteto + Security Champion |

### 9.7 Gestao de Vulnerabilidades

| Severidade | SLA de Remediacao | Acao Imediata | Escalonamento |
|------------|-------------------|---------------|---------------|
| **Critica (CVSS >= 9.0)** | 24 horas | Isolamento do componente afetado, notificacao ao CISO | VP de Tecnologia |
| **Alta (CVSS 7.0-8.9)** | 72 horas | Implementacao de controle compensatorio | Gerente de Seguranca |
| **Media (CVSS 4.0-6.9)** | 30 dias | Planejamento de patch no proximo ciclo | Coordenador de Infra |
| **Baixa (CVSS < 4.0)** | 90 dias | Inclusao no backlog de seguranca | Analista de Seguranca |

**Processo de gestao:**

1. Deteccao automatizada via Trivy, Qualys, ou Nessus
2. Classificacao automatica por CVSS + contexto bancario (ativos criticos recebem +1 nivel)
3. Atribuicao automatica ao responsavel pelo componente
4. Rastreamento em dashboard centralizado com metricas de SLA
5. Validacao pos-remediacao com re-scan automatico
6. Relatorio mensal ao Comite de Seguranca da Informacao

---

## 10. Operacao e Monitoramento

### 10.1 Health Checks

Todos os componentes do ForgeSquad implementam tres tipos de probes conforme padrao Kubernetes:

```yaml
# Configuracao de probes para agentes ForgeSquad
livenessProbe:
  httpGet:
    path: /health/live
    port: 9090
  initialDelaySeconds: 30
  periodSeconds: 10
  timeoutSeconds: 5
  failureThreshold: 3
  # Reinicia o container se falhar 3 vezes consecutivas

readinessProbe:
  httpGet:
    path: /health/ready
    port: 9090
  initialDelaySeconds: 10
  periodSeconds: 5
  timeoutSeconds: 3
  failureThreshold: 2
  # Remove do load balancer se nao estiver pronto

startupProbe:
  httpGet:
    path: /health/startup
    port: 9090
  initialDelaySeconds: 5
  periodSeconds: 5
  failureThreshold: 30
  # Permite ate 150s para inicializacao (carga de modelos, conexoes)
```

**Endpoints de health check por componente:**

| Componente | Endpoint | Verificacoes |
|-----------|----------|-------------|
| API Gateway | `/health/gateway` | Upstream backends, certificados TLS, rate limiter |
| Pipeline Runner | `/health/pipeline` | Fila de execucao, conexao com DB, agent mesh |
| Agentes (cada) | `/health/agent/{role}` | Modelo carregado, memoria disponivel, conexoes ativas |
| Audit Service | `/health/audit` | Storage disponivel, integridade da cadeia, replicacao |
| Redis Cache | `/health/cache` | Memoria utilizada, conexoes, replicacao |

### 10.2 Monitoramento de SLA

**Target: 99.95% de disponibilidade** (equivale a ~22 minutos de downtime por mes)

```yaml
# Alertas de SLA configurados no Prometheus
groups:
  - name: forgesquad-sla
    rules:
      - alert: AvailabilityBelow99_95
        expr: |
          1 - (sum(rate(http_requests_total{status=~"5.."}[5m])) /
          sum(rate(http_requests_total[5m]))) < 0.9995
        for: 5m
        labels:
          severity: critical
          team: platform
        annotations:
          summary: "Disponibilidade abaixo de 99.95%"
          runbook: "https://wiki.internal/runbooks/sla-breach"

      - alert: PipelineLatencyP99High
        expr: |
          histogram_quantile(0.99,
            rate(pipeline_execution_duration_seconds_bucket[5m])) > 300
        for: 10m
        labels:
          severity: warning
        annotations:
          summary: "Latencia P99 de pipeline acima de 5 minutos"
```

### 10.3 Capacity Planning

| Metrica | Threshold de Alerta | Threshold de Escalonamento | Acao |
|---------|---------------------|---------------------------|------|
| CPU por node | 70% (warning) | 85% (critical) | Scale-out horizontal |
| Memoria por node | 75% (warning) | 90% (critical) | Scale-out + investigacao |
| Disco (audit logs) | 70% (warning) | 85% (critical) | Rotacao + expansao |
| Fila de pipelines | 50 pendentes | 100 pendentes | Scale-out de workers |
| Conexoes DB | 70% do pool | 85% do pool | Aumentar pool + otimizar queries |
| Latencia inter-agente | 200ms P95 | 500ms P95 | Investigar rede/mesh |

### 10.4 Resposta a Incidentes

**Classificacao de incidentes:**

| Prioridade | Descricao | Tempo de Resposta | Tempo de Resolucao | Comunicacao |
|-----------|-----------|-------------------|---------------------|-------------|
| **P1 - Critico** | Pipeline de producao parado, perda de dados, brecha de seguranca | 15 minutos | 1 hora | CISO + VP + War Room |
| **P2 - Alto** | Degradacao significativa, agente principal indisponivel | 30 minutos | 4 horas | Gerente + Equipe on-call |
| **P3 - Medio** | Funcionalidade secundaria indisponivel, lentidao | 2 horas | 24 horas | Equipe via Slack/Teams |
| **P4 - Baixo** | Problema estetico, melhoria solicitada | 8 horas | 5 dias uteis | Backlog normal |

### 10.5 Runbooks Operacionais

#### Runbook 1: Falha de Agente

```
TITULO: Recuperacao de Agente ForgeSquad Indisponivel
TRIGGER: Alerta "AgentHealthCheckFailed" no PagerDuty
SEVERIDADE: P2

PASSOS:
1. Verificar status do pod/container:
   $ kubectl get pods -n forgesquad -l agent-role={ROLE}
   $ kubectl describe pod {POD_NAME} -n forgesquad

2. Verificar logs recentes:
   $ kubectl logs {POD_NAME} -n forgesquad --tail=100

3. Se OOMKilled:
   a. Verificar consumo de memoria: kubectl top pod {POD_NAME}
   b. Aumentar limit temporariamente: kubectl patch deployment...
   c. Abrir ticket para investigacao de memory leak

4. Se CrashLoopBackOff:
   a. Verificar logs do container anterior: kubectl logs {POD_NAME} --previous
   b. Verificar ConfigMaps e Secrets atualizados
   c. Rollback se deployment recente: kubectl rollout undo deployment/{DEPLOY}

5. Se ImagePullBackOff:
   a. Verificar credenciais do registry: kubectl get secret regcred
   b. Verificar disponibilidade da imagem no Harbor/ECR

6. Validar recuperacao:
   $ curl -s http://{POD_IP}:9090/health/ready | jq .

7. Documentar no ticket e notificar equipe.
```

#### Runbook 2: Pipeline Travado

```
TITULO: Pipeline de Execucao Travado (Stuck)
TRIGGER: Alerta "PipelineExecutionTimeout" (> 30 min sem progresso)
SEVERIDADE: P2

PASSOS:
1. Identificar pipeline travado:
   $ forgesquad pipeline status --stuck --format=json

2. Verificar em qual step esta travado:
   $ forgesquad pipeline inspect {PIPELINE_ID} --steps

3. Se travado em Approval Gate:
   a. Verificar se ha aprovacao pendente: forgesquad approvals list
   b. Notificar aprovador ou escalonar
   c. Se emergencia: forgesquad approvals override {GATE_ID} --reason="P1 incident"

4. Se travado em execucao de agente:
   a. Verificar logs do agente: forgesquad agent logs {AGENT_ID} --tail=50
   b. Verificar se agente esta responsivo: forgesquad agent ping {AGENT_ID}
   c. Se nao responsivo: forgesquad agent restart {AGENT_ID}

5. Se travado por dependencia externa (API, DB):
   a. Verificar conectividade: forgesquad diagnostics connectivity
   b. Verificar status do servico externo
   c. Retry manual: forgesquad pipeline retry {PIPELINE_ID} --from-step={STEP}

6. Documentar causa raiz e atualizar runbook se necessario.
```

#### Runbook 3: Gap no Audit Trail

```
TITULO: Deteccao de Gap no Audit Trail
TRIGGER: Alerta "AuditTrailGapDetected" (sequencia de eventos quebrada)
SEVERIDADE: P1 (compliance-critical)

PASSOS:
1. IMEDIATO: Pausar todos os pipelines em execucao:
   $ forgesquad pipeline pause-all --reason="Audit trail gap investigation"

2. Identificar o gap:
   $ forgesquad audit verify-chain --from={LAST_KNOWN_EVENT} --verbose
   $ forgesquad audit gaps --format=detailed

3. Verificar replicacao do audit store:
   $ forgesquad audit replication-status
   Se lag > 0: aguardar sincronizacao e re-verificar

4. Verificar se eventos existem em replicas/backup:
   $ forgesquad audit search --backup --event-range={START}:{END}

5. Se eventos encontrados em backup:
   a. Restaurar eventos: forgesquad audit restore --from-backup --range={RANGE}
   b. Re-verificar cadeia: forgesquad audit verify-chain --full

6. Se eventos PERDIDOS (irrecuperaveis):
   a. ESCALONAR IMEDIATAMENTE ao CISO e Compliance Officer
   b. Registrar incidente de compliance
   c. Gerar relatorio de gap para regulador (se aplicavel)
   d. Iniciar investigacao forense

7. Retomar pipelines somente apos validacao completa:
   $ forgesquad audit verify-chain --full
   $ forgesquad pipeline resume-all

8. Post-mortem obrigatorio em 48 horas.
```

---

## 11. Disaster Recovery

### 11.1 Objetivos de Recuperacao

| Metrica | Valor | Justificativa |
|---------|-------|---------------|
| **RPO (Recovery Point Objective)** | 5 minutos | Replicacao assincrona com confirmacao; perda maxima aceitavel de dados |
| **RTO (Recovery Time Objective)** | 30 minutos | Tempo maximo para restauracao completa de servicos criticos |
| **MTTR (Mean Time To Repair)** | 45 minutos | Tempo medio de reparo incluindo validacao |
| **RPO Audit Trail** | 0 (zero) | Replicacao sincrona obrigatoria para dados de auditoria |

### 11.2 Estrategia de Backup

**Backup completo (Full):**

| Item | Frequencia | Retencao | Destino | Criptografia |
|------|-----------|----------|---------|-------------|
| Banco de dados principal | Diario (02:00 UTC-3) | 90 dias | Storage secundario + offsite | AES-256 (HSM) |
| Audit Trail | Diario (01:00 UTC-3) | 7 anos (regulatorio) | Storage imutavel (WORM) | AES-256 (HSM) |
| Configuracoes (GitOps) | A cada commit | Indefinida | Git remoto + backup offsite | GPG signed |
| Secrets/Certificados | Diario | 365 dias | Vault backup + HSM backup | Vault seal |
| Imagens de container | A cada build | 180 dias | Registry secundario | Registry signing |

**Backup incremental:**

- Banco de dados: WAL archiving continuo (a cada 5 minutos)
- Audit Trail: Replicacao sincrona para site secundario
- Configuracoes: Commit-level tracking via GitOps
- Teste de restore: semanal automatizado + mensal manual com validacao

### 11.3 Procedimento de Failover

```
SEQUENCIA DE FAILOVER (automatizado via Runbook Ansible/Terraform):

1. DETECCAO (0-2 min):
   - Health check falha 3x consecutivas no site primario
   - Alertas disparam para equipe de plantao
   - Sistema de failover automatico acionado

2. DECISAO (2-5 min):
   - Failover automatico: se >3 componentes criticos indisponiveis
   - Failover manual: se degradacao parcial (requer aprovacao do on-call)

3. DNS FAILOVER (5-8 min):
   - Route53/Azure Traffic Manager atualiza registros DNS
   - TTL pre-configurado em 60 segundos para propagacao rapida
   - Health checks do DNS validam site secundario antes da troca

4. PROMOCAO DO BANCO (8-15 min):
   - Replica PostgreSQL promovida a primaria
   - Verificacao de consistencia: pg_isready + query de validacao
   - Conexoes redirecionadas via PgBouncer

5. VALIDACAO (15-25 min):
   - Smoke tests automatizados em todos os endpoints criticos
   - Verificacao de integridade do Audit Trail
   - Validacao de conectividade entre agentes
   - Health check de cada agente individualmente

6. COMUNICACAO (25-30 min):
   - Notificacao a stakeholders via canal de incidentes
   - Atualizacao de status page
   - Registro do evento no sistema de incidentes
```

### 11.4 Topologia de DR

```
Site Primario (Datacenter A / Region us-east-1)     Site DR (Datacenter B / Region us-west-2)
+------------------------------------------+        +------------------------------------------+
|  ForgeSquad Cluster (Active)             |        |  ForgeSquad Cluster (Standby)             |
|  - 9 Agentes ativos                      |  sync  |  - 9 Agentes em warm standby              |
|  - Pipeline Runner (primary)             |------->|  - Pipeline Runner (standby)               |
|  - PostgreSQL (primary)                  |  async |  - PostgreSQL (replica, 5min lag)           |
|  - Redis (primary)                       |------->|  - Redis (replica)                         |
|  - Audit Trail (primary)                 |  sync  |  - Audit Trail (replica sincrona)           |
+------------------------------------------+        +------------------------------------------+
```

### 11.5 Testes de DR

| Tipo de Teste | Frequencia | Duracao | Participantes | Criterio de Sucesso |
|--------------|-----------|---------|---------------|---------------------|
| **Tabletop exercise** | Trimestral | 2 horas | Equipe de operacao + gestao | Todos os passos revisados, gaps identificados |
| **Failover parcial** | Trimestral | 4 horas | Equipe de operacao | Banco promovido, queries OK, rollback OK |
| **Failover completo** | Semestral | 8 horas | Todas as equipes | RTO atingido, RPO validado, audit trail integro |
| **Restore de backup** | Mensal | 2 horas | DBA + Infra | Restore completo, dados validados, checksums OK |
| **Chaos engineering** | Mensal | 4 horas | SRE team | Sistema se recupera automaticamente de falhas injetadas |

---

## 12. Governanca

### 12.1 Gestao de Mudancas (Change Management)

O ForgeSquad integra-se ao processo de Change Management existente via CAB (Change Advisory Board):

| Tipo de Mudanca | Aprovacao | Lead Time | Janela |
|----------------|-----------|-----------|--------|
| **Standard** (patch de seguranca, atualizacao de configuracao) | Pre-aprovada pelo CAB | 48 horas | Janela de manutencao programada |
| **Normal** (nova versao de agente, novo step de pipeline) | CAB semanal | 5-10 dias uteis | Janela de release programada |
| **Emergencial** (correcao critica de seguranca ou producao) | ECAB (Emergency CAB) | 2-4 horas | Qualquer momento com aprovacao |

**Fluxo de aprovacao para mudancas no ForgeSquad:**

1. RFC (Request for Change) criado no ServiceNow/Jira
2. Analise de impacto automatizada pelo Architect Agent
3. Revisao por pares (peer review) do codigo/configuracao
4. Aprovacao do CAB (ou ECAB para emergencias)
5. Deployment via pipeline automatizado (GitOps)
6. Validacao pos-deployment (smoke tests + monitoring)
7. Closure do RFC com evidencias

### 12.2 Release Management

**Estrategias de deployment suportadas:**

| Estrategia | Uso | Rollback | Risco |
|-----------|-----|----------|-------|
| **Blue-Green** | Releases maiores, mudancas de schema | Instantaneo (troca de rota) | Baixo (ambiente completo de fallback) |
| **Canary** | Features novas, mudancas comportamentais | Rapido (redirect do canary) | Muito baixo (exposicao gradual) |
| **Rolling** | Patches, atualizacoes menores | Moderado (pod a pod) | Baixo |
| **Feature Flags** | Features experimentais, A/B testing | Instantaneo (toggle) | Muito baixo |

```yaml
# Exemplo de Canary Deployment para ForgeSquad
apiVersion: flagger.app/v1beta1
kind: Canary
metadata:
  name: forgesquad-pipeline-runner
  namespace: forgesquad
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: pipeline-runner
  progressDeadlineSeconds: 600
  analysis:
    interval: 60s
    threshold: 5
    maxWeight: 50
    stepWeight: 10
    metrics:
      - name: request-success-rate
        thresholdRange:
          min: 99
      - name: request-duration
        thresholdRange:
          max: 500
```

### 12.3 Gestao de Ambientes

```
DEV ──> SIT ──> UAT ──> PRE-PROD ──> PROD
 │       │       │         │           │
 │       │       │         │           └─ Producao (dados reais, compliance total)
 │       │       │         └─ Pre-Producao (replica de PROD, dados anonimizados)
 │       │       └─ User Acceptance Testing (dados sinteticos, acesso de negocio)
 │       └─ System Integration Testing (integracao com core banking, dados sinteticos)
 └─ Desenvolvimento (dados mock, sem restricoes de compliance)
```

| Ambiente | Dados | Compliance | Acesso | Refresh |
|----------|-------|------------|--------|---------|
| DEV | Mock/sinteticos | Parcial | Desenvolvedores | Sob demanda |
| SIT | Sinteticos realistas | Parcial | Dev + QA | Semanal |
| UAT | Sinteticos + anonimizados | Completo | Dev + QA + Negocio | Por release |
| PRE-PROD | Anonimizados (copia de PROD) | Completo | Operacao + QA | Mensal |
| PROD | Reais | Completo | Operacao (restrito) | N/A |

### 12.4 Segregacao de Funcoes (Separation of Duties)

O principio de **4-eyes (quatro olhos)** e aplicado em todas as operacoes criticas:

| Operacao | Quem Executa | Quem Aprova | Evidencia |
|----------|-------------|-------------|-----------|
| Deploy em PROD | Pipeline automatizado | Tech Lead + Release Manager | Audit Trail + aprovacao no pipeline |
| Alteracao de agente | Desenvolvedor | Architect Agent + Code Review | Git history + PR approval |
| Acesso a dados de producao | DBA | Gerente de Seguranca | Ticket + log de acesso |
| Alteracao de regras de compliance | Compliance Officer | CISO | Audit Trail + assinatura digital |
| Criacao de usuario privilegiado | Admin | Gerente de TI | IAM log + ticket |
| Override de Approval Gate | On-call Engineer | Incident Commander | Audit Trail + justificativa |

### 12.5 Alinhamento ITIL

| Processo ITIL | Integracao ForgeSquad |
|--------------|----------------------|
| Incident Management | Alertas automaticos geram tickets, runbooks linkados, metricas de MTTR |
| Problem Management | Audit Trail fornece dados para analise de causa raiz |
| Change Management | Pipeline integrado ao CAB, RFCs automaticas |
| Release Management | Blue-green/canary com rollback automatico |
| Service Level Management | Dashboard de SLA em tempo real, relatorios automaticos |
| Configuration Management | CMDB atualizado via GitOps, drift detection |
| Knowledge Management | Runbooks versionados, wiki auto-gerada pelo Tech Writer Agent |

---

## 13. Estimativa de Custos para Ambiente Bancario

### 13.1 Infraestrutura On-Premises

| Item | Quantidade | Custo Unitario (USD/mes) | Custo Mensal (USD) |
|------|-----------|-------------------------|-------------------|
| Servidores de aplicacao (32 vCPU, 128GB RAM) | 6 | 2.500 | 15.000 |
| Servidores de banco de dados (64 vCPU, 256GB RAM) | 4 | 4.000 | 16.000 |
| Storage SAN (SSD, 50TB) | 1 | 3.000 | 3.000 |
| Storage WORM para audit (100TB) | 1 | 2.000 | 2.000 |
| Switches de rede (10GbE) | 4 | 500 | 2.000 |
| Load Balancers (F5/HAProxy) | 2 | 1.500 | 3.000 |
| HSM (Hardware Security Module) | 2 | 2.000 | 4.000 |
| Licenca VMware/Hypervisor | 1 | 3.000 | 3.000 |
| **Subtotal Infra On-Prem** | | | **48.000** |

### 13.2 Infraestrutura Cloud (AWS/Azure)

| Servico | Especificacao | Custo Mensal (USD) |
|---------|-------------|-------------------|
| Kubernetes (EKS/AKS) | 3 node groups, auto-scaling | 8.500 |
| RDS/Azure SQL (Multi-AZ) | db.r6g.2xlarge, 2TB storage | 6.200 |
| ElastiCache/Azure Cache | r6g.xlarge, replica | 2.400 |
| S3/Blob Storage (audit) | 100TB, immutable, lifecycle | 2.300 |
| CloudHSM/Dedicated HSM | 2 unidades (HA) | 3.200 |
| WAF + DDoS Protection | Advanced/Standard | 1.800 |
| Secrets Manager/Key Vault | 500 secrets, rotacao | 400 |
| CloudWatch/Monitor + Logs | Metricas + logs + alertas | 1.500 |
| Network (VPC, Transit GW) | Multi-AZ, VPN backup | 1.200 |
| DR Region (standby) | Replicas + warm standby | 5.500 |
| **Subtotal Cloud** | | **33.000** |

### 13.3 Licenciamento de Software

| Software | Tipo | Custo Mensal (USD) |
|----------|------|-------------------|
| ForgeSquad Enterprise License | Per-squad (3 squads) | 15.000 |
| PostgreSQL Enterprise (EDB) | Suporte + HA | 3.000 |
| Prometheus + Grafana Enterprise | Monitoramento | 1.500 |
| Trivy/Aqua Security | Container security | 2.500 |
| Falco Enterprise | Runtime security | 1.500 |
| Vault Enterprise | Secrets management | 2.000 |
| Flagger/ArgoCD Enterprise | GitOps + progressive delivery | 1.000 |
| PagerDuty/OpsGenie | Incident management | 800 |
| **Subtotal Licencas** | | **27.300** |

### 13.4 Equipe

| Funcao | Quantidade | Custo Mensal (USD) | Fase |
|--------|-----------|-------------------|------|
| Arquiteto de Solucao | 1 | 18.000 | Implementacao + Operacao |
| Engenheiro DevOps/SRE | 2 | 28.000 | Implementacao + Operacao |
| DBA | 1 | 14.000 | Implementacao + Operacao |
| Engenheiro de Seguranca | 1 | 16.000 | Implementacao + Operacao |
| Analista de Compliance | 1 | 12.000 | Implementacao + Operacao |
| Desenvolvedores (integracao) | 3 | 36.000 | Apenas Implementacao (6 meses) |
| Gerente de Projeto | 1 | 16.000 | Apenas Implementacao (6 meses) |
| **Subtotal Equipe (impl.)** | | **140.000** | Primeiros 6 meses |
| **Subtotal Equipe (oper.)** | | **88.000** | Apos go-live |

### 13.5 TCO Comparativo (3 Anos)

| Cenario | Ano 1 (USD) | Ano 2 (USD) | Ano 3 (USD) | TCO 3 Anos (USD) |
|---------|------------|------------|------------|------------------|
| **On-Premises** | 1.680.000 | 1.320.000 | 1.380.000 | **4.380.000** |
| **Hibrido (on-prem + cloud DR)** | 1.520.000 | 1.180.000 | 1.220.000 | **3.920.000** |
| **Full Cloud** | 1.280.000 | 1.050.000 | 1.080.000 | **3.410.000** |

> **Nota:** Os valores acima sao estimativas referenciais e podem variar significativamente conforme regiao, fornecedor, volume de negociacao e requisitos especificos de cada instituicao. O cenario full cloud apresenta menor TCO, porem exige validacao regulatoria para uso de nuvem publica em workloads bancarios criticos conforme Resolucao BCB 4.893/2021.

---

## 14. Roadmap de Implantacao

### 14.1 Visao Geral das Fases

| Fase | Semanas | Descricao | Entregaveis Principais |
|------|---------|-----------|----------------------|
| **Fase 1** | 1-4 | Assessment e Planejamento | Documento de arquitetura, plano de projeto, analise de gaps |
| **Fase 2** | 5-8 | Infraestrutura e Seguranca | Ambiente provisionado, baseline de seguranca, rede configurada |
| **Fase 3** | 9-12 | Deploy Core e Configuracao | ForgeSquad instalado, agentes configurados, pipelines basicos |
| **Fase 4** | 13-16 | Integracao e Compliance | Core banking integrado, audit trail validado, compliance OK |
| **Fase 5** | 17-20 | UAT e Testes | Testes de aceitacao, performance, seguranca aprovados |
| **Fase 6** | 21-24 | Go-Live | Producao ativa, cutover executado, monitoring operacional |
| **Fase 7** | 25-28 | Estabilizacao | Otimizacao, knowledge transfer, handover para operacao |

### 14.2 Detalhamento por Fase

**Fase 1 - Assessment e Planejamento (Semanas 1-4):**

- Semana 1: Kickoff, alinhamento de stakeholders, coleta de requisitos
- Semana 2: Assessment de infraestrutura atual, gap analysis de seguranca
- Semana 3: Definicao de arquitetura, revisao com arquitetura corporativa
- Semana 4: Plano de projeto detalhado, cronograma, matriz RACI, aprovacao pelo CAB
- Gate: Aprovacao do documento de arquitetura pelo Comite de Arquitetura

**Fase 2 - Infraestrutura e Seguranca (Semanas 5-8):**

- Semana 5: Provisionamento de servidores/cloud, configuracao de rede
- Semana 6: Hardening de SO, instalacao de ferramentas de seguranca
- Semana 7: Configuracao de Kubernetes/container runtime, registry privado
- Semana 8: Setup de monitoring, logging, alertas; baseline de seguranca validado
- Gate: Scan de vulnerabilidades limpo (zero Critical/High)

**Fase 3 - Deploy Core e Configuracao (Semanas 9-12):**

- Semana 9: Instalacao do ForgeSquad core, configuracao de banco de dados
- Semana 10: Configuracao dos 9 agentes, personalizacao de personas
- Semana 11: Criacao de pipelines customizados para o banco, approval gates
- Semana 12: Testes unitarios e de integracao dos agentes, ajuste de parametros
- Gate: Todos os agentes operacionais, pipeline basico executando end-to-end

**Fase 4 - Integracao e Compliance (Semanas 13-16):**

- Semana 13: Integracao com core banking (APIs, filas, batch)
- Semana 14: Integracao com LDAP/AD, SSO, MFA corporativo
- Semana 15: Configuracao e validacao do Audit Trail completo
- Semana 16: Auditoria interna de compliance, geracao de evidencias regulatorias
- Gate: Aprovacao do Compliance Officer e do Auditor Interno

**Fase 5 - UAT e Testes (Semanas 17-20):**

- Semana 17: Testes de aceitacao do usuario (UAT) com equipe de negocio
- Semana 18: Testes de performance e carga (objetivo: 1000 pipelines/dia)
- Semana 19: Pentest externo, scan de vulnerabilidades final
- Semana 20: Correcao de findings, re-teste, aprovacao final de seguranca
- Gate: Sign-off de UAT, relatorio de pentest sem findings Critical/High

**Fase 6 - Go-Live (Semanas 21-24):**

- Semana 21: Rehearsal de cutover em ambiente PRE-PROD
- Semana 22: Preparacao de cutover (comunicacao, runbooks, equipe de plantao)
- Semana 23: **CUTOVER** - Migracao para producao (janela de 8 horas)
- Semana 24: Hypercare (suporte intensivo), monitoring 24/7, ajustes finos
- Gate: Operacao estavel por 5 dias consecutivos sem incidente P1/P2

**Fase 7 - Estabilizacao e Handover (Semanas 25-28):**

- Semana 25: Otimizacao de performance baseada em dados reais de producao
- Semana 26: Knowledge transfer para equipe de operacao (workshops + documentacao)
- Semana 27: Handover formal, transicao de suporte para equipe interna
- Semana 28: Retrospectiva do projeto, lessons learned, plano de evolucao
- Gate: Aceite formal do projeto pelo sponsor

### 14.3 Cronograma Gantt

```
Semana:     1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28
            ├──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┤
Fase 1      ████████████████
Fase 2                      ████████████████
Fase 3                                      ████████████████
Fase 4                                                      ████████████████
Fase 5                                                                      ████████████████
Fase 6                                                                                      ████████████████
Fase 7                                                                                                      ████████████████

Gates:            G1          G2              G3              G4              G5          G6              G7
                  │           │               │               │               │           │               │
                  ▼           ▼               ▼               ▼               ▼           ▼               ▼
              Arquitet.   Seguranca      Core OK         Compliance      UAT/Pentest  Go-Live        Aceite
```

---

## 15. Checklist de Go-Live

### 15.1 Infraestrutura

- [ ] Todos os servidores/nodes provisionados e com hardening CIS Level 2 aplicado
- [ ] Cluster Kubernetes operacional com auto-scaling configurado e testado
- [ ] Storage provisionado com IOPS suficiente (benchmark executado e aprovado)
- [ ] Rede configurada com micro-segmentacao e regras de firewall validadas
- [ ] Load balancers configurados com health checks e failover testado
- [ ] DNS configurado com failover automatico para site DR
- [ ] Certificados TLS instalados e com renovacao automatica configurada
- [ ] HSM operacional com chaves de producao geradas e backup realizado
- [ ] Site DR provisionado, replicacao ativa e failover testado
- [ ] Capacity planning validado para 12 meses de crescimento projetado

### 15.2 Seguranca

- [ ] Scan de vulnerabilidades executado: zero findings Critical e High
- [ ] Pentest externo concluido com relatorio aprovado pelo CISO
- [ ] WAF configurado com regras OWASP Top 10 ativas e testadas
- [ ] mTLS habilitado entre todos os componentes internos
- [ ] OAuth 2.0/OIDC integrado com IdP corporativo (LDAP/AD)
- [ ] MFA obrigatorio para todos os acessos administrativos
- [ ] Secrets armazenados em Vault/HSM com rotacao automatica configurada
- [ ] Falco/runtime protection ativo com alertas configurados
- [ ] Politicas de rede (NetworkPolicies) aplicadas e testadas
- [ ] Processo de gestao de vulnerabilidades documentado e operacional

### 15.3 Compliance

- [ ] Audit Trail operacional com hash chain verificado end-to-end
- [ ] Retencao de logs configurada conforme politica regulatoria (minimo 5 anos)
- [ ] Segregacao de funcoes (SoD) implementada e validada
- [ ] LGPD: Data Processing Agreement (DPA) assinado com fornecedores
- [ ] Resolucao BCB 4.893/2021: compliance validado para servicos em nuvem
- [ ] Relatorios de compliance gerados e revisados pelo Compliance Officer
- [ ] Politica de classificacao de dados aplicada a todos os repositorios
- [ ] Auditoria interna concluida com parecer favoravel

### 15.4 Integracoes

- [ ] Core banking: APIs integradas e testadas (happy path + error handling)
- [ ] LDAP/Active Directory: autenticacao e autorizacao validadas
- [ ] SIEM: logs de seguranca fluindo para o SOC
- [ ] ServiceNow/Jira: integracao de tickets e change management operacional
- [ ] E-mail/Slack/Teams: notificacoes configuradas e testadas
- [ ] Pipeline CI/CD: integrado com repositorio Git e registry de imagens
- [ ] Monitoring: metricas fluindo para Prometheus/Grafana
- [ ] Backup: jobs configurados e restore testado com sucesso

### 15.5 Performance

- [ ] Teste de carga executado: 1000 pipelines/dia sem degradacao
- [ ] Latencia P99 de API < 500ms sob carga normal
- [ ] Tempo de startup de agente < 30 segundos
- [ ] Failover automatico testado com RTO < 30 minutos
- [ ] Auto-scaling validado: scale-out em < 2 minutos sob pico
- [ ] Baseline de performance documentado para comparacao futura

### 15.6 Operacao

- [ ] Runbooks criados e revisados para todos os cenarios criticos (minimo 10)
- [ ] Equipe de plantao definida com escalas e contatos atualizados
- [ ] PagerDuty/OpsGenie configurado com politicas de escalonamento
- [ ] Dashboards de monitoring criados e revisados com equipe de operacao
- [ ] Processo de incident management documentado e simulado
- [ ] Processo de change management integrado ao CAB
- [ ] SLA de 99.95% configurado com alertas proativos
- [ ] Chaos engineering: pelo menos 3 cenarios de falha testados

### 15.7 Documentacao

- [ ] Manual de operacao completo e revisado
- [ ] Arquitetura documentada e aprovada pelo Comite de Arquitetura
- [ ] Runbooks publicados na wiki interna e acessiveis pela equipe de plantao
- [ ] Documentacao de API (Swagger/OpenAPI) publicada e atualizada
- [ ] Plano de DR documentado, testado e aprovado
- [ ] Knowledge base inicial criada com FAQs e troubleshooting

### 15.8 Aprovacoes

- [ ] Sign-off do Arquiteto Corporativo
- [ ] Sign-off do CISO (Chief Information Security Officer)
- [ ] Sign-off do Compliance Officer
- [ ] Sign-off do Sponsor do Projeto / Diretor de Tecnologia
- [ ] Sign-off do CAB (Change Advisory Board) para deploy em producao
- [ ] Sign-off do Business Owner (aceitacao funcional - UAT)

---

## 16. Contatos e Suporte

### 16.1 Matriz de Escalonamento

```
┌─────────────────────────────────────────────────────────────────────────┐
│                      MATRIZ DE ESCALONAMENTO                          │
├─────────┬──────────────────┬─────────────┬──────────────────────────────┤
│ Nivel   │ Responsavel      │ SLA         │ Escopo                      │
├─────────┼──────────────────┼─────────────┼──────────────────────────────┤
│ L1      │ Service Desk     │ 15 min      │ Triagem, troubleshooting    │
│         │                  │ (resposta)  │ basico, runbook execution   │
├─────────┼──────────────────┼─────────────┼──────────────────────────────┤
│ L2      │ Operacao         │ 30 min      │ Diagnostico avancado,       │
│         │ ForgeSquad       │ (resposta)  │ restart de servicos,        │
│         │                  │             │ failover manual             │
├─────────┼──────────────────┼─────────────┼──────────────────────────────┤
│ L3      │ Engenharia       │ 1 hora      │ Analise de causa raiz,      │
│         │ ForgeSquad       │ (resposta)  │ patches, mudancas de        │
│         │                  │             │ configuracao complexas      │
├─────────┼──────────────────┼─────────────┼──────────────────────────────┤
│ L4      │ Engineering      │ 2 horas     │ Bugs de produto, features   │
│         │ (Vendor)         │ (resposta)  │ emergenciais, escalacao     │
│         │                  │             │ final                       │
└─────────┴──────────────────┴─────────────┴──────────────────────────────┘
```

### 16.2 Niveis de Suporte e SLAs

| Nivel de Suporte | Horario | Canais | SLA Resposta | SLA Resolucao |
|-----------------|---------|--------|-------------|---------------|
| **Premium 24/7** | 24x7x365 | Telefone, Chat, E-mail, Portal | P1: 15min, P2: 30min | P1: 1h, P2: 4h |
| **Business Hours** | Seg-Sex 08:00-20:00 | Chat, E-mail, Portal | P1: 30min, P2: 1h | P1: 4h, P2: 8h |
| **Standard** | Seg-Sex 09:00-18:00 | E-mail, Portal | P1: 1h, P2: 4h | P1: 8h, P2: 24h |

> **Recomendacao para ambiente bancario:** Contrato **Premium 24/7** obrigatorio para ambientes de producao.

### 16.3 Canais de Comunicacao

| Canal | Uso | Acesso |
|-------|-----|--------|
| **War Room (Teams/Slack)** | Incidentes P1/P2 em andamento | Equipe de plantao + gestao |
| **Canal #forgesquad-ops** | Comunicacao operacional diaria | Equipe de operacao |
| **Canal #forgesquad-alerts** | Alertas automaticos do monitoring | Equipe de operacao + on-call |
| **E-mail forgesquad-support@** | Solicitacoes formais, RFCs | Todos os stakeholders |
| **Portal de Suporte** | Tickets, knowledge base, status page | Todos os usuarios |
| **Bridge telefonica** | War room para incidentes P1 | On-call + gestao |

### 16.4 Template de Contatos de Emergencia

| Funcao | Nome | Telefone | E-mail | Horario |
|--------|------|----------|--------|---------|
| On-call Engineer (primario) | _____________ | _____________ | _____________ | Conforme escala |
| On-call Engineer (backup) | _____________ | _____________ | _____________ | Conforme escala |
| Incident Commander | _____________ | _____________ | _____________ | 24/7 |
| DBA de Plantao | _____________ | _____________ | _____________ | Conforme escala |
| Security Officer de Plantao | _____________ | _____________ | _____________ | 24/7 |
| Gerente de Operacoes | _____________ | _____________ | _____________ | Horario comercial |
| CISO | _____________ | _____________ | _____________ | Escalonamento P1 |
| VP de Tecnologia | _____________ | _____________ | _____________ | Escalonamento P1 |
| Suporte ForgeSquad (Vendor) | N/A | +55 (11) XXXX-XXXX | support@forgesquad.io | 24/7 |
| Suporte Cloud (AWS/Azure) | N/A | Via console | enterprise-support@ | 24/7 (Enterprise) |

### 16.5 Procedimento de Acionamento

```
FLUXO DE ACIONAMENTO DE SUPORTE:

1. IDENTIFICACAO DO INCIDENTE
   └─> Automatico (alerta) ou Manual (usuario reporta)

2. CLASSIFICACAO (L1 - Service Desk)
   ├─> P1/P2: Acionar War Room imediatamente
   └─> P3/P4: Criar ticket e seguir fluxo normal

3. ESCALONAMENTO (se necessario)
   ├─> L1 → L2: Apos 15 min sem resolucao ou se fora do escopo
   ├─> L2 → L3: Apos 30 min sem resolucao ou se requer mudanca
   ├─> L3 → L4: Apos 1 hora sem resolucao ou se bug de produto
   └─> Gestao: P1 automaticamente notifica Gerente + CISO

4. RESOLUCAO E FECHAMENTO
   ├─> Documentar causa raiz e resolucao no ticket
   ├─> Atualizar runbook se aplicavel
   └─> Post-mortem obrigatorio para P1/P2 em ate 48 horas
```

---

> **Documento gerado pelo ForgeSquad** | Versao 1.0 | Data: Marco 2026
>
> Este manual deve ser revisado e atualizado a cada 6 meses ou sempre que houver mudanca significativa na arquitetura, regulacao ou operacao do ambiente.
>
> **Classificacao:** Confidencial - Uso Interno
>
> **Aprovacoes necessarias antes da implantacao:**
> - Comite de Arquitetura
> - CISO (Chief Information Security Officer)
> - Compliance Officer
> - Sponsor do Projeto
