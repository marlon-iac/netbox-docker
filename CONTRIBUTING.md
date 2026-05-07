# 📝 Guia de Contribuição - NetBox Docker

Obrigado por considerar contribuir com este projeto! Este documento descreve as diretrizes para contribuições.

## 📋 Índice

- [Como Contribuir](#como-contribuir)
- [Padrão de Commits](#padrão-de-commits)
- [Fluxo de Trabalho (Git Flow)](#fluxo-de-trabalho)
- [Padrão de Código](#padrão-de-código)
- [Testes](#testes)
- [Pull Requests](#pull-requests)

---

## 🚀 Como Contribuir

1. **Fork** este repositório (opcional, se você não tiver acesso direto)
2. **Clone** o repositório: `git clone https://github.com/marlon-iac/netbox-docker.git`
3. **Crie uma branch** para sua feature: `git checkout -b feature/minha-feature`
4. **Faça suas alterações**
5. **Commit** seguindo nosso padrão (veja abaixo)
6. **Push** para sua branch: `git push origin feature/minha-feature`
7. **Abra um Pull Request** descrevendo suas alterações

---

## 📝 Padrão de Commits

Utilizamos o padrão **Conventional Commits** (em português):

### Estrutura:
```
<tipo>(escopo opcional): <descrição curta>

[corpo opcional]
```

### Tipos permitidos:
- `feat:` - Nova funcionalidade
- `fix:` - Correção de bug
- `docs:` - Alterações na documentação
- `style:` - Formatação, faltando alterações de código
- `refactor:` - Refatoração de código
- `test:` - Adição ou correção de testes
- `chore:` - Atualizações de tarefas, configurações, etc.

### Exemplos:
```bash
feat: adicionar suporte a .env para customização

fix: corrigir timeout no script de instalação

docs: atualizar README com seção de troubleshooting

chore: adicionar arquivos padrão GitHub
```

---

## 🌿 Fluxo de Trabalho (Git Flow)

### Branches principais:
- `main`: Código estável e pronto para produção
- `develop`: Branch de desenvolvimento (se houver)

### Tipos de branches:
- `feature/*`: Para novas funcionalidades
- `fix/*`: Para correções de bugs
- `docs/*`: Para alterações na documentação
- `refactor/*`: Para refatorações

### Exemplo de fluxo:
```bash
# Criar branch a partir da main
git checkout main
git pull origin main
git checkout -b feature/nova-funcionalidade

# Fazer alterações, commits, etc.
git add .
git commit -m "feat: adicionar nova funcionalidade"

# Push para o repositório remoto
git push origin feature/nova-funcionalidade

# Abrir Pull Request no GitHub
```

---

## 💻 Padrão de Código

### Shell Script (install.sh):
- Use `set -euo pipefail` no início
- Comente trechos complexos
- Use variáveis em caixa alta para configurações
- Valide entradas e dependências

### Docker Compose:
- Use variáveis de ambiente (`${VAR:-padrão}`)
- Comente seções complexas
- Sempre use `restart: unless-stopped` para serviços principais

### Documentação (Markdown):
- Escreva em **português**
- Use emojis para tornar mais visual (padrão do projeto)
- Foque em **usuários leigos** (sem jargões desnecessários)
- Use tabelas para estruturar informações

---

## ✅ Testes

Antes de abrir um Pull Request, certifique-se de:

1. **Testar a instalação** em uma VM limpa (Ubuntu 22.04)
2. **Verificar se o NetBox sobe** corretamente
3. **Testar diferentes configurações** no `.env`
4. **Validar a documentação** (links, formatação)

### Comando de teste rápido:
```bash
# Em uma VM Ubuntu 22.04 limpa
git clone <seu-fork>
cd netbox-docker
cp .env.example .env
sudo ./install.sh
# Aguarde e teste: curl http://localhost:8000
```

---

## 🔀 Pull Requests

### Antes de abrir um PR:
- [ ] O código foi testado?
- [ ] A documentação foi atualizada?
- [ ] O commit segue o padrão Conventional Commits?
- [ ] O PR está vinculado a uma Issue (se aplicável)?

### Template de PR:
```markdown
## 📋 Alterações Realizadas
- ...

## 🔗 Issue Relacionada
Fecha #N

## 🧪 Como Testar
...

## ✅ Checklist
- [ ] Testado em VM Ubuntu 22.04
- [ ] Documentação atualizada
- [ ] Commits seguindo padrão
```

### Processo de Review:
1. Um mantenedor revisará seu PR
2. Feedback será dado via comentários
3. Ajustes podem ser solicitados
4. Após aprovação, o PR será mergeado

---

## 📞 Dúvidas?

Abra uma **Issue** no repositório ou entre em contato com os mantenedores.

**Obrigado por contribuir! 🚀**
