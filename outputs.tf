#
# Note: local_* values are for debugging purposes
#

# -------------------------------------------------------------------------------------------------
# Route53 Delegation Sets
# -------------------------------------------------------------------------------------------------
output "delegation_sets" {
  value       = aws_route53_delegation_set.delegation_sets
  description = "Created delegation sets."
}


# -------------------------------------------------------------------------------------------------
# Public Route53 Root Zones
# -------------------------------------------------------------------------------------------------
#output "local_public_root_zones" {
#  value       = local.public_root_zones
#  description = "Transformed public root zones."
#}

output "public_root_zones" {
  value       = aws_route53_zone.public_root_zones
  description = "Created public root zones."
}


# -------------------------------------------------------------------------------------------------
# Public Route53 Subdomain Zones (secondary)
# -------------------------------------------------------------------------------------------------
#output "local_public_secondary_zones" {
#  value       = local.public_secondary_zones
#  description = "Transformed public secondary zones."
#}

#output "local_public_secondary_ns_records" {
#  value       = local.public_secondary_ns_records
#  description = "Transformed public secondary ns records."
#}

output "public_secondary_zones" {
  value       = aws_route53_zone.public_secondary_zones
  description = "Created public secondary zones."
}

output "public_secondary_ns_records" {
  value       = aws_route53_record.public_secondary_ns_records
  description = "Created public secondary ns records."
}


# -------------------------------------------------------------------------------------------------
# Private Route53 Root Zones
# -------------------------------------------------------------------------------------------------
#output "local_private_root_zones" {
#  value       = local.private_root_zones
#  description = "Transformed private root zones."
#}

output "private_root_zones" {
  value       = aws_route53_zone.private_root_zones
  description = "Created private root zones."
}
