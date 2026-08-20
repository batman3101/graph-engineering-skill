#!/usr/bin/env bash
# One-shot GitHub publisher for the graph-engineering skill.
# Creates a PUBLIC repo, rewrites the placeholder username, commits and pushes.
# Requires: git, gh (GitHub CLI)

set -euo pipefail

REPO_NAME="graph-engineering-skill"

echo ""
echo "=== graph-engineering skill : GitHub publisher ==="
echo ""

command -v git >/dev/null || { echo "[ERROR] git not found."; exit 1; }
command -v gh  >/dev/null || { echo "[ERROR] GitHub CLI (gh) not found. See https://cli.github.com"; exit 1; }

if ! gh auth status >/dev/null 2>&1; then
  echo "[INFO] Not logged in. Starting GitHub login..."
  gh auth login
fi

GH_USER="$(gh api user --jq .login)"
[ -n "$GH_USER" ] || { echo "[ERROR] Could not resolve GitHub username."; exit 1; }

echo "[INFO] GitHub user: $GH_USER"
echo "[INFO] Repo to create: $GH_USER/$REPO_NAME (public)"
echo ""

echo "[INFO] Rewriting placeholders..."
for f in install.cmd install.sh README.md; do
  [ -f "$f" ] || continue
  sed -i.bak \
    -e "s/YOUR_GITHUB_USERNAME/${GH_USER}/g" \
    -e "s#raw.githubusercontent.com/USER/#raw.githubusercontent.com/${GH_USER}/#g" \
    -e "s#github.com/USER/#github.com/${GH_USER}/#g" \
    "$f"
  rm -f "$f.bak"
done

[ -d .git ] || git init -q
git add -A
git commit -q -m "graph-engineering skill v4" 2>/dev/null || true
git branch -M main

if gh repo view "$GH_USER/$REPO_NAME" >/dev/null 2>&1; then
  echo "[INFO] Repository already exists. Pushing..."
  git remote remove origin 2>/dev/null || true
  git remote add origin "https://github.com/$GH_USER/$REPO_NAME.git"
  git push -u origin main --force
else
  echo "[INFO] Creating public repository..."
  gh repo create "$REPO_NAME" --public --source=. --remote=origin --push
fi

echo ""
echo "=== Done ==="
echo "Repo : https://github.com/$GH_USER/$REPO_NAME"
echo ""
echo "One-line install for anyone:"
echo "  curl -fsSL https://raw.githubusercontent.com/$GH_USER/$REPO_NAME/main/install.sh | bash"
echo ""
