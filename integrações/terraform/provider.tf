terraform {
  required_providers {
    netbox = {
      source  = "e-breuninger/netbox"
      version = "~> 5.3.0"
    }
  }
}

provider "netbox" {
  server_url = "http://192.168.249.175:8000"
  api_token  = var.netbox_token
}