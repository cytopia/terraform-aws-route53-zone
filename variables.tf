# -------------------------------------------------------------------------------------------------
# Optional Public Zone Variables
# -------------------------------------------------------------------------------------------------
variable "delegation_sets" {
  type        = list(string)
  default     = []
  description = "A list of delegation sets to create. You only need to specify the alias names that can then be referenced by other variables in this module via this unique name. A delegation set is a set of four authoritative name servers that you can use with more than one hosted zone. By default, Route 53 assigns a random selection of name servers to each new hosted zone. To make it easier to migrate DNS service to Route 53 for a large number of domains, you can create a reusable delegation set and then associate the reusable delegation set with new hosted zones."
}

variable "public_root_zones" {
  type = list(object({
    name           = string,
    delegation_set = string,
  }))
  default     = []
  description = "A list of public Route53 root zones. A 'root zone' can be anything from a tld to any level of subdomain, if and only if this is your root starting point for this (sub-)domain on the current AWS account. You can also attach a delegation_set to this root zone by its reference name (if it has been defined in the 'delegation_sets' list) or set it to 'null' to use no delegation set."
}

variable "public_delegated_secondary_zones" {
  type = list(object({
    name           = string,
    parent         = string,
    ns_ttl         = number,
    ns_list        = list(string),
    delegation_set = string,
  }))
  default     = []
  description = "A list of public Route53 delegated secondary zones. Each item must specify its 'parent' by name, which must match the name defined in the 'public_root_zones' variables and must also be exactly one level deeper than the corresponding root zone item. By doing so, this module will automatically add nameservers into the root zone to create the delegation. You can also attach a delegation_set to this zone by its reference name (if it has been defined in the 'delegation_sets' list) or set it to 'null' to use no delegation set. Additionally you can also define your own name servers for this zone by specifying them in the `ns_list` list or just leave the list empty to use AWS default name server."
}

variable "public_delegated_tertiary_zones" {
  type = list(object({
    name           = string,
    parent         = string,
    ns_ttl         = number,
    ns_list        = list(string),
    delegation_set = string,
  }))
  default     = []
  description = "A list of public Route53 delegated tertiary zones. Each item must specify its 'parent' by name, which must match the name defined in the 'public_delegated_secondary_zones' variables and must also be exactly one level deeper than the corresponding root zone item. By doing so, this module will automatically add nameservers into the root zone to create the delegation. You can also attach a delegation_set to this zone by its reference name (if it has been defined in the 'delegation_sets' list) or set it to 'null' to use no delegation set. Additionally you can also define your own name servers for this zone by specifying them in the `ns_list` list or just leave the list empty to use AWS default name server."
}


# -------------------------------------------------------------------------------------------------
# Optional Private Zone Variables
# -------------------------------------------------------------------------------------------------
variable "private_root_zones" {
  type = list(object({
    name = string,
    vpc_ids = list(object({
      id     = string,
      region = string,
    })),
  }))
  default     = []
  description = "Private Route53 root zone (also allows subdomain if this is your root starting point). Note, by default the default VPC will always be attached, even if vpc_ids or vpc_tags are empty."
}


# -------------------------------------------------------------------------------------------------
# Optional Misc Variables
# -------------------------------------------------------------------------------------------------
variable "tags" {
  type        = map(string)
  default     = {}
  description = "Default tags to additionally apply to all resources."
}

variable "comment" {
  type        = string
  default     = "Managed by Terraform"
  description = "Default comment to add to all resources."
}
