module "sg_default" {
  source = "./modules/security_group"
  name   = "default"
  rules  = {
      {
        "cidr": "0.0.0.0/0",
        "description": "Ping IPv4",
        "end_port": null,
        "icmp_code": 0,
        "icmp_type": 8,
        "id": "8629fffe-b796-4ee1-a347-d42ba63ed1a2",
        "protocol": "icmp",
        "public_security_group": null,
        "start_port": null,
        "type": "ingress",
        "user_security_group_id": null
      },
      {
        "cidr": "::/0",
        "description": "Ping IPv6",
        "end_port": null,
        "icmp_code": 0,
        "icmp_type": 128,
        "id": "5c4fcce1-0ce1-4863-8574-3deea60431ca",
        "protocol": "icmpv6",
        "public_security_group": null,
        "start_port": null,
        "type": "ingress",
        "user_security_group_id": null
      }

  }
}

module "sg_https" {
  source = "./modules/security_group"
  name   = "https"
  rules  = {
              {
                "cidr": "0.0.0.0/0",
                "description": "https",
                "end_port": 443,
                "icmp_code": null,
                "icmp_type": null,
                "id": "efef1c2a-084b-4f97-bf39-20c0e1a75461",
                "protocol": "tcp",
                "public_security_group": null,
                "start_port": 443,
                "type": "ingress",
                "user_security_group_id": null
              },
              {
                "cidr": "::/0",
                "description": "https-v6",
                "end_port": 443,
                "icmp_code": null,
                "icmp_type": null,
                "id": "2ad10561-239a-443f-8ad2-9b06c95009c0",
                "protocol": "tcp",
                "public_security_group": null,
                "start_port": 443,
                "type": "ingress",
                "user_security_group_id": null
              },
              {
                "cidr": "0.0.0.0/0",
                "description": "",
                "end_port": 80,
                "icmp_code": null,
                "icmp_type": null,
                "id": "907e5f20-5168-47d5-a70d-c5da56921c41",
                "protocol": "tcp",
                "public_security_group": null,
                "start_port": 80,
                "type": "ingress",
                "user_security_group_id": null
              },
              {
                "cidr": "::/0",
                "description": "",
                "end_port": 80,
                "icmp_code": null,
                "icmp_type": null,
                "id": "cdaf106f-fd2f-4418-90d2-a8b5c7b01e6b",
                "protocol": "tcp",
                "public_security_group": null,
                "start_port": 80,
                "type": "ingress",
                "user_security_group_id": null
              }

  }
}

module "sg_mail" {
  source = "./modules/security_group"
  name   = "mail"
  rules  = {
            {
              cidr        = "0.0.0.0/0"
              description = "SMTP:v4"
              end_port    = 25
              id          = "a5f888df-01ad-4812-9f14-03b010bc1360"
              protocol    = "tcp"
              start_port  = 25
              type        = "ingress"
            },
          {
              cidr        = "::/0"
              description = "SMTP:v6"
              end_port    = 25
              id          = "833aa642-01bd-4fac-b2c6-34a28f9bfc42"
              protocol    = "tcp"
              start_port  = 25
              type        = "ingress"
            },
          {
              cidr        = "0.0.0.0/0"
              description = "IMAP4:v4"
              end_port    = 143
              id          = "c9f16472-56fd-498d-91cf-8ad1dbd1e4ae"
              protocol    = "tcp"
              start_port  = 143
              type        = "ingress"
            },
          {
              cidr        = "::/0"
              description = "IMAP4:v6"
              end_port    = 143
              id          = "8485caa7-fd71-4721-a6b1-a74eab0d151d"
              protocol    = "tcp"
              start_port  = 143
              type        = "ingress"
            },
          {
              cidr        = "0.0.0.0/0"
              description = "ESMTP:v4"
              end_port    = 465
              id          = "c969ba45-e115-4453-93c7-28dfc4a321ee"
              protocol    = "tcp"
              start_port  = 465
              type        = "ingress"
            },
          {
              cidr        = "::/0"
              description = "ESMTP:v6"
              end_port    = 465
              id          = "42394b3d-ae83-4fd9-9feb-67401e6ad961"
              protocol    = "tcp"
              start_port  = 465
              type        = "ingress"
            },
          {
              cidr        = "0.0.0.0/0"
              description = "ESMTP:v4 with STARTTLS"
              end_port    = 587
              id          = "7bce7cfd-cff3-40b6-be0c-981147b412dd"
              protocol    = "tcp"
              start_port  = 587
              type        = "ingress"
            },
          {
              cidr        = "::/0"
              description = "ESMTP:v6 with STARTTLS"
              end_port    = 587
              id          = "c711769c-c5d4-4930-affe-c3c2f2cc17d9"
              protocol    = "tcp"
              start_port  = 587
              type        = "ingress"
            },
          {
              cidr        = "0.0.0.0/0"
              description = "IMAP4:v4"
              end_port    = 993
              id          = "e3b8d031-9933-497b-bca8-65b071ef6eb3"
              protocol    = "tcp"
              start_port  = 993
              type        = "ingress"
            },
          {
              cidr        = "::/0"
              description = "IMAP4:v6"
              end_port    = 993
              id          = "0da19360-c210-4854-a558-3392a7e96f55"
              protocol    = "tcp"
              start_port  = 993
              type        = "ingress"
            },
          {
              cidr        = "0.0.0.0/0"
              description = "ManageSieve"
              end_port    = 4190
              id          = "34613899-dab5-47d6-a18f-5f4aadda9a06"
              protocol    = "tcp"
              start_port  = 4190
              type        = "ingress"
            },
          {
              cidr        = "::/0"
              description = "ManageSieve"
              end_port    = 4190
              id          = "4ed752f6-634c-4d42-af6a-0aaf635fc166"
              protocol    = "tcp"
              start_port  = 4190
              type        = "ingress"
            },

  }
}

module "sg_ssh" {
  source = "./modules/security_group"
  name   = "ssh"
  rules = {
    ssh_ipv4 = { description = "SSH", type = "ingress", cidr = "0.0.0.0/0", start_port = 22, end_port = 22 }
    ssh_ipv6 = { description = "", type = "ingress", cidr = "::/0", start_port = 22, end_port = 22 }
  }
}

module "sg_torrent" {
  source = "./modules/security_group"
  name   = "torrent"
  rules  = {
      {
        "cidr": "0.0.0.0/0",
        "description": "",
        "end_port": 51413,
        "icmp_code": null,
        "icmp_type": null,
        "id": "0a251a8c-139b-45fc-af34-459cae62c199",
        "protocol": "tcp",
        "public_security_group": null,
        "start_port": 51413,
        "type": "ingress",
        "user_security_group_id": null
      },
      {
        "cidr": "0.0.0.0/0",
        "description": "",
        "end_port": 51413,
        "icmp_code": null,
        "icmp_type": null,
        "id": "a4b9cb48-e8a7-44b5-805e-da685134482a",
        "protocol": "udp",
        "public_security_group": null,
        "start_port": 51413,
        "type": "ingress",
        "user_security_group_id": null
      }

  }
}
