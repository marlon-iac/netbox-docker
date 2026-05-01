# NetBox Docker

Este projeto facilita a instalação do NetBox utilizando Docker e seus plugins (opcional).

## 📋 Pré-requisitos

Esse ambiente foi testado com os requisitos abaixo:

- **Sistema:** Ubuntu 22.04 LTS.
- **Memória:** Mínimo de 4GB de RAM.
- **Processamento:** 2 CPUs (vCPUs).
- **Acesso:** Usuário com privilégios de `sudo`.

## ⚙️ Instalação

O processo é automatizado através de um script de instalação. Siga os passos abaixo:

1. **Clone o repositório:**

    ```bash
    sudo git clone https://github.com/marlon-iac/netbox-docker.git /opt/netbox-docker
    ```

2. **Execute o script de instalação:**

    ```bash
    cd /opt/netbox-docker && sudo ./install.sh
    ```

O script irá instalar o Docker, baixar as imagens e configurar o NetBox com Docker como um serviço automático do sistema (`systemd`).

## 🖥️ Como Usar

Após o término da instalação, o NetBox estará disponível em:

- **URL:** `http://<IP-DO-SEU-SERVIDOR>:8000`

### Credenciais de Primeiro Acesso

- **Usuário:** `admin`
- **Senha:** `Admin@1234567890`

> ⚠️ **IMPORTANTE:** Por segurança, altere a senha do usuário `admin` imediatamente após o primeiro login.

## 📁 Estrutura do Projeto

|- docs/: Documentação detalhada sobre procedimentos específicos.
|-- plugins/: Documentação sobre plugins do netbox.
|- integrações/: Documentações e exemplos de integrações com netbox
|- netbox/: Repositório oficial do `netbox-docker` (submódulo).
|- netbox-custom/: Diretório onde ficam arquivos e customizações de plugin e netbox-docker.
|-- netbox/: Diretório com o arquivo docker customizado para o netbox-docker.
|-- netbox-diode/: Diretório com os arquivos para o plugin do Diode.
|-- netbox-slurpit/: Diretório com os arquivos para o plugin do slurpit.
|- install.sh: Script que automatiza toda a configuração inicial.

## 📚 Documentação Adicional

Para demais guias, consulte os arquivos na pasta [`docs/`](./docs/).

- [diode](./docs/plugins/diode-install.md): Instruções para instalação do plugin `diode`

## 🛠️ Tecnologias Utilizadas

- **NetBox (v4.5.8-4.0.2):**.
- **Docker & Docker Compose:** Para facilidade de execução.
- **PostgreSQL:** Banco de dados.
- **Redis:** Para cache e gerenciamento de tarefas em segundo plano.
- **Ubuntu 22.04:** SO utilizado.

## Referencias

- [netbox-docker-wiki](https://github.com/netbox-community/netbox-docker/wiki/)
