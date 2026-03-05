# Scripts de monitoreo con Prometheus

Scripts para configurar el monitoreo de servidores Linux con Prometheus y Node Exporter.

## 1. Instalar Node Exporter en el servidor a monitorear

Accede al servidor que deseas monitorear y ejecuta:

```bash
curl -sSL https://raw.githubusercontent.com/cgarrido-a/node_exporter_script/main/install_node_exporter.sh | bash
```

## 2. Agregar el target en el servidor de Prometheus

Accede al servidor donde corre Prometheus y ejecuta:

```bash
curl -sSL https://raw.githubusercontent.com/cgarrido-a/node_exporter_script/main/add_prometheus_target.sh | bash -s -- <IP> <SERVER_NAME> <ENVIRONMENT>
```

Ejemplo:

```bash
curl -sSL https://raw.githubusercontent.com/cgarrido-a/node_exporter_script/main/add_prometheus_target.sh | bash -s -- 65.21.100.10 Empieza-1 production
```
