# 📝 Changelog

Todas as alterações notáveis neste projeto serão documentadas neste arquivo.

O formato é baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/),
e este projeto segue [Semantic Versioning](https://semver.org/lang/pt-BR/).

## [Não Lançado]

### ✨ Adicionado
- Suporte a arquivo `.env` global na raiz do projeto (Issue #1)
- Badges no README (Docker Pulls, Issues, License, Stars)
- Este CHANGELOG.md (padrão Keep a Changelog)
- Documentação em português (pt-BR)

### 🔄 Alterado
- `docker-compose.override.yml`: uso de `environment` com `${VAR}` explícitas
  (evita sobrescrever variáveis do projeto oficial netbox-docker)
- `install.sh`:
  - Carregamento do `.env` via `set -a` e `source` para variáveis de shell
  - Remoção da geração automática de `SECRET_KEY` (agora via comando oficial Python)
  - Validação de porta via variável `${NETBOX_PORT}` do .env
  - Timeout de espera do NetBox reduzido para 5 minutos (30 tentativas)

### 🐛 Corrigido
- `.gitignore` atualizado para ignorar `.env` (segurança)
- `install.sh`: Correção na passagem de variáveis para o Systemd service (`--env-file`)

### ❌ Removido
- Geração automática de senhas no `install.sh` (função `generate_password` removida)

### 🔐 Segurança
- Credenciais não são mais hardcoded (usam `.env`)
- Arquivo `.env` adicionado ao `.gitignore`

---

## [1.0.0] - 2024-05-07

### ✨ Adicionado
- Versão inicial do projeto
- Script `install.sh` para instalação automática
- Suporte ao NetBox v4.5.8-4.0.2
- Documentação básica (README.md)
- Estrutura de diretórios (`docs/`, `integrações/`, `netbox-custom/`)
- Suporte a plugins (Diode, Slurpit)

---

## 📋 Legenda

- ✨ `Adicionado` para novas funcionalidades.
- 🔄 `Alterado` para mudanças em funcionalidades existentes.
- 🐛 `Corrigido` para correção de erros.
- ⚠️ `Depreciado` para funcionalidades que serão removidas em breve.
- ❌ `Removido` para funcionalidades removidas.
- 🔐 `Segurança` em caso de vulnerabilidades.
