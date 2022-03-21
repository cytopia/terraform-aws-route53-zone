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

output "public_root_zones" {
  value       = aws_route53_zone.public_root_zones
  description = "Created public root zones."
}


# -------------------------------------------------------------------------------------------------
# Public Route53 Subdomain Zones (secondary)
# -------------------------------------------------------------------------------------------------

output "public_delegated_secondary_zones" {
  value       = aws_route53_zone.public_delegated_secondary_zones
  description = "Created public delegated secondary zones."
}

output "public_delegated_secondary_ns_records" {
  value       = aws_route53_record.public_delegated_secondary_ns_records
  description = "Created NS records in your root zone for delegated secondary zones."
}


# -------------------------------------------------------------------------------------------------
# Public Route53 Subdomain Zones (tertiary)
# -------------------------------------------------------------------------------------------------

output "public_delegated_tertiary_zones" {
  value       = aws_route53_zone.public_delegated_secondary_zones
  description = "Created public delegated tertiary zones."
}

output "public_delegated_tertiary_ns_records" {
  value       = aws_route53_record.public_delegated_secondary_ns_records
  description = "Created NS records in your root zone for delegated tertiary zones."
}


# -------------------------------------------------------------------------------------------------
# Private Route53 Root Zones
# -------------------------------------------------------------------------------------------------

output "private_root_zones" {
  value       = aws_route53_zone.private_root_zones
  description = "Created private root zones."
}
