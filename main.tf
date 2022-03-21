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
    { "Name" = each.value.name },
    { "DelegationSetId" = each.value.deleg_id },
    { "DelegationSetName" = each.value.deleg_name },
    var.tags
  )

  depends_on = [aws_route53_delegation_set.delegation_sets]
}


# -------------------------------------------------------------------------------------------------
# Public secondary zones
# -------------------------------------------------------------------------------------------------
resource "aws_route53_zone" "public_delegated_secondary_zones" {
  for_each = local.public_delegated_secondary_zones

  name    = each.value.name
  comment = var.comment

  delegation_set_id = each.value.deleg_id

  tags = merge(
    { "Name" = each.value.name },
    { "Parent" = each.value.parent },
    { "DelegationSetId" = each.value.deleg_id },
    { "DelegationSetName" = each.value.deleg_name },
    var.tags
  )

  depends_on = [aws_route53_zone.public_root_zones]
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone#public-subdomain-zone
resource "aws_route53_record" "public_delegated_secondary_ns_records" {
  for_each = local.public_delegated_secondary_ns_records

  zone_id = aws_route53_zone.public_root_zones[each.value.parent]["id"]
  name    = each.value.name
  type    = "NS"
  ttl     = each.value.ns_ttl
  records = formatlist("%s.", each.value.ns_list)

  depends_on = [aws_route53_zone.public_delegated_secondary_zones]
}

# -------------------------------------------------------------------------------------------------
# Public tertiary zones
# -------------------------------------------------------------------------------------------------
resource "aws_route53_zone" "public_delegated_tertiary_zones" {
  for_each = local.public_delegated_tertiary_zones

  name    = each.value.name
  comment = var.comment

  delegation_set_id = each.value.deleg_id

  tags = merge(
    { "Name" = each.value.name },
    { "Parent" = each.value.parent },
    { "DelegationSetId" = each.value.deleg_id },
    { "DelegationSetName" = each.value.deleg_name },
    var.tags
  )

  depends_on = [aws_route53_zone.public_delegated_secondary_zones]
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone#public-subdomain-zone
resource "aws_route53_record" "public_delegated_tertiary_ns_records" {
  for_each = local.public_delegated_tertiary_ns_records

  zone_id = aws_route53_zone.public_delegated_secondary_zones[each.value.parent]["id"]
  name    = each.value.name
  type    = "NS"
  ttl     = each.value.ns_ttl
  records = formatlist("%s.", each.value.ns_list)

  depends_on = [aws_route53_zone.public_delegated_tertiary_zones]
}

# -------------------------------------------------------------------------------------------------
# Private root zones
# -------------------------------------------------------------------------------------------------
data "aws_region" "current" {}

resource "aws_route53_zone" "private_root_zones" {
  for_each = local.private_root_zones

  name    = each.value.name
  comment = var.comment

  dynamic "vpc" {
    for_each = { for vpc in each.value.vpc_ids : vpc.id => vpc }
    content {
      vpc_id     = vpc.value.id
      vpc_region = vpc.value.region
    }
  }

  tags = merge(
    { "Name" = each.value.name },
    var.tags
  )

  depends_on = [data.aws_region.current]
}
