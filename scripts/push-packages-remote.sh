#!/usr/bin/env bash
# Publica o monorepo SPM (Packages/) no GitHub — execute uma vez após criar o repo wimb-packages.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PACKAGES="$ROOT/Packages"
REMOTE_URL="${1:-https://github.com/douglastaquary/wimb-packages.git}"

if [[ ! -d "$PACKAGES/.git" ]]; then
  echo "Erro: $PACKAGES não é um repositório git."
  exit 1
fi

cd "$PACKAGES"

if git remote get-url origin &>/dev/null; then
  echo "Remote origin: $(git remote get-url origin)"
else
  git remote add origin "$REMOTE_URL"
  echo "Remote origin adicionado: $REMOTE_URL"
fi

echo "Enviando branch main para origin..."
git push -u origin main

echo ""
echo "OK. Próximo passo no repo principal (se o ponteiro do submodule mudou):"
echo "  cd $ROOT"
echo "  git add Packages .gitmodules"
echo "  git commit -m 'Atualiza submodule Packages'"
echo "  git push"
