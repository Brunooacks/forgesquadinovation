#!/bin/bash
# ForgeSquad v2.0 — Instalador
# Uso: curl -sL https://raw.githubusercontent.com/Brunooacks/forgesquadinovation/main/install.sh | bash

set -e

REPO="https://github.com/Brunooacks/forgesquadinovation.git"
FORGE_DIR=".forgesquad-framework"

echo ""
echo "  ╔══════════════════════════════════════╗"
echo "  ║     ForgeSquad v2.0 — Prometheus     ║"
echo "  ║   AI-Augmented Engineering Framework ║"
echo "  ╚══════════════════════════════════════╝"
echo ""

# Check if claude is installed
if ! command -v claude &> /dev/null; then
  echo "  [!] Claude Code nao encontrado."
  echo "      Instale com: npm install -g @anthropic-ai/claude-code"
  echo ""
  exit 1
fi

# Check if already installed
if [ -d "$FORGE_DIR" ]; then
  echo "  [*] ForgeSquad ja instalado. Atualizando..."
  cd "$FORGE_DIR" && git pull --quiet && cd ..
else
  echo "  [1/3] Baixando ForgeSquad..."
  git clone --quiet --depth 1 "$REPO" "$FORGE_DIR"
fi

# Copy essentials to project root
echo "  [2/3] Configurando projeto..."

# CLAUDE.md — instructions for the AI
cp "$FORGE_DIR/CLAUDE.md" ./CLAUDE.md 2>/dev/null || true

# .claude/commands — slash commands
mkdir -p .claude/commands
cp "$FORGE_DIR/.claude/commands/"*.md .claude/commands/ 2>/dev/null || true

# Create symlinks for core framework files (so commands can find them)
if [ ! -L "_forgesquad" ]; then
  ln -sf "$FORGE_DIR/_forgesquad" _forgesquad
fi
if [ ! -L "squads" ]; then
  ln -sf "$FORGE_DIR/squads" squads
fi
if [ ! -L "skills" ]; then
  ln -sf "$FORGE_DIR/skills" skills
fi

echo "  [3/3] Pronto!"
echo ""
echo "  ✔ ForgeSquad instalado com sucesso"
echo ""
echo "  Para comecar:"
echo "    claude"
echo "    /forgesquad"
echo ""
echo "  Comandos disponiveis:"
echo "    /forgesquad          Menu principal"
echo "    /forgesquad-create   Criar squad"
echo "    /forgesquad-run      Executar pipeline"
echo "    /forgesquad-list     Listar squads"
echo "    /forgesquad-report   Gerar relatorio"
echo "    /forgesquad-help     Ajuda"
echo ""
