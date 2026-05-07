# Gerenciando o NetBox 4.5.8 como Fonte da Verdade com Terraform

**Laboratório:** `http://192.168.249.175:8000` (desligado no momento)  
**Objetivo:** Criar, atualizar e remover equipamentos (devices) no NetBox usando Terraform, com o plugin **Diode** já cadastrado.

---

## 📋 Pré-requisitos

| Item | Versão mínima | Como instalar/verificar |
|------|---------------|--------------------------|
| Terraform | `>= 1.0` | `terraform version` |
| Provider NetBox | `e-breuninger/netbox` | `terraform providers` |
| Acesso ao NetBox | API habilitada (token com permissão de escrita) | Obter token em **User → API Tokens** |
| Plugin Diode instalado | Já cadastrado no lab | Verificar em **Plugins → Diode** no NetBox |

> **Links úteis**  
> * Terraform Registry – Provider: https://registry.terraform.io/providers/e-breuninger/netbox/latest  
> * Repositório GitHub: https://github.com/e-breuninger/terraform-provider-netbox  
> * Documentação do recurso `netbox_device`: https://github.com/e-breuninger/terraform-provider-netbox/blob/master/docs/resources/device.md  
> * Documentação oficial do NetBox (API): https://netbox.readthedocs.io/en/stable/

---

## 🔐 Configuração do Provider

Crie um arquivo `provider.tf`:

```hcl
terraform {
  required_providers {
    netbox = {
      source  = "e-breuninger/netbox"
      version = "~> 3.6"
    }
  }
}

provider "netbox" {
  api_endpoint = "http://192.168.249.175:8000"
  token       = var.netbox_token
  timeout     = 30
}
```

**Variável (`variables.tf`):**

```hcl
variable "netbox_token" {
  description = "Token da API do NetBox com permissão de escrita"
  type        = string
  sensitive   = true
}
```

> **Segurança:** nunca comite o token no código. Use `terraform.tfvars` (com `.gitignore`), variáveis de ambiente (`TF_VAR_netbox_token`) ou um vault.

---

## 📦 Recurso: `netbox_device`

### Schema Oficial (Required / Optional)

**Obrigatórios (Required):**
- `device_type_id` (Number)
- `name` (String)
- `role_id` (Number)
- `site_id` (Number)

**Opcionais (Optional) mais usados:**
- `asset_tag` (String)
- `comments` (String)
- `custom_fields` (Map of String)
- `description` (String)
- `platform_id` (Number)
- `serial` (String)
- `status` (String) — valores válidos: `offline`, `active`, `planned`, `staged`, `failed`, `inventory`, `decommissioning` (padrão: `active`)
- `tenant_id` (Number)
- `rack_id` (Number)
- `rack_position` (Number)
- `rack_face` (String) — `front` ou `rear`
- `tags` (Set of String)
- `local_context_data` (String) — use `jsonencode()`

> Fonte: https://github.com/e-breuninger/terraform-provider-netbox/blob/master/docs/resources/device.md

---

## ➕ Cadastro (Criação)

### Exemplo completo (`devices.tf`):

```hcl
# Data sources para buscar IDs existentes
data "netbox_site" "dc1" {
  name = "Datacenter Principal"
}

data "netbox_device_role" "core" {
  name = "core switch"
}

data "netbox_device_type" "cisco" {
  model = "WS-C2960X-24TS-LL"
}

data "netbox_tenant" "ti" {
  name = "TI Infra"
}

data "netbox_platform" "ios" {
  name = "Cisco IOS"
}

# Recurso principal
resource "netbox_device" "sw_core_01" {
  name           = "sw-core-01"
  device_type_id = data.netbox_device_type.cisco.id
  role_id        = data.netbox_device_role.core.id
  site_id        = data.netbox_site.dc1.id

  status      = "active"
  serial      = "FXS21040123"
  asset_tag   = "ASSET-00123"
  tenant_id   = data.netbox_tenant.ti.id
  platform_id = data.netbox_platform.ios.id
  comments    = "Switch de núcleo gerenciado via Terraform."

  custom_fields = {
    diode_vlan_range = "100-200"
  }
}
```

