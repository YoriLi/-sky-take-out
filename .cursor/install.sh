#!/usr/bin/env bash
# Idempotent repository bootstrap for the sky-take-out (苍穹外卖) stack.
# Installs system toolchains (JDK 8, Maven, MySQL, Redis), builds the Spring Boot
# backend, and installs the Vue admin frontend deps (Node 16). Safe to re-run.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

JDK8_HOME=/usr/lib/jvm/java-8-openjdk-amd64

echo "==> System packages: JDK 8, Maven, MySQL, Redis"
if [ ! -d "$JDK8_HOME" ] || ! command -v mvn >/dev/null 2>&1 \
   || ! command -v mysqld >/dev/null 2>&1 || ! command -v redis-server >/dev/null 2>&1; then
  sudo apt-get update -y
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    openjdk-8-jdk maven mysql-server redis-server ca-certificates curl
fi

echo "==> Backend: build sky-server with JDK 8 + Maven"
export JAVA_HOME="$JDK8_HOME"
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
