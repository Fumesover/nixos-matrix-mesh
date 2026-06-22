variable "name" {
  type        = string
  description = "Name of the security group."
}

variable "rules" {
  type = map(object({
    type                   = string
    protocol               = optional(string, "tcp")
    description            = optional(string, "")
    cidr                   = optional(string)
    public_security_group  = optional(string)
    user_security_group_id = optional(string)
    start_port             = optional(number)
    end_port               = optional(number)
    icmp_type              = optional(number)
    icmp_code              = optional(number)
  }))
  description = "Map of security group rules. Keys are arbitrary identifiers."
}
