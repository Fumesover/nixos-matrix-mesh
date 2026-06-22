module "sg_default" {
  source = "./modules/security_group"
  name   = "default"
  rules = {
    ping_ipv4 = { description = "Ping IPv4", type = "ingress", protocol = "icmp", cidr = "0.0.0.0/0", icmp_type = 8, icmp_code = 0 }
    ping_ipv6 = { description = "Ping IPv6", type = "ingress", protocol = "icmpv6", cidr = "::/0", icmp_type = 128, icmp_code = 0 }
  }
}

module "sg_https" {
  source = "./modules/security_group"
  name   = "https"
  rules = {
    https_ipv4 = { description = "https", type = "ingress", cidr = "0.0.0.0/0", start_port = 443, end_port = 443 }
    https_ipv6 = { description = "https-v6", type = "ingress", cidr = "::/0", start_port = 443, end_port = 443 }
    http_ipv4  = { type = "ingress", cidr = "0.0.0.0/0", start_port = 80, end_port = 80 }
    http_ipv6  = { type = "ingress", cidr = "::/0", start_port = 80, end_port = 80 }
  }
}

module "sg_mail" {
  source = "./modules/security_group"
  name   = "mail"
  rules = {
    smtp_ipv4         = { description = "SMTP:v4", type = "ingress", cidr = "0.0.0.0/0", start_port = 25, end_port = 25 }
    smtp_ipv6         = { description = "SMTP:v6", type = "ingress", cidr = "::/0", start_port = 25, end_port = 25 }
    imap_ipv4         = { description = "IMAP4:v4", type = "ingress", cidr = "0.0.0.0/0", start_port = 143, end_port = 143 }
    imap_ipv6         = { description = "IMAP4:v6", type = "ingress", cidr = "::/0", start_port = 143, end_port = 143 }
    esmtp_ipv4        = { description = "ESMTP:v4", type = "ingress", cidr = "0.0.0.0/0", start_port = 465, end_port = 465 }
    esmtp_ipv6        = { description = "ESMTP:v6", type = "ingress", cidr = "::/0", start_port = 465, end_port = 465 }
    esmtp_tls_ipv4    = { description = "ESMTP:v4 with STARTTLS", type = "ingress", cidr = "0.0.0.0/0", start_port = 587, end_port = 587 }
    esmtp_tls_ipv6    = { description = "ESMTP:v6 with STARTTLS", type = "ingress", cidr = "::/0", start_port = 587, end_port = 587 }
    imaps_ipv4        = { description = "IMAP4:v4", type = "ingress", cidr = "0.0.0.0/0", start_port = 993, end_port = 993 }
    imaps_ipv6        = { description = "IMAP4:v6", type = "ingress", cidr = "::/0", start_port = 993, end_port = 993 }
    managesieve_ipv4  = { description = "ManageSieve", type = "ingress", cidr = "0.0.0.0/0", start_port = 4190, end_port = 4190 }
    managesieve_ipv6  = { description = "ManageSieve", type = "ingress", cidr = "::/0", start_port = 4190, end_port = 4190 }
  }
}

module "sg_ssh" {
  source = "./modules/security_group"
  name   = "ssh"
  rules = {
    ssh_ipv4 = { description = "SSH", type = "ingress", cidr = "0.0.0.0/0", start_port = 22, end_port = 22 }
    ssh_ipv6 = { type = "ingress", cidr = "::/0", start_port = 22, end_port = 22 }
  }
}

module "sg_torrent" {
  source = "./modules/security_group"
  name   = "torrent"
  rules = {
    torrent_tcp_ipv4 = { type = "ingress", cidr = "0.0.0.0/0", start_port = 51413, end_port = 51413 }
    torrent_udp_ipv4 = { type = "ingress", protocol = "udp", cidr = "0.0.0.0/0", start_port = 51413, end_port = 51413 }
  }
}
