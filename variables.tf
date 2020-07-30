# -------------------------------------------------------------------------------------------------
# Optional Variables
# -------------------------------------------------------------------------------------------------
variable "delegation_sets" {
  type        = list(string)
  default     = []
  description = "A set of four authoritative name servers that you can use with more than one hosted zone. By default, Route 53 assigns a random selection of name servers to each new hosted zone. To make it easier to migrate DNS service to Route 53 for a large number of domains, you can create a reusable delegation set and then associate the reusable delegation set with new hosted zones."
}

variable "public_root_zones" {
  type = list(object({
    name           = string,
    delegation_set = string,
  }))
  default     = []
  description = "Route53 root zone (also allows subdomain if this is your root starting point). Set delegation_set to 'null' to use no delegation set."
}

variable "public_secondary_zones" {
  type = list(object({
    name           = string,
    parent         = string,
    ns_ttl         = number,
    ns_servers     = list(string),
    delegation_set = string,
  }))
  default     = []
  description = "Route53 secondary zone ('parent' zone must be specified as well). Set delegation_set to 'null' to use no delegation set. Use empty 'ns_servers' list to use AWS default nameserver."
}

variable "tags" {
  type        = map
  default     = {}
  description = "Default tags to additionally apply to all resources."
}

variable "comment" {
  type        = string
  default     = "Managed by Terraform"
  description = "Default comment to add to all resources."
}
