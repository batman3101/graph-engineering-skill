#!/usr/bin/env bash
# graph-engineering skill installer (macOS / Linux / WSL)
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/<user>/<repo>/main/install.sh | bash
#   curl -fsSL .../install.sh | bash -s -- -p   # project-local install

set -euo pipefail

REPO_USER="batman3101"
REPO_NAME="graph-engineering-skill"
BRANCH="main"
SKILL_DIR="graph-engineering"
MODE="global"

for arg in "${@:-}"; do
  case "$arg" in
    -p|--project) MODE="project" ;;
    -g|--global) MODE="global" ;;
  esac
done

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

echo "[graph-engineering] Downloading skill from GitHub..."
curl -fsSL "https://github.com/${REPO_USER}/${REPO_NAME}/archive/refs/heads/${BRANCH}.tar.gz" -o "$TMP_DIR/repo.tar.gz"
tar -xzf "$TMP_DIR/repo.tar.gz" -C "$TMP_DIR"

SRC="$TMP_DIR/${REPO_NAME}-${BRANCH}/${SKILL_DIR}"
if [ ! -d "$SRC" ]; then
  echo "[ERROR] Skill folder not found in downloaded repo: $SRC"
  exit 1
fi

installed=0

if [ "$MODE" = "global" ]; then
  echo "[graph-engineering] Installing globally for \$HOME..."

  if command -v claude >/dev/null 2>&1; then
    mkdir -p "$HOME/.claude/skills"
    rm -rf "$HOME/.claude/skills/$SKILL_DIR"
    cp -r "$SRC" "$HOME/.claude/skills/$SKILL_DIR"
    echo "  -> Claude Code: $HOME/.claude/skills/$SKILL_DIR"
    installed=1
  fi

  if command -v codex >/dev/null 2>&1; then
    mkdir -p "$HOME/.agents/skills"
    rm -rf "$HOME/.agents/skills/$SKILL_DIR"
    cp -r "$SRC" "$HOME/.agents/skills/$SKILL_DIR"
    echo "  -> Codex: $HOME/.agents/skills/$SKILL_DIR"
    installed=1
  fi

  if [ "$installed" -eq 0 ]; then
    echo "  [!] Neither 'claude' nor 'codex' found in PATH."
    echo "      Installing to both default locations anyway."
    mkdir -p "$HOME/.claude/skills" "$HOME/.agents/skills"
    rm -rf "$HOME/.claude/skills/$SKILL_DIR" "$HOME/.agents/skills/$SKILL_DIR"
    cp -r "$SRC" "$HOME/.claude/skills/$SKILL_DIR"
    cp -r "$SRC" "$HOME/.agents/skills/$SKILL_DIR"
    echo "  -> $HOME/.claude/skills/$SKILL_DIR"
    echo "  -> $HOME/.agents/skills/$SKILL_DIR"
  fi
else
  echo "[graph-engineering] Installing into current project: $(pwd)"
  mkdir -p ".claude/skills" ".agents/skills"
  rm -rf ".claude/skills/$SKILL_DIR" ".agents/skills/$SKILL_DIR"
  cp -r "$SRC" ".claude/skills/$SKILL_DIR"
  cp -r "$SRC" ".agents/skills/$SKILL_DIR"
  echo "  -> $(pwd)/.claude/skills/$SKILL_DIR"
  echo "  -> $(pwd)/.agents/skills/$SKILL_DIR"
fi

echo ""
echo "[graph-engineering] Install complete."
echo "  Claude Code : type /graph-engineering"
echo "  Codex       : mention \"graph-engineering skill\" in your prompt"
