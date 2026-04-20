# Guia de Atualização (Upgrade) do NetBox

Este documento descreve como realizar o upgrade de versão do NetBox de forma segura, considerando que o projeto utiliza versões fixas de imagem no arquivo de override.

## ⚠️ Antes de Começar (IMPORTANTE)

1.  **Backup:** Sempre realize um backup completo do banco de dados e dos arquivos de mídia (uploads) antes de qualquer atualização. Veja o [Guia de Backup](netbox-backup.md).
2.  **Migrações:** O NetBox realiza migrações automáticas no banco de dados. Uma vez que o banco é migrado para uma versão superior (ex: 4.5.x), não é garantido que você consiga voltar para uma versão anterior (downgrade).
3.  **Versão Atual:** O projeto está atualmente fixado na versão **v4.5.8-4.0.2**.

---

## 🛠️ Passo a Passo para Upgrade

Se você deseja atualizar para uma nova versão (ex: de 4.5.8 para 4.6.0), siga estes passos:

### 1. Identifique a Imagem Correta
Acesse o [Docker Hub do NetBox](https://hub.docker.com/r/netboxcommunity/netbox/tags) e procure pela tag que combina a versão do NetBox com a versão do repositório docker (neste caso, mantendo o final `-4.0.2`).

### 2. Atualize o Arquivo de Override
Edite o arquivo `netbox-custom/netbox/docker-compose.override.yml` e altere a tag da imagem para as três instâncias: `netbox`, `netbox-worker` e `netbox-housekeeping`.

```yaml
services:
  netbox:
    image: netboxcommunity/netbox:v<NOVA_VERSAO>-4.0.2
  # ... repita para worker e housekeeping
```

### 3. Aplique as Mudanças
Execute o comando abaixo para baixar as novas imagens e reiniciar os containers:

```bash
sudo ./install.sh
```

O script `install.sh` irá:
1.  Copiar o novo override para a pasta de execução.
2.  Baixar as imagens atualizadas (`docker compose pull`).
3.  Reiniciar os containers (`docker compose up -d`), o que disparará automaticamente as migrações de banco de dados.

### 4. Verifique os Logs
Acompanhe os logs para garantir que as migrações ocorreram sem erros:

```bash
cd netbox
docker compose logs -f netbox
```

---

## 🛑 Como Voltar Atrás (Rollback)

Se algo der errado durante o upgrade:
1.  Altere a imagem no `docker-compose.override.yml` de volta para a versão anterior.
2.  Restaure o backup do banco de dados feito antes do início do processo.
3.  Execute o `sudo ./install.sh` novamente.
