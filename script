#!/bin/bash
# =============================================================================
# install_node_exporter.sh
# Uso: bash install_node_exporter.sh
# =============================================================================
set -euo pipefail

VERSION="1.10.2"
ARCH="linux-amd64"
PKG="node_exporter-${VERSION}.${ARCH}"

echo "[1/6] Descargando Node Exporter v${VERSION}..."
cd /tmp
curl -sSLO "https://github.com/prometheus/node_exporter/releases/download/v${VERSION}/${PKG}.tar.gz"

echo "[2/6] Extrayendo..."
tar xzf "${PKG}.tar.gz"

echo "[3/6] Instalando binario..."
mv "${PKG}/node_exporter" /usr/local/bin/
chmod +x /usr/local/bin/node_exporter

echo "[4/6] Creando usuario de sistema..."
useradd --no-create-home --shell /bin/false node_exporter 2>/dev/null || true
chown node_exporter:node_exporter /usr/local/bin/node_exporter

echo "[5/6] Creando servicio systemd..."
cat > /etc/systemd/system/node_exporter.service << 'EOF'
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

echo "[6/6] Habilitando e iniciando servicio..."
systemctl daemon-reload
systemctl enable node_exporter
systemctl restart node_exporter

rm -rf /tmp/node_exporter-*

echo ""
echo "✓ Node Exporter v${VERSION} instalado y corriendo en puerto 9100"
echo ""

# --- Verificación automática ---
echo "Verificando servicio..."
sleep 2

if systemctl is-active --quiet node_exporter; then
  echo "✓ Servicio activo"
else
  echo "✗ El servicio no está corriendo. Revisa con: journalctl -u node_exporter -n 20"
  exit 1
fi

if curl -sf http://localhost:9100/metrics > /dev/null; then
  echo "✓ Puerto 9100 respondiendo"
else
  echo "✗ Puerto 9100 no responde. Revisa con: journalctl -u node_exporter -n 20"
  exit 1
fi

echo ""
echo "Todo listo. Agrega este server a Prometheus:"
echo "  - targets: ['$(hostname -I | awk '{print $1}'):9100']"