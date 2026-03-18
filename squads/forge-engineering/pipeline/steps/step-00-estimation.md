---
step: "00"
name: "Estimativa de Projeto — Análise de Complexidade"
type: checkpoint
depends_on: null
phase: estimation
execution: inline
---

# Step 00: Estimativa de Projeto

## Para o Pipeline Runner

Antes de iniciar o pipeline, o sistema analisa a demanda do usuário e gera uma
estimativa completa de esforço, custo e tempo. Apresenta duas opções de execução
para o usuário escolher antes de prosseguir.

### Instruções

1. **Analisar a demanda** do usuário (briefing inicial ou descrição do projeto)

2. **Classificar complexidade** em 4 dimensões:

   | Dimensão | Peso | Critérios |
   |----------|------|-----------|
   | **Escopo funcional** | 30% | Número de features, integrações, entidades |
   | **Complexidade técnica** | 25% | Stack, arquitetura, infra, segurança |
   | **Compliance/Regulatório** | 25% | Bacen, BIAN, PCI DSS, LGPD, Open Finance |
   | **Domínio de negócio** | 20% | Conhecimento específico necessário |

   **Escala:**
   - **Baixa** (1-3): Projeto simples, poucas features, stack conhecida
   - **Média** (4-6): Projeto moderado, integrações, regulação parcial
   - **Alta** (7-9): Projeto complexo, multi-serviço, regulação pesada
   - **Crítica** (10): Projeto mission-critical, full compliance, alta disponibilidade

3. **Calcular esforço por agente** usando a tabela de referência:

   | Agente | Complexidade Baixa | Média | Alta | Crítica |
   |--------|-------------------|-------|------|---------|
   | Architect (Sofia) | 2h | 5h | 10h | 16h |
   | Tech Lead (Rafael) | 1h | 3h | 6h | 10h |
   | Business Analyst (Clara) | 2h | 4h | 8h | 12h |
   | Finance Advisor (Ricardo) | 0h | 2h | 6h | 10h |
   | Dev Backend (Bruno) | 4h | 10h | 24h | 40h |
   | Dev Frontend (Fernanda) | 3h | 8h | 20h | 32h |
   | QA Engineer (Quésia) | 2h | 5h | 12h | 20h |
   | Tech Writer (Daniela) | 1h | 3h | 6h | 10h |
   | Project Manager (Pedro) | 1h | 2h | 4h | 6h |

4. **Calcular custo em tokens** (referência por modelo):

   | Modelo | Input (1K tokens) | Output (1K tokens) | Velocidade |
   |--------|-------------------|---------------------|------------|
   | Claude Opus (tier-1) | $0.015 | $0.075 | ~30 tok/s |
   | Claude Sonnet (tier-2) | $0.003 | $0.015 | ~80 tok/s |
   | Claude Haiku (tier-3) | $0.00025 | $0.00125 | ~150 tok/s |
   | GPT-4o | $0.005 | $0.015 | ~60 tok/s |
   | GPT-4o-mini | $0.00015 | $0.0006 | ~120 tok/s |

   **Estimativa de tokens por tipo de tarefa:**
   | Tarefa | Input médio | Output médio |
   |--------|-------------|--------------|
   | Análise de requisitos | ~5K | ~8K |
   | Design de arquitetura | ~8K | ~15K |
   | Parecer regulatório | ~10K | ~12K |
   | Implementação (por feature) | ~3K | ~10K |
   | Testes automatizados | ~4K | ~8K |
   | Code review | ~8K | ~5K |
   | Documentação | ~5K | ~10K |
   | Relatório PM | ~3K | ~5K |

5. **Gerar duas opções de execução:**

   ### Opção A: Quality-First (Mais caro, mais rápido e preciso)
   - **Modelo:** Todos os agentes em `tier-1` (Claude Opus / GPT-4o)
   - **Pipeline:** Completo (todos os 23 steps incluindo revisões e pareceres financeiros)
   - **Subagents:** Execução paralela onde possível
   - **Vantagens:** Máxima qualidade, menos ciclos de review, output mais robusto
   - **Desvantagens:** Custo mais alto em tokens

   ### Opção B: Cost-Optimized (Mais barato, mais longo)
   - **Modelo:** Agentes críticos em `tier-1`, demais em `tier-2/3`
     - Opus: Architect, Finance Advisor (decisões críticas)
     - Sonnet: Tech Lead, BA, QA, Devs (execução)
     - Haiku: Tech Writer, PM (documentação, relatórios)
   - **Pipeline:** Otimizado (steps opcionais podem ser pulados)
   - **Subagents:** Execução sequencial
   - **Vantagens:** Custo 60-70% menor
   - **Desvantagens:** Mais ciclos de review, output pode precisar refinamento

