# Architecture Guidelines

## Princípios
1. **Simplicidade**: A solução mais simples que resolve o problema é a melhor
2. **Separação de Concerns**: Cada módulo/serviço tem uma responsabilidade clara
3. **Loose Coupling**: Dependências explícitas e minimizadas entre componentes
4. **High Cohesion**: Funcionalidades relacionadas ficam juntas
5. **Fail Fast**: Erros são detectados e reportados o mais cedo possível

## Decisões Arquiteturais (ADRs)
- Toda decisão significativa gera um ADR
- ADRs são imutáveis — se a decisão mudar, cria-se um novo ADR que a supersede
- Formato: Contexto → Decisão → Consequências → Alternativas Consideradas

## Padrões de API
- REST para CRUD e operações simples
- GraphQL para queries complexas com múltiplas entidades
- gRPC para comunicação interna entre serviços
- Event-driven (pub/sub) para processos assíncronos

## Segurança
- Zero Trust: nunca confiar, sempre verificar
- Principle of Least Privilege para acessos
- Encryption at rest e in transit obrigatórios
- Secrets em vault (nunca em código ou env files commitados)

## Observabilidade
- Três pilares: Logs, Metrics, Traces
- Correlation ID em toda request chain
- Health check endpoints obrigatórios
- Alertas baseados em SLOs, não em thresholds arbitrários
