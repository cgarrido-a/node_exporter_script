#!/bin/bash
# =============================================================================
# add_prometheus_target.sh
# Ejecutar directamente en el server de Prometheus
# Uso: bash add_prometheus_target.sh <IP_DEL_NUEVO_SERVER>
# Ejemplo: bash add_prometheus_target.sh 65.21.100.10
# =============================================================================
set -euo pipefail

PROMETHEUS_YML="/etc/prometheus/prometheus.yml"

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# --- Validar que se pasó una IP ---
if [[ -z "${1:-}" ]]; then
  echo -e "${RED}ERROR: Debes pasar la IP del nuevo server${NC}"
  echo "Uso: bash add_prometheus_target.sh <IP>"
  exit 1
fi

NEW_TARGET="${1}:9100"

# --- Verificar si el target ya existe ---
if grep -q "$NEW_TARGET" "$PROMETHEUS_YML"; then
  echo "El target $NEW_TARGET ya existe en prometheus.yml"
  exit 0
fi

# --- Agregar el nuevo target ---
echo "==> Agregando $NEW_TARGET..."
TMP_FILE=$(mktemp)
sudo cp "$PROMETHEUS_YML" "$TMP_FILE"
sed "/targets:/a\\          - '$NEW_TARGET'" "$TMP_FILE" | sudo tee "$PROMETHEUS_YML" > /dev/null
rm -f "$TMP_FILE"

# --- Reiniciar Prometheus ---
sudo systemctl restart prometheus

echo -e "${GREEN}✓ $NEW_TARGET agregado y Prometheus reiniciado${NC}"
echo "Verifica en: http://localhost:9090/targets"