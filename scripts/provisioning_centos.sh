#!/bin/bash
# ==============================================================================
# Netbox Docker - Instalação no CentoS 9 Stream
# ==============================================================================

set -euo pipefail  # Para o script parar em caso de erro

SHARED_DIR="/home/vagrant/shared"
LOCAL_DIR="/home/vagrant"

echo "=================================================="
echo "🚀 Iniciando provisionamento da máquina Netbox..."
echo "=================================================="
echo ""

# Atualização e Dependências
echo "[1] <<<<< Atualizando sistema >>>>>"
sudo dnf update -y

# Removendo Docker (se instalado) - para evitar conflitos de dependências
echo "[2] <<<<< Removendo Docker >>>>>"
sudo dnf remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine

# Setup do repositório Docker
echo "[3] <<<<< Setup do repositório Docker >>>>>"
sudo dnf -y install dnf-plugins-core
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# Instalação do Docker
echo "[4] <<<<< Instalando Docker >>>>>"
sudo dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# Iniciar e habilitar Docker
echo "[5] Iniciando e habilitando Docker..."
sudo systemctl enable --now docker

# Adicionar usuário vagrant ao grupo docker
# o usuário precisa ter permissão de admin para alguns diretórios do Docker, então adicionamos ele ao grupo docker
echo "[6] Adicionando vagrant ao grupo docker..."
sudo usermod -aG docker vagrant
newgrp docker

# Criando links simbólicos para os arquivos compartilhados
echo "[7] <<<<< Instalando Netbox Docker >>>>>"
cd ${LOCAL_DIR}
ln -sf ${SHARED_DIR}/netbox-docker ./netbox-docker

# Iniciando o Docker Compose com o Netbox
echo "[8] Iniciando NetBox (pode demorar na primeira vez)..."
cd ${LOCAL_DIR}/netbox-docker
cp ${SHARED_DIR}/docker-compose.override.yml docker-compose.override.yml
docker compose pull
docker compose up -d

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
echo "Acesse o Netbox em http://$IP_ADDR:8000 e use as credenciais criadas para login."
echo ""

echo "=== Configuração de Rede ==="
# Captura o IP da interface que não seja a loopback (127.0.0.1) 
# Prioriza a rede pública/privada definida no Vagrantfile
IP_ADDR=$(ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v "127.0.0.1" | grep -v "10.0.2.15" | head -n 1)

# Se não achar o IP da rede pública, tenta pegar qualquer um exceto localhost
if [ -z "$IP_ADDR" ]; then
    IP_ADDR=$(hostname -I | awk '{print $1}')
fi

echo "IP da Máquina → $IP_ADDR"
echo "Para acessar via SSH externo: ssh vagrant@$IP_ADDR (senha: vagrant)"
echo "Ou use internamente: vagrant ssh"
echo ""
echo "=================================================="