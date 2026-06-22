module "sg_default" {
  source = "./modules/security_group"
  name   = "default"
  rules  = {}
}

module "sg_https" {
  source = "./modules/security_group"
  name   = "https"
  rules  = {}
}

module "sg_mail" {
  source = "./modules/security_group"
  name   = "mail"
  rules  = {}
}

module "sg_ssh" {
  source = "./modules/security_group"
  name   = "ssh"
  rules = {
    ssh_ipv4 = { description = "SSH", type = "INGRESS", cidr = "0.0.0.0/0", start_port = 22, end_port = 22 }
    ssh_ipv6 = { description = "", type = "INGRESS", cidr = "::/0", start_port = 22, end_port = 22 }
  }
}

module "sg_torrent" {
  source = "./modules/security_group"
  name   = "torrent"
  rules  = {}
}
