# -------------------------------------------------------------------------------------------------
# Delegation sets
# -------------------------------------------------------------------------------------------------
resource "aws_route53_delegation_set" "delegation_sets" {
  for_each = { for val in var.delegation_sets : val => val }

  reference_name = each.value
}


# -------------------------------------------------------------------------------------------------
# Public root zones
# -------------------------------------------------------------------------------------------------
resource "aws_route53_zone" "public_root_zones" {
  for_each = local.public_root_zones

  name    = each.value.name
  comment = var.comment

  delegation_set_id = each.value.deleg_id

  tags = merge(
    map("Name", each.value.name),
    map("DelegationSetId", each.value.deleg_id),
    map("DelegationSetName", each.value.deleg_name),
    var.tags
  )

  depends_on = [aws_route53_delegation_set.delegation_sets]
}


# -------------------------------------------------------------------------------------------------
# Public secondary zones
# -------------------------------------------------------------------------------------------------
resource "aws_route53_zone" "public_secondary_zones" {
  for_each = local.public_secondary_zones

  name    = each.value.name
  comment = var.comment

  delegation_set_id = each.value.deleg_id

  tags = merge(
    map("Name", each.value.name),
    map("Parent", each.value.parent),
    map("DelegationSetId", each.value.deleg_id),
    map("DelegationSetName", each.value.deleg_name),
    var.tags
  )

  depends_on = [aws_route53_zone.public_root_zones]
}


# -------------------------------------------------------------------------------------------------
# Public secondary zone  dns records
# -------------------------------------------------------------------------------------------------
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone#public-subdomain-zone
resource "aws_route53_record" "public_secondary_ns_records" {
  for_each = local.public_secondary_ns_records

  zone_id = aws_route53_zone.public_root_zones[each.value.parent]["id"]
  name    = each.value.name
  type    = "NS"
  ttl     = each.value.ns_ttl

  records = each.value.ns_servers

  depends_on = [aws_route53_zone.public_secondary_zones]
}
