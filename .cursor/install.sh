#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# 苍穹外卖 (sky-take-out) — Cloud Agent install phase (idempotent).
#
# Prepares a fully working dev environment:
#   * system toolchains: JDK 11, Maven, MySQL, Redis, build tools
#   * Node 14 (for the legacy vue-cli 3 admin frontend) under /opt/node14
#   * builds the Spring Boot backend jar
#   * installs frontend npm dependencies
#   * seeds the sky_take_out MySQL database
# Safe to run repeatedly.
# ---------------------------------------------------------------------------
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NODE14_DIR=/opt/node14
JAVA11_HOME=/usr/lib/jvm/java-11-openjdk-amd64

echo "==> [1/5] System dependencies"
export DEBIAN_FRONTEND=noninteractive
if ! command -v mvn >/dev/null 2>&1 || ! command -v mysqld >/dev/null 2>&1 || ! command -v redis-server >/dev/null 2>&1; then
  sudo apt-get update
  sudo apt-get install -y --no-install-recommends \
    openjdk-11-jdk-headless maven \
    mysql-server redis-server \
    build-essential python3 \
    curl ca-certificates xz-utils
fi
# The base image ships JDK 21, which is incompatible with this project's
# Lombok 1.18.20; pin the JVM used for the backend build to Java 11.
sudo update-alternatives --set java "$JAVA11_HOME/bin/java" >/dev/null 2>&1 || true

echo "==> [2/5] Node 14 (legacy vue-cli frontend)"
if [ ! -x "$NODE14_DIR/bin/node" ]; then
  curl -fsSL https://nodejs.org/dist/v14.21.3/node-v14.21.3-linux-x64.tar.xz -o /tmp/node14.tar.xz
  sudo mkdir -p "$NODE14_DIR"
  sudo tar -xJf /tmp/node14.tar.xz -C "$NODE14_DIR" --strip-components=1
  rm -f /tmp/node14.tar.xz
fi

echo "==> [3/5] Build backend (Java 11)"
export JAVA_HOME="$JAVA11_HOME"
( cd "$ROOT/sky-take-out" && mvn -q clean package -DskipTests -Dmaven.test.skip=true )

echo "==> [4/5] Install frontend dependencies (Node 14)"
# The optional `fibers` dep (a dart-sass perf helper) cannot build against the
# modern node-gyp/Python toolchain, so native build scripts are skipped;
# vue-cli falls back to plain dart-sass automatically.
export PATH="$NODE14_DIR/bin:$PATH"
( cd "$ROOT/project-rjwm-admin-vue-ts" && npm install --ignore-scripts )

echo "==> [5/5] Seed sky_take_out database"
sudo service mysql start || true
sudo service redis-server start || true
for _ in $(seq 1 30); do sudo mysqladmin ping >/dev/null 2>&1 && break; sleep 1; done
sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '123456'; FLUSH PRIVILEGES;" 2>/dev/null || true
mysql -uroot -p123456 -h 127.0.0.1 < "$ROOT/.cursor/db/sky_take_out.sql"

echo "==> install complete"
