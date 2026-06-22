resource "exoscale_security_group" "this" {
  name = var.name

  rule = [for k, v in var.rules : {
    type                   = v.type
    protocol               = v.protocol
    description            = v.description
    cidr                   = v.cidr
    public_security_group  = v.public_security_group
    user_security_group_id = v.user_security_group_id
    start_port             = v.start_port
    end_port               = v.end_port
    icmp_type              = v.icmp_type
    icmp_code              = v.icmp_code
  }]
}
