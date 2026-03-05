#!/bin/bash
# =============================================================================
# update_prometheus_target.sh
# Ejecutar directamente en el server de Prometheus
# Uso: bash update_prometheus_target.sh
# =============================================================================
set -euo pipefail

PROMETHEUS_YML="/etc/prometheus/prometheus.yml"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# --- Extraer targets con sus server_name e IPs ---
echo ""
echo "==> Targets actuales en prometheus.yml:"
echo ""

NAMES=()
IPS=()
i=0

while IFS= read -r line; do
  if [[ "$line" =~ targets:.*\'([0-9.]+):9100\' ]]; then
    current_ip="${BASH_REMATCH[1]}"
  fi
  if [[ "$line" =~ server_name:.*\'([^\']+)\' ]]; then
    i=$((i + 1))
    NAMES+=("${BASH_REMATCH[1]}")
    IPS+=("$current_ip")
    echo -e "  ${YELLOW}${i})${NC} ${BASH_REMATCH[1]} - ${current_ip}"
  fi
done < <(sudo cat "$PROMETHEUS_YML")

if [[ ${#NAMES[@]} -eq 0 ]]; then
  echo -e "${RED}No se encontraron targets con server_name${NC}"
  exit 1
fi

echo ""

# --- Seleccionar target (leer desde /dev/tty para funcionar con curl | bash) ---
read -r -p "Selecciona el número del target a actualizar: " selection < /dev/tty

if ! [[ "$selection" =~ ^[0-9]+$ ]] || [[ "$selection" -lt 1 ]] || [[ "$selection" -gt ${#NAMES[@]} ]]; then
  echo -e "${RED}Selección inválida${NC}"
  exit 1
fi

idx=$((selection - 1))
SELECTED_NAME="${NAMES[$idx]}"
OLD_IP="${IPS[$idx]}"

echo ""
echo -e "Seleccionado: ${YELLOW}${SELECTED_NAME}${NC} (IP actual: ${OLD_IP})"
read -r -p "Nueva IP: " NEW_IP < /dev/tty

if [[ -z "$NEW_IP" ]]; then
  echo -e "${RED}ERROR: Debes ingresar una IP${NC}"
  exit 1
fi

# --- Reemplazar la IP ---
echo ""
echo "==> Actualizando ${OLD_IP} -> ${NEW_IP} para ${SELECTED_NAME}..."

TMP_FILE=$(mktemp)
sudo cp "$PROMETHEUS_YML" "$TMP_FILE"
sed "s/${OLD_IP}:9100/${NEW_IP}:9100/g" "$TMP_FILE" | sudo tee "$PROMETHEUS_YML" > /dev/null
rm -f "$TMP_FILE"

# --- Reiniciar Prometheus ---
sudo systemctl restart prometheus

echo -e "${GREEN}✓ Target '${SELECTED_NAME}' actualizado a ${NEW_IP} y Prometheus reiniciado${NC}"
echo "Verifica en: http://localhost:9090/targets"
