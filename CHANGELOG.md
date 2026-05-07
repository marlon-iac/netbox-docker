# 📝 Changelog

Todas as alterações notáveis neste projeto serão documentadas neste arquivo.

O formato é baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/),
e este projeto segue [Semantic Versioning](https://semver.org/lang/pt-BR/).

## [Não Lançado]

### ✨ Adicionado
- Suporte a arquivo `.env` para customização (Issue #1)
- Seção de Troubleshooting no README.md
- Arquivo `CONTRIBUTING.md` com guia de contribuição
- Arquivo `LICENSE` (MIT)
- Badges no README (Docker Pulls, Issues, License, Stars)
- Este CHANGELOG.md

### 🔄 Alterado
- `docker-compose.override.yml` refatorado para usar variáveis `${VAR}`
- `install.sh` melhorado com:
  - Carregamento automático do `.env`
  - Validação de porta antes de subir
  - Healthcheck com verificação HTTP e timeout de 15min
  - Feedback visual com tempo decorrido
- `README.md` reescrito com:
  - Seção de configuração `.env`
  - Seção de Troubleshooting
  - Tabelas para estrutura do projeto
  - Foco em usuários leigos

### 🐛 Corrigido
- `.gitignore` atualizado para ignorar `.env` (segurança)

### ⚠️ Depreciado
- (Nenhum)

### ❌ Removido
- (Nenhum)

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
