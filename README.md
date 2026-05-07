---
title: Netbox Docker
description: Guia de instalação e configuração do NetBox com Docker e seus plugins.
---

[![Docker Pulls](https://img.shields.io/docker/pulls/netboxcommunity/netbox?style=flat-square)](https://hub.docker.com/r/netboxcommunity/netbox)
[![GitHub Issues](https://img.shields.io/github/issues/marlon-iac/netbox-docker?style=flat-square)](https://github.com/marlon-iac/netbox-docker/issues)
[![License: MIT](https://img.shields.io/github/license/marlon-iac/netbox-docker?style=flat-square)](LICENSE)
[![GitHub stars](https://img.shields.io/github/stars/marlon-iac/netbox-docker?style=flat-square)](https://github.com/marlon-iac/netbox-docker/stargazers)

**Sumário**

- [📋 Pré-requisitos](#-pré-requisitos)
- [⚙️ Instalação](#️-instalação)
- [🖥️ Como Usar](#️-como-usar)
- [📁 Estrutura do Projeto](#-estrutura-do-projeto)
- [📚 Documentação Adicional](#-documentação-adicional)
- [🛠️ Tecnologias Utilizadas](#️-tecnologias-utilizadas)
- [Referencias](#referencias)

---

Este projeto facilita a instalação do NetBox utilizando Docker e seus plugins (opcional).

# 📋 Pré-requisitos

Esse ambiente foi testado com os requisitos abaixo:

- **Sistema:** Ubuntu 22.04 LTS.
- **Memória:** Mínimo de 4GB de RAM.
- **Processamento:** 2 CPUs (vCPUs).
- **Acesso:** Usuário com privilégios de `sudo`.

# ⚙️ Instalação

O processo é automatizado através de um script de instalação. Siga os passos abaixo:

1. **Clone o repositório:**

    ```bash
    sudo git clone https://github.com/marlon-iac/netbox-docker.git /opt/netbox-docker
    ```

2. **Ajustes de variável:**

Crie o arquivo .env a partir do .env.example e edite-o conforme necessário

  ```bash
  cp /opt/netbox-docker/.env.example /opt/netbox-docker/.env
  nano /opt/netbox-docker/.env
  ```

3. **Execute o script de instalação:**

    ```bash
    cd /opt/netbox-docker && sudo ./install.sh
    ```

O script irá instalar o Docker, baixar as imagens e configurar o NetBox com Docker como um serviço automático do sistema (`systemd`).

# 🖥️ Como Usar

Após o término da instalação, o NetBox estará disponível em:

- **URL:** `http://<IP-DO-SEU-SERVIDOR>:8000`

As credenciais de primeiro acesso foram as definidas no arquivo `/opt/netbox-docker/.env`

> ⚠️ **IMPORTANTE:** Por segurança, altere a senha do usuário `admin` imediatamente após o primeiro login.

# 📁 Estrutura do Projeto

|- docs/: Documentação detalhada sobre procedimentos específicos.
|-- plugins/: Documentação sobre plugins do netbox.
|- integrações/: Documentações e exemplos de integrações com netbox
|- netbox/: Repositório oficial do `netbox-docker` (submódulo).
|- netbox-custom/: Diretório onde ficam arquivos e customizações de plugin e netbox-docker.
|-- netbox/: Diretório com o arquivo docker customizado para o netbox-docker.
|-- netbox-diode/: Diretório com os arquivos para o plugin do Diode.
|-- netbox-slurpit/: Diretório com os arquivos para o plugin do slurpit.
|- install.sh: Script que automatiza toda a configuração inicial.

# 📚 Documentação Adicional

Para demais guias, consulte os arquivos na pasta [`docs/`](./docs/).

- [diode](./docs/plugins/diode-install.md): Instruções para instalação do plugin `diode`
- [terraform](./integrações/terraform/README.md)
- [pyats](./integrações/pyats+netbox/README.md)

# 🛠️ Tecnologias Utilizadas

- **NetBox (v4.5.8-4.0.2):**.
- **Docker & Docker Compose:** Para facilidade de execução.
- **PostgreSQL:** Banco de dados.
- **Redis:** Para cache e gerenciamento de tarefas em segundo plano.
- **Ubuntu 22.04:** SO utilizado.

# Referencias

- [netbox-docker-wiki](https://github.com/netbox-community/netbox-docker/wiki/)
