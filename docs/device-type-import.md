# Guia completo: Importando Device Types no NetBox

Este guia foi criado para dar instruções de como importar os device types via script.

---

## 1. Visão geral do fluxo

Neste tutorial, usaremos um projeto chamado [Device-Type-Library-Import](https://github.com/marcinpsk/Device-Type-Library-Import) para preencher o NetBox com modelos prontos de equipamentos (como switches Cisco, roteadores Juniper, etc.). Fazer isso manualmente seria um trabalho gigantesco!

---

## 2. Validação de compatibilidade

O teste desse guia foi executado na versão **4.5.8** do Netbox.

> **O Device-Type-Library-Import é compatível?**
>
> A versão atual do script e a biblioteca por trás dele (geralmente a `pynetbox`) estão constantemente sendo ajustadas pela comunidade. Para o NetBox 4.x, pode ser que você esbarre em pequenos *warnings* (avisos) ou incompatibilidades bem específicas dependendo das dependências, mas na grande maioria dos casos o importador principal funciona muito bem!

---

## 3. Visão geral

**O que é o Device-Type-Library-Import?**

É um script feito pela comunidade que acessa a biblioteca oficial e pública de [Device Types](https://github.com/netbox-community/devicetype-library) do GitHub para injetar todos eles de uma vez.

**IMPORTANTE:** Ele **NÃO é um plugin do NetBox**. Não precisa ser instalado "dentro" do netbox. Ele age como um client, desde que a origem da execução tenha conectividade com o netbox.

---

## 4. Pré-requisitos

Para que isso funcione, você vai precisar de:
1. Netbox.
2. UV.
3. **Um API Token criado no NetBox**.

### Como criar o seu API Token no NetBox:

1. Acesse seu NetBox pelo navegador
2. No canto **Superior Direito**, clique no seu **Nome de Usuário** e em seguida selecione **Tokens de API**.
3. Clique em **Adicionar um Token**.
4. Crie um token (v1 ou v2) com permissões de escrita.
5. Copie o token (uma vez criado, não será possível obter as informações do token após fechar)

---

## 5. Preparação do ambiente

1. Abra o Terminal do seu computador.
2. Verifique se tem conectividade com o netbox a partir da maquina que irá executar o script.

```bash
curl -I http://<hostname_netbox>:<port_netbox>
```

---

## 6. Usando Python local

### 6.1: Virtualenv

Clone o repositório:

```bash
git clone https://github.com/marcinpsk/Device-Type-Library-Import.git
cd Device-Type-Library-Import
```

### 6.2: Instale as dependencias com uv

```bash
uv sync
```

### 6.3: Configuração do script

Copie o arquivo .env de exemplo e altere as variáveis

```bash
cp .env.example .env
vim .env
```

> ⚠️ **Tokens:** Existe uma diferença nas configurações do token baseadas na versão (v1 ou v2)
>
> Para v1, o token deve ser configurado da seguinte forma:
>
> `NETBOX_TOKEN=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx`
>
> Para v2, você precisa incluir o prefixo "nbt_", a chave bearer key, um ponto (.), seguido do secret token:
>
>`NETBOX_TOKEN=nbt_XXXXXXXXXXXX.xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx`

---

## 7. Execução do import

Para executar o script use o comando abaixo:

```bash
uv run nb-dt-import.py
```

> ⚠️ **Cuidado:** Ao executar o comando sem especificar o vendor, todos os vendors serão importados para o Netbox.

Para importar por vendor, utilize o comando

```bash
uv run nb-dt-import.py --vendors <nome_do_vendor>
```

Durante a execução, o script irá:

1. Obter os device-types do repositório.
2. Conectar ao Netbox.
3. Cruzar os dados para averiguar se algo já existe ou não.

Para mais detalhes de como remover, fazer update, variáveis extras.. etc, consulte a documentação oficial em [Device-Type-Library-Import](https://github.com/marcinpsk/Device-Type-Library-Import)

## 8 Referencia

- [Device-Type-Library-Import](https://github.com/marcinpsk/Device-Type-Library-Import)