6. **Apresentar o resumo ao usuário:**

   ```
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   📊 ESTIMATIVA DE PROJETO — ForgeSquad
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

   📋 Projeto: {nome do projeto}
   🎯 Complexidade: {classificação} ({score}/10)

   ┌─────────────────────────────────────────┐
   │  ANÁLISE DE COMPLEXIDADE                │
   │                                         │
   │  Escopo funcional:    ████████░░  8/10   │
   │  Complexidade técnica:██████░░░░  6/10   │
   │  Compliance/Regulat.: ████████░░  8/10   │
   │  Domínio de negócio:  ██████░░░░  6/10   │
   │                                         │
   │  Score médio ponderado: 7.2/10 (ALTA)   │
   └─────────────────────────────────────────┘

   👥 ESFORÇO POR AGENTE
   ┌──────────────┬──────────┬──────────────┐
   │ Agente       │ Horas    │ Participação │
   ├──────────────┼──────────┼──────────────┤
   │ 🏗️ Sofia     │ 10h      │ ████████░░   │
   │ 📋 Rafael    │ 6h       │ █████░░░░░   │
   │ 📊 Clara     │ 8h       │ ██████░░░░   │
   │ 🏦 Ricardo   │ 6h       │ █████░░░░░   │
   │ 🔧 Bruno     │ 24h      │ ██████████   │
   │ 🎨 Fernanda  │ 20h      │ █████████░   │
   │ 🔍 Quésia    │ 12h      │ ███████░░░   │
   │ 📝 Daniela   │ 6h       │ █████░░░░░   │
   │ 📈 Pedro     │ 4h       │ ███░░░░░░░   │
   ├──────────────┼──────────┼──────────────┤
   │ TOTAL        │ 96h      │              │
   └──────────────┴──────────┴──────────────┘

   💰 OPÇÕES DE EXECUÇÃO

   ┌─ OPÇÃO A: Quality-First ─────────────────┐
   │ 🏆 Todos os agentes em modelo tier-1      │
   │ ⏱️  Tempo estimado: ~45 min               │
   │ 🪙  Custo estimado: ~$12.50 em tokens     │
   │ 📊 Tokens: ~180K input + ~250K output     │
   │ ✅ 23 steps completos                     │
   │ ⚡ Execução paralela                      │
   └───────────────────────────────────────────┘

   ┌─ OPÇÃO B: Cost-Optimized ────────────────┐
   │ 💰 Mix de modelos (Opus/Sonnet/Haiku)     │
   │ ⏱️  Tempo estimado: ~90 min               │
   │ 🪙  Custo estimado: ~$4.20 em tokens      │
   │ 📊 Tokens: ~180K input + ~250K output     │
   │ ✅ 20 steps (3 opcionais pulados)         │
   │ 🔄 Execução sequencial                   │
   └───────────────────────────────────────────┘

   Qual opção deseja seguir? [A/B]
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   ```

7. **Salvar a escolha do usuário** e configurar o pipeline:
   - Se **Opção A**: manter config.yaml padrão (todos powerful)
   - Se **Opção B**: criar config override com mix de tiers
   - Salvar estimativa em `output/estimation/project-estimation.md`

### Regras:

- NUNCA pular a estimativa — é o primeiro step do pipeline
- Apresentar SEMPRE as duas opções — o usuário decide
- Se o usuário pedir uma opção intermediária, calcular o mix personalizado
- Salvar a escolha para rastreabilidade no relatório final do PM

## Expected Outputs

| Artefato | Caminho | Descrição |
|----------|---------|-----------|
| Estimativa do Projeto | `output/estimation/project-estimation.md` | Análise completa de complexidade e custo |
| Config Override | `output/estimation/config-override.yaml` | Configuração de tiers se Opção B |

## Quality Gate

- [ ] Complexidade classificada nas 4 dimensões
- [ ] Esforço calculado por agente
- [ ] Custo em tokens estimado para ambas opções
- [ ] Opções A e B apresentadas ao usuário
- [ ] Escolha do usuário registrada
