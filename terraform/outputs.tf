resource "local_file" "hosts" {
  content = jsonencode({
    for name, inst in exoscale_compute_instance.instance : name => {
      ip   = inst.public_ip_address
      ipv6 = inst.ipv6_address
    }
  })
  filename = "${path.module}/../hosts.json"
}
