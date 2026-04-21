#!/usr/bin/env bash
set -euo pipefail

# ==============================
# CONFIG
# ==============================
export DEBIAN_FRONTEND=noninteractive

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
NETBOX_DIR="${BASE_DIR}/netbox"
OVERRIDE_FILE="${BASE_DIR}/netbox-custom/netbox/docker-compose.override.yml"
NETBOX_PORT=8000
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
apt-get install -y ca-certificates curl git


# ==============================
# INIT SUBMODULE
# ==============================
echo "Inicializando submodule..."
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

echo "Baixando imagens..."
docker compose pull

echo "Subindo containers..."
docker compose up -d

# ==============================
# WAIT FOR NETBOX
# ==============================
echo "Aguardando NetBox iniciar..."

until curl -s http://localhost:${NETBOX_PORT} >/dev/null; do
  echo "NetBox ainda não disponível..."
  sleep 5
done

# ==============================
# CREATE SUPERUSER
# ==============================
echo "Criando superuser automaticamente..."

NETBOX_ADMIN_USER=${NETBOX_ADMIN_USER:-admin}
NETBOX_ADMIN_PASSWORD=${NETBOX_ADMIN_PASSWORD:-Admin@1234567890}
NETBOX_ADMIN_EMAIL=${NETBOX_ADMIN_EMAIL:-admin@example.com}

docker compose exec -T netbox python3 /opt/netbox/netbox/manage.py shell <<EOF
from django.contrib.auth import get_user_model

User = get_user_model()

username = "${NETBOX_ADMIN_USER}"
email = "${NETBOX_ADMIN_EMAIL}"
password = "${NETBOX_ADMIN_PASSWORD}"

if not User.objects.filter(username=username).exists():
    User.objects.create_superuser(username, email, password)
    print("Superuser criado com sucesso")
else:
    print("Superuser já existe")
EOF


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
echo "✅ NetBox instalado com sucesso!"
echo "=================================================="
echo ""
echo "Docker: $(docker --version)"
echo ""
echo "Acesse: http://${IP_ADDR}:${NETBOX_PORT}"
echo ""
echo "⚠️  IMPORTANTE: altere a senha do usuário admin no primeiro login!"
echo "Usuário: ${NETBOX_ADMIN_USER}"
echo "Senha: ${NETBOX_ADMIN_PASSWORD}"
echo ""
echo "=================================================="