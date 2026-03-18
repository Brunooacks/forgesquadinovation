---
step: "01"
name: "Briefing do Projeto"
type: checkpoint
depends_on: null
phase: requirements
---

# Step 01: Checkpoint — Briefing do Projeto

## Para o Pipeline Runner

Este e o primeiro passo da pipeline. Solicite ao usuario as informacoes do projeto
antes de qualquer trabalho dos agentes. Nenhum agente deve ser acionado ate que
o briefing esteja completo e confirmado.

### Perguntas a fazer ao usuario:

1. **Nome do Projeto** — Qual o nome do projeto ou produto?
2. **Descricao** — Descreva em alto nivel o que o sistema deve fazer.
3. **Objetivos de Negocio** — Quais problemas este projeto resolve? Quais KPIs serao impactados?
4. **Publico-alvo** — Quem sao os usuarios finais?
5. **Restricoes** — Orcamento, prazo, regulamentacoes, tecnologias obrigatorias ou proibidas.
6. **Preferencias Tecnologicas** — Linguagens, frameworks, cloud provider, banco de dados preferido.
7. **Integrações** — Sistemas externos com os quais o projeto deve se integrar.
8. **Requisitos Nao-Funcionais** — Performance esperada, disponibilidade, seguranca, escalabilidade.
9. **Contexto Adicional** — Links, documentos, diagramas, ou qualquer referencia relevante.

### Comportamento do Checkpoint:

- Apresente as perguntas ao usuario de forma conversacional.
- Permita que o usuario responda de forma parcial e complete iterativamente.
- Quando todas as informacoes essenciais (1-6) estiverem coletadas, apresente um resumo.
- Solicite confirmacao explicita: "O briefing esta correto? Posso prosseguir?"
- Somente apos confirmacao, gere o artefato e avance para o proximo step.

## Inputs para este Step

- Nenhum (este e o ponto de entrada da pipeline).

## Expected Outputs

| Artefato | Caminho | Descricao |
|----------|---------|-----------|
| Project Brief | `output/requirements/project-brief.md` | Documento estruturado com todas as informacoes coletadas do briefing |

### Estrutura do project-brief.md:

```markdown
# Project Brief: [Nome do Projeto]

## Visao Geral
[Descricao do projeto]

## Objetivos de Negocio
- [Objetivo 1]
- [Objetivo 2]

## Publico-Alvo
[Descricao dos usuarios]

## Restricoes
- Prazo: [prazo]
- Orcamento: [orcamento]
- Regulamentacoes: [regulamentacoes]

## Stack Tecnologica Preferida
- Linguagem: [linguagem]
- Framework: [framework]
- Cloud: [provider]
- Banco de Dados: [banco]

## Integracoes
- [Sistema 1]
- [Sistema 2]

## Requisitos Nao-Funcionais
- Performance: [meta]
- Disponibilidade: [SLA]
- Seguranca: [requisitos]

## Contexto Adicional
[Links e referencias]
```

## Execution Mode

- **Modo:** Interativo (checkpoint humano)
- **Agente:** Nenhum — interacao direta com o usuario
- **Skills:** Nenhuma

## Quality Gate

Antes de avancar para o Step 02, verifique:

- [ ] Nome do projeto definido
- [ ] Descricao do sistema fornecida
- [ ] Objetivos de negocio claros
- [ ] Publico-alvo identificado
- [ ] Restricoes documentadas
- [ ] Preferencias tecnologicas registradas
- [ ] Arquivo `project-brief.md` gerado
- [ ] Usuario confirmou o briefing explicitamente
