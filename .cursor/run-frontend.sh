#!/usr/bin/env bash
# Runs the vue-cli 3 admin dev server on http://localhost:8081 using Node 14.
# Node 14 is required for the legacy webpack 4 / vue-cli 3 toolchain and is
# prepended to PATH so it takes precedence over the newer system Node.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export PATH="/opt/node14/bin:$PATH"

cd "$ROOT/project-rjwm-admin-vue-ts"
exec npm run serve
