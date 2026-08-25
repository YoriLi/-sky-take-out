#!/usr/bin/env bash
# Per-boot service reconciliation: bring up Redis and MySQL, then ensure the
# sky_take_out database exists and is seeded. Idempotent and safe to re-run.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

DB_NAME="sky_take_out"
DB_PASS="123456"

echo "==> Starting Redis"
sudo service redis-server start || true

echo "==> Starting MySQL"
sudo service mysql start || true

echo "==> Waiting for MySQL to accept connections"
for _ in $(seq 1 60); do
  if sudo mysqladmin ping >/dev/null 2>&1; then break; fi
  sleep 1
done

# Ensure the app can log in over TCP as root/123456 (MySQL 8 defaults root to auth_socket).
if ! mysql -h127.0.0.1 -uroot -p"${DB_PASS}" -e "SELECT 1" >/dev/null 2>&1; then
  echo "==> Configuring MySQL root password + native auth"
  sudo mysql <<SQL
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${DB_PASS}';
FLUSH PRIVILEGES;
SQL
fi

echo "==> Ensuring database ${DB_NAME} exists"
mysql -h127.0.0.1 -uroot -p"${DB_PASS}" \
  -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME} CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;"

if ! mysql -h127.0.0.1 -uroot -p"${DB_PASS}" "${DB_NAME}" \
      -e "SELECT 1 FROM employee LIMIT 1" >/dev/null 2>&1; then
  echo "==> Seeding schema from database/sky.sql"
  mysql -h127.0.0.1 -uroot -p"${DB_PASS}" "${DB_NAME}" < database/sky.sql
fi

echo "==> start.sh complete (Redis + MySQL ready, ${DB_NAME} seeded)"
