#!/usr/bin/env bash
set -euo pipefail

# ==============================
# FUNÇÕES AUXILIARES
# ==============================

# Gerar senha aleatória (60 caracteres, atende Django SECRET_KEY >= 50)
generate_password() {
  local password=""
  # Django exige pelo menos 50 caracteres para SECRET_KEY
  # Apenas A-Za-z0-9 (evita problemas com tr ranges e source .env)
  while [ ${#password} -lt 60 ]; do
    char=$(</dev/urandom tr -dc 'A-Za-z0-9' | head -c 1)
    password="${password}${char}"
  done
  echo "$password"
}

# ==============================
# CONFIG
# ==============================
export DEBIAN_FRONTEND=noninteractive

BASE_DIR="/opt/netbox-docker"
NETBOX_DIR="${BASE_DIR}/netbox"
OVERRIDE_FILE="${BASE_DIR}/netbox-custom/netbox/docker-compose.override.yml"
ENV_FILE="${BASE_DIR}/.env"
ENV_EXAMPLE="${BASE_DIR}/.env.example"

# ==============================
# CARREGAR VARIÁVEIS DO .env
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
    echo "✅ Arquivo .env criado! Você pode editá-lo antes de executar novamente."
    echo "   Edite: nano ${ENV_FILE}"
    echo "   Depois execute novamente: sudo ./install.sh"
    exit 0
  else
    echo "⚠️  Arquivo .env.example não encontrado. Usando valores padrão."
  fi
fi

# ==============================
# GERAR SENHAS FORTES (PADRÃO OFICIAL)
# ==============================
echo "Verificando senhas..."

# Lista de variáveis que devem ser senhas fortes
PASSWORDS_TO_CHECK=(
  "POSTGRES_PASSWORD"
  "DB_PASSWORD"
  "REDIS_PASSWORD"
  "REDIS_CACHE_PASSWORD"
  "SECRET_KEY"
)

for var in "${PASSWORDS_TO_CHECK[@]}"; do
  current_value="${!var:-}"
  
  # Se vazio OU se for senha fraca (padrão anterior)
  if [ -z "$current_value" ] || [ "$current_value" = "netbox" ] || [ "$current_value" = "Admin@1234567890" ]; then
    echo "  Gerando ${var} forte..."
    new_password=$(generate_password)
    
    # Atualizar variável atual
    export $var="$new_password"
    
    # Atualizar arquivo .env (usando sed com separador ~)
    if [ -f "${ENV_FILE}" ]; then
      # Se a linha existe, substitui; senão, adiciona
      if grep -q "^${var}=" "${ENV_FILE}"; then
        # Usar ~ como separador (evita conflito com | na senha)
        sed -i "s~^${var}=.*~${var}=${new_password}~" "${ENV_FILE}"
      else
        echo "${var}=${new_password}" >> "${ENV_FILE}"
      fi
    fi
  fi
done

echo "✅ Senhas verificadas/geradas!"

# Definir variáveis com fallback
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
apt-get install -y ca-certificates curl git net-tools

# ==============================
# TIMEZONE SAO PAULO CONFIG AND NTP
# ==============================
timedatectl set-timezone America/Sao_Paulo
timedatectl set-ntp true
systemctl restart systemd-timesyncd

# ==============================
# VERIFICAR PORTA
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

# Limpeza: remover diretório netbox/ se existir (evita erro de diretório não vazio)
if [ -d "${NETBOX_DIR}" ]; then
  echo "Removendo diretório netbox/ existente..."
  rm -rf "${NETBOX_DIR}"
fi

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
docker compose --env-file "${ENV_FILE}" pull

echo "Subindo containers..."
# Limpar volumes anteriores para evitar conflito de senhas (PostgreSQL)
# Volumes persistem dados mesmo após 'docker rm', causando falha de autenticação
cd "${NETBOX_DIR}"
docker compose --env-file "${ENV_FILE}" down -v 2>/dev/null || true
cd "${BASE_DIR}"

docker compose --env-file "${ENV_FILE}" up -d

# ==============================
# WAIT FOR NETBOX (MELHORADO)
# ==============================
echo "Aguardando NetBox iniciar..."
echo "⏳ Isso pode levar até 10 minutos na primeira inicialização (banco de dados)..."

ELAPSED=0
 until curl -s -o /dev/null -w "%{http_code}" http://localhost:${NETBOX_PORT} | grep -qE "200|302"; do
  printf "NetBox ainda não disponível... %ds elapsed\r" "$ELAPSED"
  sleep 10
  ELAPSED=$((ELAPSED + 10))  
  
  # Timeout de 15 minutos
  if [ $ELAPSED -ge 900 ]; then
    echo ""
    echo "❌ TIMEOUT: NetBox não iniciou em 15 minutos."
    echo "   Verifique os logs: cd ${NETBOX_DIR} && docker compose logs -f"
    exit 1
  fi
done

echo ""
echo "✅ NetBox respondeu após ${ELAPSED}s!"

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
echo "✅ NetBox instalado com sucesso!"
echo "=================================================="
echo ""
echo "Docker: $(docker --version)"
echo ""
echo "Acesse: http://${IP_ADDR}:${NETBOX_PORT}"
echo ""
echo "Credenciais (configure no arquivo .env):"
echo "  Usuário: ${SUPERUSER_NAME:-admin}"
echo "  Senha: ${SUPERUSER_PASSWORD:-Admin@1234567890}"
echo ""
echo "Para alterar configurações:"
echo "  1. Edite: nano ${ENV_FILE}"
echo "  2. Reinicie: systemctl restart netbox"
echo ""
echo "=================================================="
