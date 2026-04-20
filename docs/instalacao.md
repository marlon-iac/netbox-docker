# Sobre

Procedimento de como fazer instalação manual do netbox com docker

# Pre-requisitos

- Ubuntu 22.04
- 2048 de memória
- 2 CPUS

# Instalação

clone o repositório
```shell
git clone --recurse-submodules https://github.com/marlon-iac/netbox-docker.git
cd netbox-docker
sudo ./install.sh
```

Execute os comandos abaixo com o usuário root

```shell
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive
NETBOX_DIR="/root/netbox-docker/netbox-docker"
NETBOX_PORT=8000

# Remover docker existente
apt remove $(dpkg --get-selections docker.io docker-compose docker-compose-v2 docker-doc podman-docker containerd runc | cut -f1) -y

# Setup do repositório docker
apt-get update -y
apt install ca-certificates curl -y
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Adiciona repositório ao apt sources
tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

# Instalação do Docker
apt-get update -y
apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# Inicialização do docker
systemctl enable --now docker

# Clonar repositório com netbox-docker
apt install git -y
git clone https://github.com/marlon-iac/netbox-docker.git

# Customização da imagem netbox-docker
cp -fv "${NETBOX_CUSTOM_DIR}/docker-compose.override.yml" "${NETBOX_DIR}/docker-compose.override.yml"

# Inicialização do netbox-docker
cd ${NETBOX_DIR}
docker compose pull
docker compose up -d

# Criando systemd para o netbox
cat <<EOF > /etc/systemd/system/netbox.service
[Unit]
Description=NetBox Docker Compose
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
WorkingDirectory=${NETBOX_DIR}/${NETBOX_DIR}
ExecStart=/usr/bin/docker compose up -d --wait
ExecStop=/usr/bin/docker compose down
TimeoutStartSec=500

# Opcional: faz o systemd tentar novamente se o start falhar
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Recarregar systemd e habilitar serviço
systemctl daemon-reexec
systemctl daemon-reload
systemctl enable netbox

# Verificações finais
echo "=================================================="
echo "✅ Provisionamento concluído!"
echo "=================================================="
echo ""
echo "=== Versões instaladas ==="
echo "Docker:  $(docker --version)"
echo "Status Docker: $(systemctl is-active docker)"
echo ""
echo "Execute o comando abaixo para criar o usuário administrador:"
echo ""
echo "docker compose exec netbox /opt/netbox/netbox/manage.py createsuperuser"
echo ""
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
echo "Acesse o Netbox em: http://$IP_ADDR:${NETBOX_PORT}"
echo ""
echo ""
echo "=================================================="
```
