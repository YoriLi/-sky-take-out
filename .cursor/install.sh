#!/usr/bin/env bash
# Idempotent repository bootstrap for the sky-take-out (苍穹外卖) stack.
# Builds the Spring Boot backend (JDK 8) and installs the Vue admin frontend deps (Node 16).
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

echo "==> Backend: build sky-server with JDK 8 + Maven"
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export PATH="$JAVA_HOME/bin:$PATH"
( cd sky-take-out && mvn -q -DskipTests clean package )

echo "==> Frontend: ensure Node 16 (nvm) is available"
export NVM_DIR="$HOME/.nvm"
if [ ! -s "$NVM_DIR/nvm.sh" ]; then
  curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
fi
# shellcheck disable=SC1091
source "$REPO_ROOT/.cursor/node-env.sh"
nvm install 16 >/dev/null
# Re-resolve PATH now that 16 is definitely installed.
export PATH="$(dirname "$(nvm which 16)"):$PATH"
command -v yarn >/dev/null 2>&1 || npm i -g yarn

echo "==> Frontend: install admin dependencies"
( cd project-rjwm-admin-vue-ts && yarn install --network-timeout 600000 )

echo "==> install.sh complete"
