---
step: "19b"
name: "Relatorio de Auditoria — Trilha de Auditoria Completa"
type: agent
agent: project-manager
tasks:
  - generate-audit-report
depends_on: step-19
phase: sustaining
best_practice: audit-trail
---

# Step 19b: Project Manager — Relatorio de Auditoria

## Para o Pipeline Runner

Acione o agente `project-manager` (PM Pedro Progress) com a task `generate-audit-report`.
Este step deve ser executado APOS o Step 19 (Relatorio Final) e ANTES do Step 20 (Encerramento).

O Project Manager deve ler o arquivo `audit-trail.json` completo do run atual e gerar
um relatorio de auditoria legivel em markdown, consolidando toda a trilha de auditoria
da pipeline.

### Referencia

Antes de executar, o Pipeline Runner deve carregar as instrucoes de auditoria:
- Ler `_forgesquad/core/audit-trail.md` para entender o schema e as regras
- Ler `squads/forge-engineering/pipeline/data/audit-template.json` para referencia do schema

### Instrucoes para o Agente:

1. **Leia** o arquivo completo de auditoria:
   ```
   squads/{name}/output/{run_id}/audit-trail.json
   ```

2. **Valide** a integridade da trilha de auditoria:
   - Verifique que `sequence_number` e consecutivo sem gaps
   - Verifique que `timestamp` e monotonicamente crescente
   - Verifique que todos os `related_entry_id` referenciam `entry_id` existentes
   - Verifique que cada arquivo em `output/` possui ao menos um `artifact_created`
   - Verifique que cada `artifact_created` possui um `artifact_approved` correspondente
   - Verifique que cada `veto_triggered` possui um `veto_resolved` correspondente
   - Verifique que cada `checkpoint_reached` possui `checkpoint_approved` ou `checkpoint_rejected`

3. **Compile** a timeline completa:
   - Liste todas as acoes em ordem cronologica
   - Agrupe por fase da pipeline
   - Inclua duracao de cada fase (diferenca entre primeiro e ultimo timestamp da fase)

4. **Construa** a cadeia de aprovacao de cada artefato:
   - Para cada artefato: criacao -> revisao -> aprovacao/rejeicao
   - Identifique quem criou, quem revisou, quem aprovou
   - Calcule tempo entre criacao e aprovacao

5. **Gere** estatisticas:
   - Total de artefatos criados
   - Total de artefatos aprovados vs. rejeitados (taxa de aprovacao)
   - Tempo medio entre criacao e aprovacao (average review time)
   - Total de checkpoints alcancados vs. aprovados
   - Total de vetos disparados vs. resolvidos
   - Total de handoffs realizados
   - Total de ciclos de revisao
   - Duracao total da pipeline

6. **Elabore** o resumo de conformidade:
   - Conformidade com Bacen CMN 4.893 (rastreabilidade de decisoes)
   - Conformidade com LGPD (rastreabilidade de tratamento de dados)
   - Conformidade com ISO/IEC 27001 (registros de auditoria)
   - Status de cada item de conformidade: Conforme / Nao Conforme / Nao Aplicavel

7. **Identifique** riscos e observacoes:
   - Artefatos sem aprovacao (risco alto)
   - Vetos nao resolvidos (bloqueante)
   - Gaps na sequencia de auditoria (risco de integridade)
   - Checkpoints rejeitados e seu impacto
   - Tempos de revisao acima da media (possivel gargalo)

## Inputs para este Step

| Artefato | Caminho | Descricao |
|----------|---------|-----------|
| Audit Trail | `output/{run_id}/audit-trail.json` | Trilha de auditoria completa do run |
| Final Report | `output/reports/final-report.md` | Relatorio final do PM (step 19) |
| State JSON | `state.json` | Estado atual da pipeline com metricas |

## Expected Outputs

