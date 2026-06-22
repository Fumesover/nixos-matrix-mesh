locals {
  instances = {
    "nixos-host-1" = { zone = "ch-gva-2", type = "standard.medium", disk_size = 50, reverse_dns = "mail.parou.eu" }
    "nixos-host-2" = { zone = "ch-gva-2", type = "standard.medium", disk_size = 50, reverse_dns = "" }
  }
}

data "exoscale_template" "my_template" {
  zone = "ch-gva-2"
  name = "Linux Ubuntu 22.04 LTS 64-bit"
}

resource "exoscale_compute_instance" "instance" {
  for_each = local.instances

  zone = each.value.zone
  name = each.key

  template_id = data.exoscale_template.my_template.id
  type        = each.value.type
  disk_size   = each.value.disk_size

  ipv6        = true
  reverse_dns = each.value.reverse_dns

  ssh_keys = ["fumesover@yubikey-1"]

  lifecycle {
    ignore_changes = [template_id]
  }
}

