# Definition of Ready — TokenOps Platform

Uma story so pode entrar na sprint quando TODOS os criterios abaixo forem atendidos.

## Checklist

### User Story
- [ ] User story segue o formato: "Como [persona], eu quero [acao] para que [beneficio]"
- [ ] Persona identificada (DevOps Engineer, Engineering Manager, Platform Admin, Finance Lead)
- [ ] Story tem titulo claro e descritivo

### Criterios de Aceitacao
- [ ] Criterios de aceitacao definidos no formato Given/When/Then
- [ ] Cenarios de sucesso e erro cobertos
- [ ] Pelo menos 2 criterios de aceitacao por story

### Priorizacao
- [ ] Story priorizada usando MoSCoW (Must, Should, Could, Won't)
- [ ] Prioridade alinhada com o roadmap do produto
- [ ] Product Owner confirmou a prioridade

### Dependencias
- [ ] Dependencias identificadas (outras stories, APIs externas, infra)
- [ ] Dependencias resolvidas ou rastreadas com data prevista
- [ ] Nenhuma dependencia bloqueante sem plano de resolucao

### Requisitos Tecnicos
- [ ] Modulo/bounded context identificado (Gateway, Estimator, Recommender, Dashboard, Platform)
- [ ] Endpoints de API definidos (metodo, path, request/response schema)
- [ ] Modelo de dados identificado (tabelas, colunas, relacoes)
- [ ] Integracoes externas mapeadas (quais LLM providers, quais APIs)

### Requisitos Nao-Funcionais (quando aplicavel)
- [ ] Latencia maxima definida (ex: Gateway proxy < 50ms p95)
- [ ] Throughput esperado definido (ex: 10k req/s)
- [ ] Requisitos de acuracia definidos (ex: estimativa de tokens com erro < 5%)
- [ ] Requisitos de disponibilidade (ex: 99.9% uptime para Gateway)

### Design e UX (para stories de frontend)
- [ ] Mockup ou wireframe disponivel (Figma)
- [ ] Estados de UI definidos (loading, empty, error, success)
- [ ] Responsividade especificada (mobile, tablet, desktop)
- [ ] Dark mode considerado
- [ ] Acessibilidade verificada (WCAG 2.1 AA)

### Estimativa
- [ ] Story estimada em story points (Fibonacci: 1, 2, 3, 5, 8, 13)
- [ ] Stories > 8 pontos foram quebradas em stories menores
- [ ] Time estimou coletivamente (Planning Poker ou similar)

### Validacao
- [ ] Nao bloqueada por outras stories
- [ ] Revisada pelo BA (requisitos claros e completos)
- [ ] Revisada pelo Tech Lead (viabilidade tecnica confirmada)
- [ ] Architect consultado se envolve decisao arquitetural

## Exemplo de Story Pronta

```
Titulo: Estimativa de custo antes da execucao

Como Engineering Manager,
eu quero ver a estimativa de custo antes de executar um prompt via API
para que eu possa controlar o orcamento do meu time.

Criterios de Aceitacao:
- Given um prompt valido e modelo selecionado
  When eu chamo POST /api/v1/estimations
  Then recebo { inputTokens, outputTokens, estimatedCost, currency, model }

- Given um prompt vazio
  When eu chamo POST /api/v1/estimations
  Then recebo 400 Bad Request com mensagem de validacao

- Given um modelo nao suportado
  When eu chamo POST /api/v1/estimations
  Then recebo 422 Unprocessable Entity com lista de modelos disponiveis

Priorizacao: Must Have
Modulo: Estimator
Pontos: 5
Dependencias: Pricing models configurados para OpenAI e Anthropic
NFR: Latencia p95 < 30ms
```

## Notas

- Stories que nao atendem a todos os criterios devem voltar para refinamento
- O BA e responsavel por garantir que a story esta pronta antes da Planning
- O Tech Lead valida a viabilidade tecnica e estima complexidade
- Stories de infraestrutura podem ter criterios adaptados (sem mockup, por exemplo)
