variable "netbox_token" {
  description = "Token da API do NetBox com permissão de escrita"
  type        = string
  sensitive   = true
}

variable "timezone" {
  description = "Timezone"
  type        = string
  sensitive   = false
  default = "America/Sao_Paulo"
}