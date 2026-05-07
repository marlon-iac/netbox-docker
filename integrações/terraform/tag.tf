resource "netbox_tag" "terraform" {
  name      = "terraform"
  color_hex = "ff00ff"
  description = "tag para demarcar tudo que foi criado via terraform"
  slug = "terraform"
}