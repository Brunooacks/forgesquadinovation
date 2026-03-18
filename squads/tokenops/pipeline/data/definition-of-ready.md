# Definition of Ready (DoR) — TokenOps

Uma user story so entra em sprint quando TODOS os criterios abaixo sao atendidos:

## Requisitos
- [ ] User story escrita no formato "As a... I want... So that..."
- [ ] Criterios de aceite definidos no formato Given/When/Then
- [ ] Requisitos nao-funcionais identificados (performance, seguranca, multi-tenancy)
- [ ] Dependencias mapeadas e resolvidas (ou plano de resolucao)
- [ ] Impacto em consumo de tokens e custos estimado (se aplicavel)
- [ ] LLM providers afetados identificados (OpenAI, Anthropic, Google, etc.)

## Design
- [ ] Wireframe ou mockup aprovado pelo stakeholder (se componente de dashboard)
- [ ] Arquitetura definida e validada pelo Arquiteto
- [ ] Contratos de API definidos (OpenAPI spec draft)
- [ ] Modelo de dados revisado (PostgreSQL, ClickHouse ou Redis conforme o caso)
- [ ] Fluxo de eventos definido (se envolve pipeline de analytics ou remediation)
- [ ] Integracao com LLM providers mapeada (se envolve gateway proxy)

## Seguranca e Multi-Tenancy
- [ ] Requisitos de isolamento de dados por organizacao definidos
- [ ] Permissoes RBAC necessarias identificadas (owner, admin, member, viewer)
- [ ] Dados sensiveis identificados e plano de criptografia definido
- [ ] Rate limiting requirements definidos (se endpoint publico ou gateway)

## Estimativa
- [ ] Story estimada pelo time (story points ou T-shirt sizing)
- [ ] Complexidade compreendida por pelo menos 2 membros do time
- [ ] Riscos tecnicos identificados (ex: limites de API de providers, performance de ClickHouse)
- [ ] Spike necessario ja realizado (se complexidade alta ou tecnologia nova)

## Testabilidade
- [ ] Criterios de aceite sao testaveis automaticamente
- [ ] Cenarios de teste de alto nivel definidos pelo QA
- [ ] Dados de teste identificados ou planejados (fixtures de prompts, mock responses)
- [ ] Estrategia de teste de performance definida (se modulo critico: gateway, estimator)

## Observabilidade
- [ ] Metricas e traces necessarios identificados
- [ ] SLOs aplicaveis ao feature definidos
- [ ] Alertas necessarios listados
