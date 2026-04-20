#!/bin/bash
# ==============================================================================
# Instalação do Netbox com Docker
# ==============================================================================

set -euo pipefail  # Para o script parar em caso de erro

# ==============================================================================
# CONFIG
# ==============================================================================
VAGRANT_HOME="/home/vagrant"
SHARED_DIR="${VAGRANT_HOME}/shared"
NETBOX_DIR="${VAGRANT_HOME}/netbox-docker"

export DEBIAN_FRONTEND=noninteractive


echo "=================================================="
echo "🚀 Iniciando provisionamento Netbox..."
echo "=================================================="
echo ""

# Removendo Docker (se instalado) - para evitar conflitos de dependências
echo "<<<<< Removendo Docker >>>>>"
apt remove $(dpkg --get-selections docker.io docker-compose docker-compose-v2 docker-doc podman-docker containerd runc | cut -f1) -y

# Setup do repositório Docker
echo "<<<<< Setup do repositório Docker >>>>>"
# Add Docker's official GPG key:
apt-get update -y
apt install ca-certificates curl -y
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

# Instalação do Docker
echo "<<<<< Instalando Docker >>>>>"
apt-get update -y
apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# Iniciar e habilitar Docker
echo "<<<<< Iniciando e habilitando Docker >>>>>"
systemctl enable --now docker

# Adicionar usuário vagrant ao grupo docker
# o usuário precisa ter permissão de admin para alguns diretórios do Docker, então adicionamos ele ao grupo docker
echo "<<<<< Adicionando vagrant ao grupo docker >>>>>"
usermod -aG docker vagrant
newgrp docker

# Criando links simbólicos para os arquivos compartilhados
echo "<<<<< Criando links simbólicos e copiando arquivos >>>>>"
cd "${VAGRANT_HOME}"
# Link para projeto compartilhado
ln -sfn "${SHARED_DIR}/netbox-docker" "${NETBOX_DIR}"

# copiar arquivo do docker customizados
cp -fv "${SHARED_DIR}/netbox-custom/docker-compose.override.yml" "${NETBOX_DIR}/docker-compose.override.yml"
cp -fv "${SHARED_DIR}/netbox-custom/Dockerfile-Plugins" "${NETBOX_DIR}/Dockerfile-Plugins"
cp -fv "${SHARED_DIR}/netbox-custom/plugin_requirements.txt" "${NETBOX_DIR}/plugin_requirements.txt"
cp -fv "${SHARED_DIR}/netbox-custom/configuration/plugins.py" "${NETBOX_DIR}/configuration/plugins.py"


# Iniciando o Docker Compose com o Netbox
echo "<<<<< Iniciando NetBox (pode demorar na primeira vez)... >>>>>"
cd "${NETBOX_DIR}"
# o comando abaixo irá fazer o build da minha imagem customizada com plugins
docker compose build --no-cache
# utilizar docker compose pull apenas se for baixar a imagem sem fazer o build
# docker compose pull
docker compose up -d

echo "<<<<< Criando serviço systemd para o NetBox >>>>>"

cat <<EOF > /etc/systemd/system/netbox.service
[Unit]
Description=NetBox Docker Compose
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
WorkingDirectory=${NETBOX_DIR}
ExecStart=/usr/bin/docker compose up -d --wait
ExecStop=/usr/bin/docker compose down
RemainAfterExit=yes
TimeoutStartSec=500

# Opcional: faz o systemd tentar novamente se o start falhar
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Recarregar systemd e habilitar serviço
systemctl daemon-reexec
systemctl daemon-reload
systemctl enable netbox

echo "<<<<< Serviço netbox habilitado para iniciar no boot >>>>>"

# Verificações finais
echo "=================================================="
echo "✅ Provisionamento concluído!"
echo "=================================================="
echo ""
echo "=== Versões instaladas ==="
echo "Docker:  $(docker --version)"
echo "Status Docker: $(systemctl is-active docker)"
echo ""
echo "Setup inicial do Netbox. Execute o comando abaixo para criar o usuário administrador:"
echo "Execute o comando docker compose exec netbox /opt/netbox/netbox/manage.py createsuperuser"
# Captura do IP de forma mais robusta
echo "=== Configuração de Rede ==="

# Tenta pegar IP da interface (exclui loopback e NAT padrão do Vagrant)
IP_ADDR=$(ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -vE '127.0.0.1|10.0.2.15' | head -n 1)

# Fallbacks
if [ -z "$IP_ADDR" ]; then
    IP_ADDR=$(hostname -I | awk '{print $1}')
fi

if [ -z "$IP_ADDR" ]; then
    IP_ADDR="SEU_IP_AQUI"   # último recurso
    echo "⚠️  Não foi possível detectar o IP automaticamente."
fi

echo "IP da Máquina → $IP_ADDR"
echo "Acesse o Netbox em: http://$IP_ADDR:8000"
echo ""
echo "Para acessar via SSH externo: ssh vagrant@$IP_ADDR (senha: vagrant)"
echo "Ou use internamente: vagrant ssh"
echo ""
echo "=================================================="