| Artefato | Caminho | Descricao |
|----------|---------|-----------|
| Audit Report | `output/reports/audit-report.md` | Relatorio de auditoria completo |

### Estrutura do audit-report.md:

```markdown
# Relatorio de Auditoria — [Nome do Projeto]

**Run ID:** [run_id]
**Squad:** [squad name]
**Data de Geracao:** [timestamp]
**Gerado por:** PM Pedro Progress

---

## 1. Resumo Executivo

- **Status da Pipeline:** Concluida com Sucesso / Concluida com Ressalvas / Falha
- **Total de Acoes Registradas:** [N]
- **Integridade da Trilha:** Integra / Comprometida
- **Conformidade Geral:** Conforme / Nao Conforme

## 2. Estatisticas da Pipeline

| Metrica | Valor |
|---------|-------|
| Duracao total | [HH:MM:SS] |
| Total de entries no audit trail | [N] |
| Artefatos criados | [N] |
| Artefatos aprovados | [N] |
| Artefatos rejeitados | [N] |
| Taxa de aprovacao | [X%] |
| Tempo medio de revisao | [HH:MM:SS] |
| Checkpoints alcancados | [N] |
| Checkpoints aprovados | [N] |
| Checkpoints rejeitados | [N] |
| Vetos disparados | [N] |
| Vetos resolvidos | [N] |
| Handoffs realizados | [N] |
| Ciclos de revisao | [N] |

## 3. Timeline por Fase

### 3.1 Estimativa
| # | Timestamp | Agente | Acao | Artefato | Status |
|---|-----------|--------|------|----------|--------|
| 1 | [time] | [agent] | [action_type] | [path] | [status] |

**Duracao da fase:** [HH:MM:SS]

### 3.2 Requisitos
[mesma tabela]

### 3.3 Arquitetura
[mesma tabela]

[... demais fases ...]

## 4. Cadeia de Aprovacao por Artefato

### 4.1 [artifact_path]
| Etapa | Agente | Timestamp | Status |
|-------|--------|-----------|--------|
| Criacao | [creator] | [time] | Criado |
| Revisao | [reviewer] | [time] | Revisado |
| Aprovacao | [approver] | [time] | Aprovado |

**Tempo total de aprovacao:** [HH:MM:SS]
**Hash SHA-256:** [hash]

[... demais artefatos ...]

## 5. Checkpoints e Decisoes

| Checkpoint | Step | Decisao | Responsavel | Timestamp | Notas |
|-----------|------|---------|-------------|-----------|-------|
| [name] | [step_id] | Aprovado/Rejeitado | [reviewer] | [time] | [notes] |

## 6. Vetos e Resolucoes

| Veto | Agente | Condicao | Resolucao | Tempo de Resolucao |
|------|--------|----------|-----------|-------------------|
| [entry_id] | [agent] | [condition] | [resolution] | [HH:MM:SS] |

## 7. Validacao de Integridade

| Verificacao | Resultado | Detalhes |
|-------------|-----------|----------|
| Sequencia consecutiva | OK/FALHA | [detalhes] |
| Ordenacao temporal | OK/FALHA | [detalhes] |
| Integridade referencial | OK/FALHA | [detalhes] |
| Cobertura de artefatos | OK/FALHA | [detalhes] |
| Cobertura de aprovacoes | OK/FALHA | [artefatos sem aprovacao] |
| Resolucao de vetos | OK/FALHA | [vetos pendentes] |
| Completude de checkpoints | OK/FALHA | [checkpoints pendentes] |

## 8. Conformidade Regulatoria

### 8.1 Bacen CMN 4.893
| Requisito | Artigo | Status | Evidencia |
|-----------|--------|--------|-----------|
| Rastreabilidade de alteracoes | Art. 3, II | Conforme | audit-trail.json |
| Identificacao de responsaveis | Art. 7 | Conforme | Campos agent_id, reviewer |
| Retencao de registros (5 anos) | Art. 23 | Conforme | Politica de retencao aplicada |

### 8.2 LGPD (Lei 13.709/2018)
| Requisito | Artigo | Status | Evidencia |
|-----------|--------|--------|-----------|
| Prestacao de contas | Art. 6, X | Conforme | Trilha de auditoria completa |
| Registro de operacoes | Art. 37 | Conforme | Todas as operacoes registradas |
| Medidas de seguranca | Art. 46 | Conforme | Hashes SHA-256 para integridade |

### 8.3 ISO/IEC 27001
| Requisito | Controle | Status | Evidencia |
|-----------|----------|--------|-----------|
| Logging e monitoramento | A.12.4 | Conforme | Audit trail automatizado |
| Seguranca em desenvolvimento | A.14.2 | Conforme | Quality gates e vetos |

## 9. Riscos e Observacoes

### Riscos Identificados
| Risco | Severidade | Descricao | Recomendacao |
|-------|-----------|-----------|--------------|
| [risco] | Alta/Media/Baixa | [descricao] | [recomendacao] |

### Observacoes
- [observacao 1]
- [observacao 2]

## 10. Conclusao

[Parecer final do PM sobre a integridade e conformidade do processo de desenvolvimento,
incluindo recomendacoes para auditorias futuras.]

---

**Assinatura Digital**
- **Agente:** PM Pedro Progress
- **Timestamp:** [ISO 8601]
- **Hash do Relatorio:** [SHA-256 deste arquivo]
```

