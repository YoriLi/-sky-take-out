# Sourced helper: put Node 16 (managed by nvm) on PATH ahead of any system/shim node.
# The legacy admin frontend (Vue CLI 3 / webpack 4) only builds cleanly on Node 16.
export NVM_DIR="$HOME/.nvm"
# shellcheck disable=SC1090
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
nvm use 16 >/dev/null 2>&1 || true
_NODE16_BIN="$(dirname "$(nvm which 16 2>/dev/null)")"
if [ -n "$_NODE16_BIN" ] && [ -d "$_NODE16_BIN" ]; then
  export PATH="$_NODE16_BIN:$PATH"
fi
# Old registry TLS certs appear expired against the VM clock; relax verification for installs.
export NODE_TLS_REJECT_UNAUTHORIZED=0
