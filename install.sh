#!/usr/bin/env bash
set -euo pipefail

# ==============================
# CONFIG
# ==============================
export DEBIAN_FRONTEND=noninteractive

BASE_DIR="/opt/netbox-docker"
NETBOX_DIR="${BASE_DIR}/netbox"
OVERRIDE_FILE="${BASE_DIR}/netbox-custom/netbox/docker-compose.override.yml"
ENV_FILE="${BASE_DIR}/.env"

# Definir variáveis com fallback (agora vêm do .env externo)
NETBOX_PORT="${NETBOX_PORT}"
IP_ADDR=$(hostname -I | awk '{print $1}')

# ==============================
# VALIDATIONS
# ==============================
if [ "$EUID" -ne 0 ]; then
  echo "Execute como root"
  exit 1
fi

# ==============================
# INSTALL DEPENDENCIES
# ==============================
apt-get update -y
apt-get install -y ca-certificates curl git python3

# ==============================
# TIMEZONE SAO PAULO CONFIG AND NTP
# ==============================
timedatectl set-timezone "$TIME_ZONE"
timedatectl set-ntp true
systemctl restart systemd-timesyncd

# ==============================
# VERIFICAR PORTA (do .env)
# ==============================
echo "Verificando se a porta ${NETBOX_PORT} está disponível..."
if netstat -tuln | grep -q ":${NETBOX_PORT} "; then
  echo "❌ ERRO: Porta ${NETBOX_PORT} já está em uso!"
  echo "   Altere a variável NETBOX_PORT no arquivo .env"
  exit 1
fi
echo "✅ Porta ${NETBOX_PORT} disponível."

# ==============================
# INIT SUBMODULE
# ==============================
echo "Inicializando submodule..."
# Pitfall: Remove existing netbox/ directory to avoid "already exists" errors
rm -rf "${NETBOX_DIR}"
git submodule update --init --recursive

if [ ! -f "${NETBOX_DIR}/docker-compose.yml" ]; then
  echo "Erro: submodule netbox não inicializado corretamente"
  exit 1
fi

if [ ! -f "${OVERRIDE_FILE}" ]; then
  echo "Override não encontrado!"
  exit 1
fi

# ==============================
# INSTALL DOCKER (SE NÃO EXISTIR)
# ==============================
if ! command -v docker &> /dev/null; then
  echo "Instalando Docker..."
  
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  chmod a+r /etc/apt/keyrings/docker.asc
  
  tee /etc/apt/sources.list.d/docker.sources > /dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF
  
  apt-get update -y
  apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
fi

systemctl enable --now docker

# ==============================
# DEPLOY NETBOX
# ==============================
cd "${NETBOX_DIR}"

echo "Aplicando override..."
cp -f "${OVERRIDE_FILE}" docker-compose.override.yml
cp -f "${ENV_FILE}" .env

echo "Baixando imagens..."
docker compose pull

echo "Subindo containers..."
docker compose up -d

# ==============================
# WAIT FOR NETBOX
# ==============================
echo "Aguardando NetBox iniciar (aguardando 'healthy' status)..."
attempt=0
max_attempts=30  # 30 * 10s = 5 minutes max
until docker ps --filter "name=netbox" --filter "health=healthy" --format "{{.Names}}" | grep -q netbox; do
  attempt=$((attempt + 1))
  if [ $attempt -ge $max_attempts ]; then
    echo "Erro: NetBox não ficou healthy após 5 minutos"
    echo "Verifique os logs: docker compose logs netbox"
    exit 1
  fi
  echo "NetBox ainda não está healthy... (tentativa $attempt/$max_attempts)"
  sleep 10
done

# ==============================
# SYSTEMD SERVICE
# ==============================
cat <<EOF > /etc/systemd/system/netbox.service
[Unit]
Description=NetBox Docker Compose
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
WorkingDirectory=${NETBOX_DIR}
ExecStart=/usr/bin/docker compose up -d
ExecStop=/usr/bin/docker compose down
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable netbox

# ==============================
# INFO FINAL
# ==============================
echo "=================================================="
echo "✅ NetBox instalado com sucesso (configuração simplificada para laboratório)!"
echo "=================================================="
echo ""
echo "Docker: $(docker --version)"
echo ""
echo "Acesse: http://${IP_ADDR}:${NETBOX_PORT}"
echo ""
echo ""
echo "Credenciais (configuradas no arquivo .env):"
echo "  - Usuário: ${SUPERUSER_NAME}"
echo "  - Senha: ${SUPERUSER_PASSWORD}"
echo ""
echo "Para logs: cd ${NETBOX_DIR} && docker compose logs -f netbox"
echo "=================================================="