## Execution Mode

- **Modo:** Subagent
- **Agente:** `project-manager`
- **Persona:** PM Pedro Progress
- **Skills:** `generate-audit-report`
- **Timeout:** 45 minutos
- **Retries:** 1

## Quality Gate

Antes de avancar para o Step 20 (Encerramento), verifique:

- [ ] Arquivo `audit-trail.json` foi lido e parseado com sucesso
- [ ] Validacao de integridade executada (7 verificacoes)
- [ ] Todas as verificacoes de integridade passaram (ou riscos documentados)
- [ ] Todos os artefatos possuem ao menos uma aprovacao
- [ ] Nenhum veto nao resolvido permanece aberto
- [ ] Timeline completa de todas as fases gerada
- [ ] Cadeia de aprovacao de cada artefato documentada
- [ ] Resumo de conformidade com Bacen CMN 4.893 incluido
- [ ] Resumo de conformidade com LGPD incluido
- [ ] Resumo de conformidade com ISO/IEC 27001 incluido
- [ ] Estatisticas compiladas (total artefatos, taxa aprovacao, tempo medio revisao)
- [ ] Relatorio de auditoria salvo em `output/reports/audit-report.md`
- [ ] Hash SHA-256 do relatorio gerado e incluido na assinatura

## Veto Conditions

- **Artefato sem aprovacao**: Se qualquer artefato criado na pipeline nao possui um `artifact_approved` correspondente, o relatorio deve listar como risco ALTO e o step NAO pode ser marcado como concluido ate que o PM documente a justificativa.
- **Veto nao resolvido**: Se qualquer `veto_triggered` nao possui um `veto_resolved` correspondente, o relatorio DEVE ser marcado como "Concluida com Ressalvas" e o step NAO pode avancar sem aprovacao explicita do usuario.
- **Gap na sequencia**: Se houver gaps no `sequence_number`, a integridade da trilha e marcada como "Comprometida" e deve ser investigada antes do encerramento.

## Notas para o Pipeline Runner

1. Este step gera uma entrada `artifact_created` no proprio `audit-trail.json` para o `audit-report.md`.
2. Apos gerar o relatorio, compute o SHA-256 do arquivo e adicione a entrada ao audit trail.
3. Este e o ULTIMO step a adicionar entradas ao audit trail antes do `pipeline_completed`.
4. O Step 20 (Encerramento) deve referenciar este relatorio como evidencia de conformidade.
