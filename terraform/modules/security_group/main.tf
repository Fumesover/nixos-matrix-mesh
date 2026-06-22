resource "exoscale_security_group" "this" {
  name = var.name
}

resource "exoscale_security_group_rule" "this" {
  for_each = var.rules

  security_group_id = exoscale_security_group.this.id

  type        = each.value.type
  protocol    = each.value.protocol
  description = each.value.description

  cidr                   = each.value.cidr
  public_security_group  = each.value.public_security_group
  user_security_group_id = each.value.user_security_group_id

  start_port = each.value.start_port
  end_port   = each.value.end_port
  icmp_type  = each.value.icmp_type
  icmp_code  = each.value.icmp_code
}

check "no_unmanaged_rules" {
  data "exoscale_security_group_rules" "current" {
    security_group_id = exoscale_security_group.this.id
  }

  assert {
    condition = length(setsubtract(
      toset([for r in data.exoscale_security_group_rules.current.rules : r.id]),
      toset(values(exoscale_security_group_rule.this)[*].id),
    )) == 0
    error_message = join("\n", concat(
      ["Unmanaged rules detected in security group '${var.name}':"],
      [for r in data.exoscale_security_group_rules.current.rules :
        "  - ${r.id} (${r.type} ${r.protocol} ${coalesce(r.cidr, r.public_security_group, r.user_security_group_id, "?")})"
        if !contains(values(exoscale_security_group_rule.this)[*].id, r.id)
      ],
    ))
  }
}
