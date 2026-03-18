---
step: "13"
name: "Testes de Performance"
type: agent
agent: qa-engineer
tasks:
  - performance-test
depends_on: step-12
phase: quality
optional: true
---

# Step 13: QA Engineer — Testes de Performance (Opcional)

## Para o Pipeline Runner

Acione o agente `qa-engineer` com a task `performance-test`. Este step e OPCIONAL
e deve ser executado quando o projeto tem requisitos de performance explícitos
ou quando a arquitetura envolve cenarios de alta carga.

### Condicoes para Execucao:

- Projeto tem SLAs de performance definidos no briefing.
- Arquitetura envolve componentes de alta carga.
- Requisitos nao-funcionais mencionam performance, escalabilidade ou throughput.
- Se nenhuma dessas condicoes se aplica, pule para o Step 14.

### Instrucoes para o Agente:

1. **Leia** os requisitos nao-funcionais e a estrategia de testes.
2. **Configure** o ambiente de testes de performance:
   - Ambiente o mais proximo possivel de producao.
   - Ferramentas de load testing configuradas.
   - Monitoramento de recursos ativo (CPU, memoria, rede, disco).
3. **Execute** cenarios de teste:
   - **Teste de carga (Load Test):** Simule carga esperada em producao.
   - **Teste de estresse (Stress Test):** Aumente carga alem do esperado ate falha.
   - **Teste de endurance (Soak Test):** Carga constante por periodo prolongado.
   - **Teste de pico (Spike Test):** Picos subitos de carga.
4. **Analise** resultados:
   - Tempo de resposta (p50, p95, p99).
   - Throughput (requests por segundo).
   - Taxa de erros sob carga.
   - Uso de recursos (CPU, memoria, conexoes).
   - Identificacao de gargalos.
5. **Recomende** otimizacoes:
   - Queries lentas.
   - Memory leaks.
   - Connection pool tuning.
   - Cache strategies.

### Ferramentas Recomendadas:

- k6 para testes de carga HTTP.
- Artillery para cenarios complexos.
- Grafana + Prometheus para monitoramento.

### Regras:

- Testes de performance devem ser executados em ambiente isolado.
- Resultados devem ser comparaveis entre execucoes (baseline).
- Gargalos criticos devem ser reportados com prioridade alta.

## Inputs para este Step

| Artefato | Caminho | Descricao |
|----------|---------|-----------|
| Test Strategy | `output/planning/test-strategy.md` | Thresholds de performance |
| Architecture Design | `output/architecture/architecture-design.md` | Endpoints e componentes criticos |
| Backend Code | `output/implementation/backend/` | APIs a serem testadas |
| Project Brief | `output/requirements/project-brief.md` | SLAs e requisitos nao-funcionais |

## Expected Outputs

| Artefato | Caminho | Descricao |
|----------|---------|-----------|
| Performance Report | `output/quality/performance-report.md` | Relatorio detalhado de performance |
| Test Scripts | `output/quality/performance-tests/` | Scripts de teste de carga |

### Estrutura do performance-report.md:

```markdown
# Relatorio de Performance — [Nome do Projeto]

## Resumo Executivo
- **Status geral:** APROVADO / REPROVADO
- **Gargalos encontrados:** [N]
- **Otimizacoes recomendadas:** [N]

## Ambiente de Teste
[Especificacoes do ambiente]

## Resultados por Cenario

### Load Test
| Metrica | Meta | Resultado | Status |
|---------|------|-----------|--------|
| p50 Response Time | <200ms | [X]ms | OK/NOK |
| p95 Response Time | <500ms | [X]ms | OK/NOK |
| p99 Response Time | <1000ms | [X]ms | OK/NOK |
| Throughput | >100 rps | [X] rps | OK/NOK |
| Error Rate | <1% | [X%] | OK/NOK |

### Stress Test
[Resultados e ponto de ruptura]

### Soak Test
[Resultados e estabilidade]

## Gargalos Identificados
[Lista com evidencias]

## Recomendacoes de Otimizacao
[Lista priorizada]
```

## Execution Mode

- **Modo:** Subagent
- **Agente:** `qa-engineer`
- **Skills:** `performance-test`
- **Timeout:** 45 minutos
- **Retries:** 1

## Quality Gate

Antes de avancar para o Step 14, verifique:

- [ ] Cenarios de carga executados com sucesso
- [ ] Metricas de performance dentro dos SLAs (ou justificativa)
- [ ] Gargalos documentados
- [ ] Recomendacoes de otimizacao priorizadas
- [ ] Relatorio de performance gerado
- [ ] Scripts de teste versionados para reexecucao
