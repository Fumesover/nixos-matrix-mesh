locals {
  instances = {
    "nixos-host-1" = { zone = "ch-gva-2", type = "standard.medium", disk_size = 50, reverse_dns = "mail.parou.eu", security_group_ids = [ module.sg_mail.security_group_id ] }
    "nixos-host-2" = { zone = "ch-gva-2", type = "standard.medium", disk_size = 50, reverse_dns = "" }

    "nixos-tuwumesh-1" = { zone = "ch-gva-2", type = "standard.small", disk_size = 10, reverse_dns = "" }
    "nixos-tuwumesh-2" = { zone = "ch-dk-2",  type = "standard.small", disk_size = 10, reverse_dns = "" }
    "nixos-tuwumesh-3" = { zone = "at-vie-1", type = "standard.small", disk_size = 10, reverse_dns = "" }
    "nixos-tuwumesh-4" = { zone = "bg-sof-1", type = "standard.small", disk_size = 10, reverse_dns = "" }
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

  security_group_ids = concat(
    try(each.value.security_group_ids, []),
    [
      module.sg_default.security_group_id,
      module.sg_ssh.security_group_id,
      module.sg_https.security_group_id,
    ],
  )

  lifecycle {
    ignore_changes = [template_id]
  }
}

