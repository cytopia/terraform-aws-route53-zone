# Terraform module: AWS Route53 Zone

[![Build Status](https://travis-ci.org/cytopia/terraform-aws-route53-zone.svg?branch=master)](https://travis-ci.org/cytopia/terraform-aws-route53-zone)
[![Tag](https://img.shields.io/github/tag/cytopia/terraform-aws-route53-zone.svg)](https://github.com/cytopia/terraform-aws-route53-zone/releases)
[![Terraform](https://img.shields.io/badge/Terraform--registry-aws--route53--zone-brightgreen.svg)](https://registry.terraform.io/modules/cytopia/route53-zone/aws/)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)

This Terraform module is able to create **delegation sets**, **public** and **private** hosted zones for root and delegated domains.

**Public** hosted zones can be created with or without a delegation set.
**Private** hosted zones will always have the default VPC from the current region attached, but can optionally also attach more VPC's from any region.

**NS records** for sub zones are added automatically to their corresponding root zone, allowing the user to customize the TTL.


## Usage

```hcl
module "public_zone" {
  source = "github.com/Flaconi/terraform-aws-route53-zone?ref=v1.0.0"

  # Create as many delegation sets as are required
  delegation_sets = [
    "root-zone",
    "sub-zone",
  ]

  # If delegation set is null, it will use AWS defaults.
  public_root_zones = [
    {
      name           = "example.com",
      delegation_set = "root-zones",
    },
    {
      name           = "example.org",
      delegation_set = null,
    },
  ]

  # If delegation set is null, it will use AWS defaults.
  # Specify your own nameserver or use an empty list to use AWS defaults.
  public_secondary_zones = [
    {
      name           = "internal.example.org",
      parent         = "example.org",
      ns_ttl         = 30,
      nameservers    = [],
      delegation_set = null,
    },
    {
      name           = "private.example.org",
      parent         = "example.org",
      ns_ttl         = 30,
      nameservers    = ["1.1.1.1", "2.2.2.2", "3.3.3.3", "4.4.4.4"],
      delegation_set = "sub-zone",
    },
  ]

  # Add private zones
  # All private zones will be attached to the default VPC of the current region.
  # Optionally also attach more VPC's by id and region.
  private_root_zones = [
    {
      name     = "private.loc",
      vpc_ids  = [],
    },
    {
      name     = "private.local",
      vpc_ids  = [{"id": "vpc-xxxxxxxxxx", "region": "eu-central-1"}],
    },
  ]

  tags = {
    Environment    = "prod"
    Infrastructure = "core"
    Owner          = "terraform"
    Project        = "route53-zone"
  }

  comment = "Managed by Terraform"
}
```


## Examples

* [private-domains](examples/private-domains)
* [public-domains](examples/public-domains)
* [public-subdomains](examples/public-subdomains)


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| comment | Default comment to add to all resources. | `string` | `"Managed by Terraform"` | no |
| delegation\_sets | A set of four authoritative name servers that you can use with more than one hosted zone. By default, Route 53 assigns a random selection of name servers to each new hosted zone. To make it easier to migrate DNS service to Route 53 for a large number of domains, you can create a reusable delegation set and then associate the reusable delegation set with new hosted zones. | `list(string)` | `[]` | no |
| private\_root\_zones | Private Route53 root zone (also allows subdomain if this is your root starting point). Note, by default the default VPC will always be attached, even if vpc\_ids or vpc\_tags are empty. | <pre>list(object({<br>    name = string,<br>    vpc_ids = list(object({<br>      id     = string,<br>      region = string,<br>    })),<br>  }))</pre> | `[]` | no |
| public\_root\_zones | Public Route53 root zone (also allows subdomain if this is your root starting point). Set delegation\_set to 'null' to use no delegation set. | <pre>list(object({<br>    name           = string,<br>    delegation_set = string,<br>  }))</pre> | `[]` | no |
| public\_secondary\_zones | Public Route53 secondary zone ('parent' zone must be specified as well). Set delegation\_set to 'null' to use no delegation set. Use empty 'ns\_servers' list to use AWS default nameserver. | <pre>list(object({<br>    name           = string,<br>    parent         = string,<br>    ns_ttl         = number,<br>    ns_servers     = list(string),<br>    delegation_set = string,<br>  }))</pre> | `[]` | no |
| tags | Default tags to additionally apply to all resources. | `map` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| delegation\_sets | Created delegation sets. |
| private\_root\_zones | Created private root zones. |
| public\_root\_zones | Created public root zones. |
| public\_secondary\_ns\_records | Created public secondary ns records. |
| public\_secondary\_zones | Created public secondary zones. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Example output

```bash
$ terraform output
```
```
Outputs:

delegation_sets = {
  "dg0" = {
    "id" = "N0XXXXXXXXXXXXXXXXXXX"
    "name_servers" = [
      "ns-1.awsdns-44.org",
      "ns-2.awsdns-54.co.uk",
      "ns-3.awsdns-14.net",
      "ns-4.awsdns-01.com",
    ]
    "reference_name" = "dg0"
  }
  "dg1" = {
    "id" = "N1XXXXXXXXXXXXXXXXXXX"
    "name_servers" = [
      "ns-5.awsdns-44.org",
      "ns-6.awsdns-54.co.uk",
      "ns-7.awsdns-14.net",
      "ns-8.awsdns-01.com",
    ]
    "reference_name" = "dg1"
  }
}
public_root_zones = {
  "example.org" = {
    "comment" = "Managed by Terraform"
    "delegation_set_id" = "N0XXXXXXXXXXXXXXXXXXX"
    "force_destroy" = false
    "id" = "Z0YYYYYYYYYYYYYYYY"
    "name" = "example.org."
    "name_servers" = [
      "ns-1.awsdns-44.org",
      "ns-2.awsdns-54.co.uk",
      "ns-3.awsdns-14.net",
      "ns-4.awsdns-01.com",
    ]
    "tags" = {
      "DelegationSetId" = "N0XXXXXXXXXXXXXXXXXXX"
      "DelegationSetName" = "dg0"
      "Name" = "example.org"
    }
    "vpc" = []
    "zone_id" = "Z0YYYYYYYYYYYYYYYY"
  }
public_subdomain_default_ns_records = {
  "internal.example.org" = {
    "alias" = []
    "failover_routing_policy" = []
    "fqdn" = "internal.example.org"
    "geolocation_routing_policy" = []
    "id" = "Z1YYYYYYYYYYYYYYYY_internal.example.org_NS"
    "latency_routing_policy" = []
    "name" = "internal.example.org"
    "records" = [
      "ns-5.awsdns-44.org",
      "ns-6.awsdns-54.co.uk",
      "ns-7.awsdns-14.net",
      "ns-8.awsdns-01.com",
    ]
    "ttl" = 30
    "type" = "NS"
    "weighted_routing_policy" = []
    "zone_id" = "Z1YYYYYYYYYYYYYYYY"
  }
}
public_secondary_zones = {
  "internal.example.org" = {
    "comment" = "Managed by Terraform"
    "delegation_set_id" = "N1XXXXXXXXXXXXXXXXXXX"
    "force_destroy" = false
    "id" = "Z1YYYYYYYYYYYYYYYY"
    "name" = "internal.example.org."
    "name_servers" = [
      "ns-5.awsdns-44.org",
      "ns-6.awsdns-54.co.uk",
      "ns-7.awsdns-14.net",
      "ns-8.awsdns-01.com",
    ]
    "tags" = {
      "DelegationSetId" = "N1XXXXXXXXXXXXXXXXXXX"
      "DelegationSetName" = "dg1"
      "Name" = "internal.example.org"
      "Root" = "example.org"
    }
    "vpc" = []
    "zone_id" = "Z1YYYYYYYYYYYYYYYY"
  }
```

## Authors

Module managed by [cytopia](https://github.com/cytopia).

## License

[MIT License](LICENSE)

Copyright (c) 2018 [cytopia](https://github.com/cytopia)
