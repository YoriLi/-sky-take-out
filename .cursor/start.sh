#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# 苍穹外卖 (sky-take-out) — Cloud Agent start phase (per-boot, idempotent).
#
# Brings up the infrastructure services the app needs on every boot and makes
# sure the database schema is present, then returns. The application servers
# themselves run as visible `terminals` (see .cursor/environment.json).
# ---------------------------------------------------------------------------
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "==> starting MySQL and Redis"
sudo service mysql start || true
sudo service redis-server start || true

echo "==> waiting for MySQL"
for _ in $(seq 1 30); do sudo mysqladmin ping >/dev/null 2>&1 && break; sleep 1; done

# Ensure the app's root credentials work over TCP (idempotent).
sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '123456'; FLUSH PRIVILEGES;" 2>/dev/null || true

# Seed only when the schema is missing so existing data survives reboots.
if ! mysql -uroot -p123456 -h 127.0.0.1 -e "SELECT 1 FROM sky_take_out.employee LIMIT 1;" >/dev/null 2>&1; then
  echo "==> seeding sky_take_out database"
  mysql -uroot -p123456 -h 127.0.0.1 < "$ROOT/.cursor/db/sky_take_out.sql"
fi

echo "==> start complete (redis: $(redis-cli ping 2>/dev/null || echo down))"
