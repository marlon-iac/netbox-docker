# NetBox Docker

Este projeto facilita a instalação do NetBox utilizando Docker.

## 🛠️ Tecnologias Utilizadas

*   **NetBox-Docker (v4.0.2):**
*   **Docker & Docker Compose:**.
*   **PostgreSQL:** Banco de dados relacional.
*   **Redis:** Para cache e gerenciamento de tarefas em segundo plano.
*   **Ubuntu 22.04:** Sistema operacional recomendado para o host.

## 📋 Pré-requisitos

Antes de começar, certifique-se de que seu servidor (físico ou VM) atende aos requisitos mínimos:
*   **Sistema:** Ubuntu 22.04 LTS (recomendado).
*   **Memória:** Mínimo de 2GB de RAM.
*   **Processamento:** 2 CPUs (vCPUs).
*   **Acesso:** Usuário com privilégios de `sudo`.

## ⚙️ Instalação

O processo é automatizado através de um script de instalação. Siga os passos abaixo:

1.  **Clone o repositório:**
    ```bash
    git clone https://github.com/marlon-iac/netbox-docker.git
    cd netbox-docker
    ```

2.  **Execute o script de instalação:**
    ```bash
    sudo ./install.sh
    ```

O script irá instalar o Docker (se necessário), baixar as imagens oficiais e configurar o NetBox como um serviço automático do sistema (`systemd`).

## 🖥️ Como Usar

Após o término da instalação, o NetBox estará disponível em:
*   **URL:** `http://<IP-DO-SEU-SERVIDOR>:8000`

### Credenciais de Primeiro Acesso:
*   **Usuário:** `admin`
*   **Senha:** `Admin@1234567890`

> ⚠️ **IMPORTANTE:** Por segurança, altere a senha do usuário `admin` imediatamente após o primeiro login.

## 📁 Estrutura do Projeto

*   `netbox/`: Contém o código oficial do repositório **[netbox-docker](https://github.com/marlon-iac/netbox-docker)** (usado como submódulo).
*   `netbox-custom/`: Pasta onde ficam customizações e configurações específicas.
*   `docs/`: Documentação detalhada sobre procedimentos específicos.
*   `install.sh`: Script que automatiza toda a configuração inicial.

## ⚠️ Limitações e Observações

*   Esta instalação foi testada especificamente no **Ubuntu 22.04**.

## 📚 Documentação Adicional

Para guias mais avançados, consulte os arquivos na pasta `docs/`:
*   [Guia de Backup](docs/netbox-backup.md) - Como fazer backup.
*   [Guia de Plugins](docs/netbox-plugins.md) - Como estender as funcionalidades.
*   [API REST](docs/netbox-rest_api.md) - Como integrar com outras ferramentas.