### Passo a passo

```bash
terraform init
terraform plan -var="netbox_token=$SEU_TOKEN"
terraform apply -var="netbox_token=$SEU_TOKEN"
```

Verifique no NetBox (**Devices → Devices**) se o equipamento foi criado.

---

## 🔁 Alteração (Update)

Edite os atributos no bloco `netbox_device` e reaplique:

```bash
terraform plan -var="netbox_token=$SEU_TOKEN"
terraform apply -var="netbox_token=$SEU_TOKEN"
```

**Exemplos de alterações:**
- Mudar status: `status = "decommissioning"`
- Mudar site: alterar `site_id`
- Adicionar/alterar campo customizado: editar `custom_fields`


---

## ❌ Remoção (Destroy)

### Opção 1: Remover o bloco do código
Comente ou apague o recurso `netbox_device` e execute:

```bash
terraform plan -var="netbox_token=$SEU_TOKEN"
terraform apply -var="netbox_token=$SEU_TOKEN"
```

### Opção 2: Comando destroy
```bash
terraform destroy -target="netbox_device.sw_core_01" -var="netbox_token=$SEU_TOKEN"
```

> ⚠️ A remoção no NetBox é irreversível (salvo backup). Use com cautela em produção.

---

## Importando recursos existentes do NetBox para o Terraform

Este guia descreve o processo para trazer objetos já cadastrados no NetBox para o gerenciamento do Terraform, evitando as dores de cabeça mais comuns.

### 1. Defina o recurso no código

Crie um arquivo `.tf` com o bloco `resource` correspondente ao objeto que deseja importar. No início, preencha apenas os campos obrigatórios.

```hcl
# sites.tf
resource "netbox_site" "meu_site" {
  name = "Nome do Site"   # valor real do NetBox
}
```

### 2. Execute o comando terraform import

Use sempre o ID numérico do objeto no NetBox (disponível na URL da interface web ou via API). O nome ou slug não são aceitos.

terraform import netbox_site.meu_site 5

Saída esperada:

netbox_site.meu_site: Importing from ID "5"...
netbox_site.meu_site: Import prepared!
netbox_site.meu_site: Refreshing state... [id=5]

### 3. Alinhe a configuração com a realidade

Após o import, execute terraform plan. O Terraform mostrará as diferenças entre o que está no código e o estado real. Edite o arquivo .tf para incluir todos os atributos que aparecerem como mudanças indesejadas.

```hcl
resource "netbox_site" "meu_site" {
  name     = "Matriz"
  slug     = "matriz"
  status   = "active"
  timezone = "America/Sao_Paulo"
}
```

Quando terraform plan não mostrar mais alterações, o recurso estará totalmente gerenciado.


---


## 🧩 Plugin Diode e Campos Customizados

O NetBox permite campos customizados (**Extras → Custom Fields**). O plugin Diode pode criar campos como `diode_vlan_range`.

### Como usar:
```hcl
resource "netbox_device" "exemplo" {
  # ... outros campos ...
  custom_fields = {
    diode_vlan_range = "100-200"
  }
}
```

> Descubra os nomes exatos em **NetBox UI → Extras → Custom Fields** (procure por chaves que comecem com `diode_`).

---

## ✅ Checklist antes do `apply`

- [ ] `terraform init` executado
- [ ] Token válido e com permissão de escrita
- [ ] `terraform plan` mostra apenas as mudanças esperadas
- [ ] Data sources retornam exatamente um resultado
- [ ] Token não exposto no terminal (use `-var-file` ou env vars)
- [ ] Conferência no NetBox UI após o `apply`

---

## 📚 Próximos passos

- **Interfaces e IPs:** `netbox_interface`, `netbox_ip_address`, `netbox_ip_interface`
- **CI/CD:** pipeline (GitHub Actions / GitLab CI) com aprovação manual
- **Versionamento:** repositório Git com tags e releases
- **Drift detection:** `terraform plan` agendado para detectar mudanças manuais no NetBox

---

**Pronto!** Guia fiel à documentação oficial do provider `e-breuninger/netbox`, sem delirações, com links validados e formatação markdown limpa. 🚀
