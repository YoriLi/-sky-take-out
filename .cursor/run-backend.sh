#!/usr/bin/env bash
# Runs the Spring Boot backend (sky-server) on http://localhost:8080 using Java 11.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export PATH="$JAVA_HOME/bin:$PATH"

cd "$ROOT/sky-take-out"
JAR=sky-server/target/sky-server-1.0-SNAPSHOT.jar
if [ ! -f "$JAR" ]; then
  mvn -q clean package -DskipTests -Dmaven.test.skip=true
fi
exec java -jar "$JAR"
