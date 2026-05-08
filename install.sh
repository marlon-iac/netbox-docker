#!/usr/bin/env bash
set -euo pipefail

# ==============================
# CONFIG
# ==============================
export DEBIAN_FRONTEND=noninteractive

BASE_DIR="/opt/netbox-docker"
NETBOX_DIR="${BASE_DIR}/netbox"
OVERRIDE_FILE="${BASE_DIR}/netbox-custom/netbox/docker-compose.override.yml"
ENV_EXAMPLE="${BASE_DIR}/.env.example"
ENV_FILE="${BASE_DIR}/.env"

# ==============================
# CARREGAR VARIÁVEIS DO .env (RAIZ DO PROJETO)
# ==============================
if [ -f "${ENV_FILE}" ]; then
  echo "Carregando variáveis do .env..."
  set -a
  source "${ENV_FILE}"
  set +a
else
  if [ -f "${ENV_EXAMPLE}" ]; then
    echo "Arquivo .env não encontrado. Criando a partir de .env.example..."
    cp "${ENV_EXAMPLE}" "${ENV_FILE}"
    set -a
    source "${ENV_FILE}"
    set +a
    echo "✅ Arquivo .env criado na raiz do projeto!"
    echo "   Edite: nano ${ENV_FILE}"
    echo "   Dica: Gere a SECRET_KEY com: docker compose --env-file ${ENV_FILE} run netbox python3 /opt/netbox/netbox/generate_secret_key.py"
    echo "   Depois execute novamente: sudo ./install.sh"
    exit 0
  else
    echo "⚠️  Arquivo .env.example não encontrado na raiz."
  fi
fi

# Definir variáveis com fallback (agora vêm do .env externo)
NETBOX_PORT="${NETBOX_PORT:-8000}"
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
# DEPLOY NETBOX (Simplified for Lab)
# ==============================
cd "${NETBOX_DIR}"

# CRITICAL: Clean Docker volumes before starting (prevents PostgreSQL password mismatch)
echo "Limpando volumes antigos (docker compose down -v)..."
docker compose --env-file "${ENV_FILE}" down -v 2>/dev/null || true

echo "Aplicando override..."
cp -f "${OVERRIDE_FILE}" docker-compose.override.yml

# Validar se SECRET_KEY está configurada (NÃO geramos mais automaticamente)
if [ -f "${ENV_FILE}" ]; then
  SECRET_KEY_VAL=$(grep "^SECRET_KEY=" "${ENV_FILE}" | cut -d'=' -f2-)
  if [ -z "$SECRET_KEY_VAL" ]; then
    echo "⚠️  AVISO: SECRET_KEY não está configurada no .env!"
    echo "   Gere uma com: cd ${NETBOX_DIR}"
    echo "   docker compose --env-file ${ENV_FILE} run netbox python3 /opt/netbox/netbox/generate_secret_key.py"
    echo "   Depois copie a chave para o arquivo .env"
  fi
fi

echo "Baixando imagens..."
docker compose --env-file "${ENV_FILE}" pull

echo "Subindo containers..."
docker compose --env-file "${ENV_FILE}" up -d

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
    echo "Verifique os logs: docker compose --env-file ${ENV_FILE} logs netbox"
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
ExecStart=/usr/bin/docker compose --env-file ${ENV_FILE} up -d
ExecStop=/usr/bin/docker compose --env-file ${ENV_FILE} down
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
echo "  - ${ENV_FILE} (raiz do projeto - .env)"
echo "  - ${NETBOX_DIR}/docker-compose.override.yml"
echo ""
echo "Credenciais (configure no arquivo .env):"
echo "  - Usuário: ${SUPERUSER_NAME:-admin}"
echo "  - Senha: ${SUPERUSER_PASSWORD:-admin}"
echo ""
echo "Para logs: cd ${NETBOX_DIR} && docker compose --env-file ${ENV_FILE} logs -f netbox"
echo "=================================================="
