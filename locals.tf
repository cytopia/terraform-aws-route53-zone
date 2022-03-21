# -------------------------------------------------------------------------------------------------
# Public root zones
# -------------------------------------------------------------------------------------------------
locals {
  # Transforms from:
  # ----------------
  # var.public_root_zones = [
  #   {
  #     name = "example1.tld",
  #     delegation_set = "deleg-name",
  #   },
  #   {
  #     name = "example2.tld",
  #     delegation_set = null,
  #   },
  # ]
  #
  # Transforms into:
  # ----------------
  # local.public_root_zones = {
  #   "example1.tld" {
  #     "name" = "example1.tld"
  #     "deleg_id" = "N0XXXXXXXXXXXXX"
  #     "deleg_name" = "deleg-name"
  #   },
  #   "example2.tld" {
  #     "name" = "example2.tld"
  #     "deleg_id" = null
  #     "deleg_name" = null
  #   },
  # }
  public_root_zones = {
    for zone in var.public_root_zones : zone.name => {
      name       = zone.name
      deleg_id   = zone.delegation_set != null ? aws_route53_delegation_set.delegation_sets[zone.delegation_set]["id"] : null
      deleg_name = zone.delegation_set
    }
  }
}


# -------------------------------------------------------------------------------------------------
# Public secondary zones
# -------------------------------------------------------------------------------------------------
locals {
  # Transforms from:
  # ----------------
  # var.public_delegated_secondary_zones = [
  #   {
  #     name = "intranet.example.tld",
  #     root = "example.tld",
  #     nameservers = [],
  #     ns_ttl = 30,
  #     delegation_set = "deleg-name",
  #   },
  #   {
  #     name = "private.example.tld",
  #     root = "example.tld",
  #     nameservers = ["1,1.1.1", "2.2.2.2", "3.3.3.3", "4.4.4.4"],
  #     delegation_set = null,
  #     ns_ttl = 30,
  #   },
  # ]
  #
  # Transforms into:
  # ----------------
  # local.public_delegated_secondary_zones = {
  #   "intranet.example1.tld" {
  #     "name" = "intranet.example.tld"
  #     "parent" = "example.tld",
  #     "deleg_id" = "N0XXXXXXXXXXXXX"
  #     "deleg_name" = "deleg-name"
  #   },
  #   "private.example1.tld" {
  #     "name" = "private.example.tld"
  #     "parent" = "example.tld",
  #     "deleg_id" = null
  #     "deleg_name" = ""
  #   },
  # }
  # local.public_delegated_secondary_default_ns_records = {
  #   "intranet.example1.tld" {
  #     "name" = "intranet.example.tld"
  #     "parent" = "example.tld",
  #   },
  # }
  # local.public_delegated_secondary_custom_ns_records = {
  #   "private.example1.tld" {
  #     "name" = "private.example.tld"
  #     "parent" = "example.tld",
  #     "nameservers" = ["1,1.1.1", "2.2.2.2", "3.3.3.3", "4.4.4.4"],
  #     "ns_ttl" = 30,
  #   },
  # }
  public_delegated_secondary_zones = {
    for zone in var.public_delegated_secondary_zones : zone.name => {
      name       = zone.name
      parent     = zone.parent
      deleg_id   = zone.delegation_set != null ? aws_route53_delegation_set.delegation_sets[zone.delegation_set]["id"] : null
      deleg_name = zone.delegation_set
    }
  }
  public_delegated_secondary_ns_records = {
    for zone in var.public_delegated_secondary_zones : zone.name => {
      name    = zone.name
      parent  = zone.parent
      ns_ttl  = zone.ns_ttl
      ns_list = length(zone.ns_list) == 0 ? aws_route53_zone.public_delegated_secondary_zones[zone.name]["name_servers"] : zone.ns_list
    }
  }
}

# -------------------------------------------------------------------------------------------------
# Public tertiary zones
# -------------------------------------------------------------------------------------------------
locals {
  # Transforms from:
  # ----------------
  # var.public_delegated_tertiary_zones = [
  #   {
  #     name = "division.intranet.example.tld",
  #     root = "intranet.example.tld",
  #     nameservers = [],
  #     ns_ttl = 30,
  #     delegation_set = "deleg-name",
  #   },
  #   {
  #     name = "division.private.example.tld",
  #     root = "private.example.tld",
  #     nameservers = ["1,1.1.1", "2.2.2.2", "3.3.3.3", "4.4.4.4"],
  #     delegation_set = null,
  #     ns_ttl = 30,
  #   },
  # ]
  #
  # Transforms into:
  # ----------------
  # local.public_delegated_tertiary_zones = {
  #   "division.intranet.example.tld" {
  #     "name" = "division.intranet.example.tld"
  #     "parent" = "example.tld",
  #     "deleg_id" = "N0XXXXXXXXXXXXX"
  #     "deleg_name" = "deleg-name"
  #   },
  #   "division.private.example.tld" {
  #     "name" = "division.private.example.tld"
  #     "parent" = "private.example.tld",
  #     "deleg_id" = null
  #     "deleg_name" = ""
  #   },
  # }
  # local.public_delegated_tertiary_default_ns_records = {
  #   "division.intranet.example.tld" {
  #     "name" = "division.intranet.example.tld"
  #     "parent" = "intranet.example.tld",
  #   },
  # }
  # local.public_delegated_tertiary_custom_ns_records = {
  #   "division.private.example.tld" {
  #     "name" = "division.private.example.tld"
  #     "parent" = "private.example.tld",
  #     "nameservers" = ["1,1.1.1", "2.2.2.2", "3.3.3.3", "4.4.4.4"],
  #     "ns_ttl" = 30,
  #   },
  # }
  public_delegated_tertiary_zones = {
    for zone in var.public_delegated_tertiary_zones : zone.name => {
      name       = zone.name
      parent     = zone.parent
      deleg_id   = zone.delegation_set != null ? aws_route53_delegation_set.delegation_sets[zone.delegation_set]["id"] : null
      deleg_name = zone.delegation_set
    }
  }
  public_delegated_tertiary_ns_records = {
    for zone in var.public_delegated_tertiary_zones : zone.name => {
      name    = zone.name
      parent  = zone.parent
      ns_ttl  = zone.ns_ttl
      ns_list = length(zone.ns_list) == 0 ? aws_route53_zone.public_delegated_tertiary_zones[zone.name]["name_servers"] : zone.ns_list
    }
  }
}

# -------------------------------------------------------------------------------------------------
# Private root zones
# -------------------------------------------------------------------------------------------------
locals {
  # Transforms from:
  # ----------------
  # var.private_root_zones = [
  #   {
  #     name     = "example1.tld",
  #     vpc_ids  = [{"id"="vpc-11111", "region"="eu-central"}],
  #   },
  #   {
  #     name     = "example2.tld",
  #     vpc_ids  = [{"id"="vpc-11111", "region"="eu-central"}],
  #   },
  # ]
  #
  # Transforms into:
  # ----------------
  # local.private_root_zones = {
  #   "example1.tld" {
  #     "name"    = "example1.tld"
  #      vpc_ids  = [{"id"="vpc-11111", "region"="eu-central"}],
  #   },
  #   "example2.tld" {
  #     "name"    = "example2.tld"
  #      vpc_ids  = [{"id"="vpc-11111", "region"="eu-central"}],
  #   },
  private_root_zones = {
    for zone in var.private_root_zones : zone.name => {
      name    = zone.name
      vpc_ids = zone.vpc_ids
    }
  }
}
