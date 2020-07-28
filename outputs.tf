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
# Route53 Public Root Zones
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
# Route53 Public Subdomain Zones
# -------------------------------------------------------------------------------------------------
#output "local_public_subdomain_zones" {
#  value       = local.public_subdomain_zones
#  description = "Transformed public subdomain zones."
#}

#output "local_public_subdomain_default_ns_records" {
#  value       = local.public_subdomain_default_ns_records
#  description = "Transformed public subdomain default ns records."
#}

#output "local_public_subdomain_custom_ns_records" {
#  value       = local.public_subdomain_custom_ns_records
#  description = "Transformed public subdomain custom ns records."
#}

output "public_subdomain_zones" {
  value       = aws_route53_zone.public_subdomain_zones
  description = "Created public subdomain zones."
}

output "public_subdomain_default_ns_records" {
  value       = aws_route53_record.public_subdomain_default_ns_records
  description = "Created public subdomain default ns records."
}

output "public_subdomain_custom_ns_records" {
  value       = aws_route53_record.public_subdomain_custom_ns_records
  description = "Created public subdomain default ns records."
}
