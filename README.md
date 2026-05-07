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
  - [1. Clone o repositório:](#1-clone-o-repositório)
  - [2. (Opcional) Configure suas preferências:](#2-opcional-configure-suas-preferências)
  - [3. Execute o script de instalação:](#3-execute-o-script-de-instalação)
- [🖥️ Como Usar](#️-como-usar)
  - [Credenciais de Primeiro Acesso](#credenciais-de-primeiro-acesso)
- [🔧 Troubleshooting](#-troubleshooting)
  - [NetBox demora para iniciar](#netbox-demora-para-iniciar)
  - [Porta já em uso](#porta-já-em-uso)
  - [Como reiniciar o NetBox](#como-reiniciar-o-netbox)
- [📁 Estrutura do Projeto](#-estrutura-do-projeto)
- [📚 Documentação Adicional](#-documentação-adicional)
- [🛠️ Tecnologias Utilizadas](#️-tecnologias-utilizadas)
- [Referências](#referências)

---

Este projeto facilita a instalação do NetBox utilizando Docker e seus plugins (opcional).

# 📋 Pré-requisitos

Esse ambiente foi testado com os requisitos abaixo:

- **Sistema:** Ubuntu 22.04 LTS.
- **Memória:** Mínimo de 4GB de RAM.
- **Processamento:** 2 CPUs (vCPUs).
- **Acesso:** Usuário com privilégios de `sudo`.

---

# ⚙️ Instalação

O processo é automatizado através de um script de instalação. Siga os passos abaixo:

## 1. Clone o repositório:

```bash
sudo git clone https://github.com/marlon-iac/netbox-docker.git /opt/netbox-docker
```

## 2. (Opcional) Configure suas preferências:

O projeto utiliza um arquivo `.env` para configurações personalizadas. **Recomendamos fortemente** que você revise essas configurações antes da instalação.

```bash
cd /opt/netbox-docker
cp .env.example .env
nano .env  # Edite porta, senha, versão, etc.
```

**Principais variáveis (em `.env`):**
- `NETBOX_VERSION`: Versão da imagem Docker (padrão: `v4.5.8-4.0.2`)
- `NETBOX_PORT`: Porta de acesso (padrão: `8000`)
- `SUPERUSER_NAME`: Usuário admin (padrão: `admin`)
- `SUPERUSER_PASSWORD`: Senha do admin (padrão: `Admin@1234567890`)
- `TIME_ZONE`: Fuso horário (padrão: `America/Sao_Paulo`)

> ⚠️ **Senhas de Banco e Redis:** O script `install.sh` gera senhas fortes automaticamente (padrão oficial) se estiverem vazias ou fracas (`netbox`). Você também pode definir suas próprias senhas antes de executar.
> 🔐 **Secret Key:** O Django `SECRET_KEY` é gerado automaticamente se estiver vazio.

**Exemplo de senhas geradas (padrão oficial):**
- `POSTGRES_PASSWORD`: `J5brHrAXFLQSif0K`
- `REDIS_PASSWORD`: `H733Kdjndks81`
- `REDIS_CACHE_PASSWORD`: `t4Ph722qJ5QHeQ1qfu36` (diferente do Redis!)

> 💡 **Dica:** O arquivo `.env` é ignorado pelo Git (`.gitignore`), então suas senhas nunca serão versionadas!

## 3. Execute o script de instalação:

```bash
cd /opt/netbox-docker && sudo ./install.sh
```

O script irá:
- Instalar o Docker (se necessário)
- Ler as variáveis do seu `.env` (ou criar um `.env` padrão automaticamente)
- Baixar as imagens do NetBox na versão configurada
- Configurar o NetBox com Docker como um serviço automático do sistema (`systemd`)

> ⏳ **Primeira inicialização:** O NetBox pode levar até **10 minutos** na primeira vez (inicialização do banco de dados). Aguarde o script terminar!

---

# 🖥️ Como Usar

Após o término da instalação, o NetBox estará disponível em:

- **URL:** `http://<IP-DO-SEU-SERVIDOR>:<PORTA>` (ou a porta configurada no `.env`)

## Credenciais de Primeiro Acesso

- **Usuário:** `admin` (ou o configurado em `SUPERUSER_NAME` no `.env`)
- **Senha:** `Admin@1234567890` (ou a configurada em `SUPERUSER_PASSWORD` no `.env`)

> ⚠️ **IMPORTANTE:** Por segurança, altere a senha do usuário `admin` imediatamente após o primeiro login.

---

# 🔧 Troubleshooting

## NetBox demora para iniciar

Na primeira instalação, o banco de dados PostgreSQL precisa ser inicializado, o que pode levar até **10 minutos**.

**Sintomas:** Containers ficam como "unhealthy" ou o script parece travado.

**Solução:**
1. Aguarde o tempo necessário (o script `install.sh` aguarda até 15 minutos)
2. Verifique o status: `cd /opt/netbox-docker/netbox && docker compose ps`
3. Veja os logs: `docker compose logs -f netbox`

## Porta já em uso

Se a porta configurada (padrão 8000) já estiver em uso, o script exibirá um erro.

**Solução:**
1. Altere a variável `NETBOX_PORT` no seu arquivo `.env`
2. Reinicie o serviço: `systemctl restart netbox`

## Como reiniciar o NetBox

```bash
sudo systemctl restart netbox
```

---

# 📁 Estrutura do Projeto

| Diretório/Arquivo | Descrição |
|-------------------|-----------|
| `docs/` | Documentação detalhada sobre procedimentos específicos |
| `integrações/` | Documentações e exemplos de integrações com NetBox |
| `netbox/` | Repositório oficial do `netbox-docker` (submódulo) |
| `netbox-custom/` | Arquivos e customizações de plugins e netbox-docker |
| `netbox-custom/netbox/` | Arquivo docker customizado para o netbox-docker |
| `netbox-custom/netbox-diode/` | Arquivos para o plugin do Diode |
| `netbox-custom/netbox-slurpit/` | Arquivos para o plugin do Slurpit |
| `.env.example` | Exemplo de arquivo de configuração (copie para `.env`) |
| `install.sh` | Script que automatiza toda a configuração inicial |

---

# 📚 Documentação Adicional

Para demais guias, consulte os arquivos na pasta [`docs/`](./docs/).

- [Diode](./docs/plugins/diode-install.md): Instruções para instalação do plugin `diode`
- [Terraform](./integrações/terraform/README.md)
- [PyATS](./integrações/pyats+netbox/README.md)

---

# 🛠️ Tecnologias Utilizadas

- **NetBox (v4.5.8-4.0.2):** IPAM/DCIM open source.
  - *Versão alterável via variável `NETBOX_VERSION` no arquivo `.env`*
- **Docker & Docker Compose:** Para facilidade de execução.
- **PostgreSQL:** Banco de dados.
- **Redis:** Para cache e gerenciamento de tarefas em segundo plano.
- **Ubuntu 22.04:** SO utilizado.

---

# Referências

- [netbox-docker-wiki](https://github.com/netbox-community/netbox-docker/wiki/)
