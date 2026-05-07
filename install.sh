#!/usr/bin/env bash
set -eou pipefail

# ==============================
# CONFIG
# ==============================
export DEBIAN_FRONTEND=noninteractive

BASE_DIR="/opt/netbox-docker"
NETBOX_DIR="${BASE_DIR}/netbox"
OVERRIDE_FILE="${BASE_DIR}/netbox-custom/netbox/docker-compose.override.yml"
ENV_EXAMPLE="${BASE_DIR}/netbox-custom/netbox/.env.example"
ENV_FILE="${NETBOX_DIR}/netbox-custom.env"
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
apt-get install -y ca-certificates curl git python3

# ==============================
# TIMEZONE SAO PAULO CONFIG AND NTP
# ==============================
timedatectl set-timezone America/Sao_Paulo
timedatectl set-ntp true
systemctl restart systemd-timesyncd

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
# DEPLOY NETBOX (Simplified for Lab)
# ==============================
cd "${NETBOX_DIR}"

# CRITICAL: Clean Docker volumes before starting (prevents PostgreSQL password mismatch)
echo "Limpando volumes antigos (docker compose down -v)..."
docker compose down -v 2>/dev/null || true

echo "Aplicando override..."
cp -f "${OVERRIDE_FILE}" docker-compose.override.yml

# Copy .env.example to netbox-custom.env if it doesn't exist
if [ ! -f "${ENV_FILE}" ] && [ -f "${ENV_EXAMPLE}" ]; then
  echo "Copiando .env.example para netbox-custom.env..."
  cp "${ENV_EXAMPLE}" "${ENV_FILE}"
fi

# Generate SECRET_KEY using official method (NOT tr/sed!)
if [ -f "${ENV_FILE}" ] && ! grep -q "SECRET_KEY=gerar_com_python" "${ENV_FILE}" 2>/dev/null; then
  echo "netbox-custom.env já possui SECRET_KEY configurado."
else
  echo "Gerando SECRET_KEY oficial (docker compose run netbox python3 /opt/netbox/netbox/generate_secret_key.py)..."
  NEW_KEY=$(docker compose run --rm netbox python3 /opt/netbox/netbox/generate_secret_key.py 2>/dev/null | tr -d '\n')
  if [ -n "$NEW_KEY" ]; then
    sed -i "s|SECRET_KEY=gerar_com_python|SECRET_KEY=$NEW_KEY|g" "${ENV_FILE}"
    echo "SECRET_KEY gerada com sucesso!"
  else
    echo "Aviso: Não foi possível gerar SECRET_KEY automaticamente. Configure manualmente no netbox-custom.env"
  fi
fi

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
echo "Arquivos de configuração:"
echo "  - ${ENV_FILE} (copiado de ${ENV_EXAMPLE})"
echo "  - ${NETBOX_DIR}/docker-compose.override.yml"
echo ""
echo "Credenciais padrão:"
echo "  - Usuário: admin"
echo "  - Senha: admin"
echo "  (definidas em SUPERUSER_* no netbox-custom.env)"
echo ""
echo "Para logs: cd ${NETBOX_DIR} && docker compose logs -f netbox"
echo "=================================================="
