---
step: "05b"
name: "Validação Regulatória da Arquitetura"
type: agent
agent: finance-advisor
depends_on: step-05
phase: architecture
execution: inline
best_practice: regulatory-compliance
---

# Step 05b: Validação Regulatória da Arquitetura

## Para o Pipeline Runner

Após a revisão arquitetural, o **FIN Ricardo Regulação** valida a arquitetura
proposta sob a ótica de compliance regulatório do setor financeiro, verificando
se as decisões técnicas atendem aos requisitos de Bacen, BIAN, PCI DSS e demais
normas aplicáveis.

### Instruções para o Agente

1. **Carregue o contexto:**
   - Leia o design de arquitetura em `output/architecture/architecture-design.md`
   - Leia os ADRs em `output/architecture/adrs/`
   - Leia o parecer financeiro anterior em `output/requirements/financial-business-review.md`
   - Leia os requisitos regulatórios em `output/requirements/regulatory-requirements.md`

2. **Validação de Segurança e Compliance Arquitetural:**
   - **Dados sensíveis:** A arquitetura prevê criptografia em trânsito (TLS 1.2+) e em repouso (AES-256)?
   - **Segregação:** Ambientes de dados PCI estão isolados? Dados de cartão em vault dedicado?
   - **Autenticação:** OAuth 2.0/OIDC previsto? Para Open Finance: FAPI + MTLS?
   - **Auditoria:** Existe componente de audit trail imutável? Event sourcing ou append-only log?
   - **Resiliência:** Circuit breakers, retry com backoff, fallback para operações críticas (SPB/Pix)?
   - **Multi-tenancy:** Se BaaS, dados de tenants estão isolados (schema/database level)?

3. **Validação BIAN:**
   - A arquitetura de domínios está alinhada ao BIAN Service Landscape?
   - Os bounded contexts correspondem a BIAN Service Domains?
   - As APIs seguem a nomenclatura BIAN (Initiate, Execute, Request, Retrieve)?
   - Existe separação clara entre Business Areas (Sales, Operations, Risk, Support)?

4. **Validação Bacen / Regulatória:**
   - **CMN 4.893:** Política de segurança cibernética endereçada na arquitetura?
   - **CMN 4.658:** Se usa cloud, os requisitos de contratação estão previstos?
   - **BCB 80:** Se Open Finance, a arquitetura atende as specs de API e consentimento?
   - **BCB 199:** Se Pix, integração com SPI/DICT está prevista corretamente?
   - **Circular 3.978:** Mecanismos de PLD/FT estão previstos (monitoramento de transações)?
   - **Basel III/IV:** Se precifica risco, os modelos seguem as abordagens padronizadas?

5. **Emita o Parecer Arquitetural Financeiro:**
   - Use o formato padronizado
   - Destaque gaps de compliance na arquitetura
   - Proponha ajustes arquiteturais específicos
   - Classifique criticidade: Bloqueante / Alta / Média / Informativo

### Veto Conditions

- **VETO:** Arquitetura sem criptografia em trânsito para dados financeiros
- **VETO:** Ausência de trilha de auditoria imutável para operações financeiras
- **VETO:** Dados de cartão armazenados fora de ambiente PCI DSS isolado
- **VETO:** APIs Open Finance sem FAPI/MTLS previsto
- **VETO:** Integração Pix sem aderência ao protocolo SPI do Bacen
- **VETO:** Ausência de mecanismo de PLD/FT para transações acima de limites regulatórios

## Inputs para este Step

| Artefato | Caminho | Descrição |
|----------|---------|-----------|
| Architecture Design | `output/architecture/architecture-design.md` | Design de arquitetura |
| ADRs | `output/architecture/adrs/` | Registros de decisão arquitetural |
| Parecer Financeiro (Req) | `output/requirements/financial-business-review.md` | Parecer anterior |
| Requisitos Regulatórios | `output/requirements/regulatory-requirements.md` | Requisitos regulatórios |

## Expected Outputs

| Artefato | Caminho | Descrição |
|----------|---------|-----------|
| Parecer Arquitetural Financeiro | `output/architecture/financial-architecture-review.md` | Parecer com análise regulatória da arquitetura |
| Compliance Matrix | `output/architecture/compliance-matrix.md` | Matriz de conformidade regulatória |

## Execution Mode

- **Modo:** Inline (agente fala diretamente no chat)
- **Agente:** FIN Ricardo Regulação
- **Skills:** web_search, web_fetch
- **Tier sugerido:** tier-1

## Quality Gate

- [ ] Todos os pontos de compliance arquitetural verificados
- [ ] BIAN alignment avaliado para domínios aplicáveis
- [ ] Regulações Bacen aplicáveis mapeadas e verificadas
- [ ] Parecer emitido com classificação de criticidade
- [ ] Compliance Matrix gerada
- [ ] Gaps bloqueantes comunicados ao Arquiteto para correção
