---
step: "03b"
name: "Parecer de Negócios — Setor Financeiro"
type: agent
agent: finance-advisor
depends_on: step-03
phase: requirements
execution: inline
best_practice: regulatory-compliance
---

# Step 03b: Parecer de Negócios do Setor Financeiro (Requisitos)

## Para o Pipeline Runner

Após a aprovação dos requisitos pelo usuário, o **FIN Ricardo Regulação** analisa
os requisitos sob a ótica de negócios do setor financeiro, verificando compliance
regulatório, viabilidade comercial e aderência a frameworks do mercado.

### Instruções para o Agente

1. **Carregue o contexto financeiro:**
   - Leia os requisitos aprovados em `output/requirements/user-stories.md`
   - Leia os critérios de aceite em `output/requirements/acceptance-criteria.md`
   - Considere o contexto da empresa em `_forgesquad/_memory/company.md`

2. **Análise Regulatória dos Requisitos:**
   - Identifique quais requisitos tocam dados financeiros, dados pessoais ou transações
   - Mapeie regulações aplicáveis do Bacen (resoluções, circulares)
   - Verifique aderência ao BIAN Service Landscape para domínios bancários
   - Avalie requisitos de PLD/FT (Prevenção à Lavagem de Dinheiro)
   - Verifique necessidade de adequação ao Open Finance Brasil
   - Avalie impacto de Pix, SPB, DREX se aplicável

3. **Análise de Viabilidade de Negócio:**
   - Avalie se os requisitos fazem sentido para o modelo de negócio (banco, fintech, IP, etc.)
   - Identifique riscos regulatórios que podem bloquear a implementação
   - Aponte oportunidades de mercado que os requisitos podem explorar
   - Verifique se há requisitos implícitos obrigatórios que estão faltando (ex: KYC, AML, trilha de auditoria)

4. **Emita o Parecer:**
   - Use o formato padronizado (APROVADO / APROVADO COM RESSALVAS / REPROVADO)
   - Preencha a tabela de análise regulatória
   - Liste recomendações de ajuste se necessário
   - Cite as normas/regulações específicas como referência

### Veto Conditions

- **VETO:** Requisitos que envolvem dados de cartão sem menção a PCI DSS
- **VETO:** Requisitos de transações financeiras sem trilha de auditoria
- **VETO:** Tratamento de dados pessoais sem base legal LGPD definida
- **VETO:** APIs financeiras expostas sem autenticação forte prevista
- **VETO:** Operações Pix sem aderência às specs do Bacen

## Inputs para este Step

| Artefato | Caminho | Descrição |
|----------|---------|-----------|
| User Stories | `output/requirements/user-stories.md` | User stories aprovadas |
| Acceptance Criteria | `output/requirements/acceptance-criteria.md` | Critérios de aceitação |
| Approval Record | `output/requirements/approval-record.md` | Registro de aprovação |

## Expected Outputs

| Artefato | Caminho | Descrição |
|----------|---------|-----------|
| Parecer Financeiro (Requisitos) | `output/requirements/financial-business-review.md` | Parecer completo com análise regulatória |
| Requisitos Regulatórios Adicionais | `output/requirements/regulatory-requirements.md` | Requisitos obrigatórios identificados |

## Execution Mode

- **Modo:** Inline (agente fala diretamente no chat)
- **Agente:** FIN Ricardo Regulação
- **Skills:** web_search, web_fetch
- **Tier sugerido:** tier-1 (análise complexa requer modelo de alta capacidade)

## Quality Gate

- [ ] Todas as regulações aplicáveis foram identificadas
- [ ] Checklist de compliance preenchido
- [ ] Parecer emitido com status claro (Aprovado/Ressalvas/Reprovado)
- [ ] Requisitos regulatórios adicionais documentados se necessário
- [ ] Referências normativas citadas
