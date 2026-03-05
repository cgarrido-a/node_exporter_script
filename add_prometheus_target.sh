#!/bin/bash
# =============================================================================
# add_prometheus_target.sh
# Ejecutar directamente en el server de Prometheus
# Uso: bash add_prometheus_target.sh <IP> <SERVER_NAME> <ENVIRONMENT>
# Ejemplo: bash add_prometheus_target.sh 65.21.100.10 Empieza-1 production
# =============================================================================
set -euo pipefail

PROMETHEUS_YML="/etc/prometheus/prometheus.yml"

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# --- Validar parámetros ---
if [[ -z "${1:-}" || -z "${2:-}" || -z "${3:-}" ]]; then
  echo -e "${RED}ERROR: Faltan parámetros${NC}"
  echo "Uso: bash add_prometheus_target.sh <IP> <SERVER_NAME> <ENVIRONMENT>"
  echo "Ejemplo: bash add_prometheus_target.sh 65.21.100.10 Empieza-1 production"
  exit 1
fi

IP="$1"
SERVER_NAME="$2"
ENVIRONMENT="$3"
NEW_TARGET="${IP}:9100"

# --- Verificar si el target ya existe ---
if sudo grep -q "$NEW_TARGET" "$PROMETHEUS_YML"; then
  echo "El target $NEW_TARGET ya existe en prometheus.yml"
  exit 0
fi

# --- Agregar el nuevo target bajo job_name: 'servidor-app' ---
echo "==> Agregando $NEW_TARGET..."

BLOCK="      - targets: ['${NEW_TARGET}']\n        labels:\n          server_name: '${SERVER_NAME}'\n          environment: '${ENVIRONMENT}'"

TMP_FILE=$(mktemp)
sudo cp "$PROMETHEUS_YML" "$TMP_FILE"
sudo sed -i "/job_name: 'servidor-app'/,/job_name:/ {
  /static_configs:/a\\
${BLOCK}
}" "$TMP_FILE"
sudo cp "$TMP_FILE" "$PROMETHEUS_YML"
rm -f "$TMP_FILE"

# --- Reiniciar Prometheus ---
sudo systemctl restart prometheus

echo -e "${GREEN}✓ $NEW_TARGET agregado y Prometheus reiniciado${NC}"
echo "Verifica en: http://localhost:9090/targets"
