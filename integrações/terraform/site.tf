resource "netbox_site" "SPA" {
  name      = "SPA"
  slug = "spa"
  comments = "Site SPA"
  status    = "active"
  timezone = var.timezone
  tags      = [netbox_tag.terraform.name]
}

resource "netbox_site" "XV" {
  name = "XV"
  slug = "xv"
  comments = "Site XV"
  status    = "active"
  timezone = var.timezone
  tags      = [netbox_tag.terraform.name]
}