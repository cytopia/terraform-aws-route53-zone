# Terraform module: AWS Route53 Zone

[![Build Status](https://travis-ci.org/cytopia/terraform-aws-route53-zone.svg?branch=master)](https://travis-ci.org/cytopia/terraform-aws-route53-zone)
[![Tag](https://img.shields.io/github/tag/cytopia/terraform-aws-route53-zone.svg)](https://github.com/cytopia/terraform-aws-route53-zone/releases)
[![Terraform](https://img.shields.io/badge/Terraform--registry-aws--elb-brightgreen.svg)](https://registry.terraform.io/modules/cytopia/route53-zone/aws/)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)

This Terraform module creates hosted zones for domains and subdomains. All specified hosted zones
can be created with or without a delegation set. NS records for sub zones are added automatically.


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
  public_subdomain_zones = [
    {
      name           = "internal.example.org",
      root           = "example.org",
      ns_ttl         = 30,
      nameservers    = [],
      delegation_set = null,
    },
    {
      name           = "private.example.org",
      root           = "example.org",
      ns_ttl         = 30,
      nameservers    = ["1.1.1.1", "2.2.2.2", "3.3.3.3", "4.4.4.4"],
      delegation_set = "sub-zone",
    },
  ]

  tags = {
    Environment    = "prod"
    Infrastructure = "core"
    Owner          = "terraform"
    Project        = "zones-public"
  }

  comment = "Managed by Terraform"
}
```


## Examples

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
| public\_root\_zones | Route53 root zone (also allows subdomain if this is your root starting point). Set delegation\_set to 'null' to use no delegation set. | <pre>list(object({<br>    name           = string,<br>    delegation_set = string,<br>  }))</pre> | `[]` | no |
| public\_subdomain\_zones | Route53 subdomain zone (root zone must be specified as well). Set delegation\_set to 'null' to use no delegation set. | <pre>list(object({<br>    name           = string,<br>    root           = string,<br>    ns_ttl         = number,<br>    nameservers    = list(string),<br>    delegation_set = string,<br>  }))</pre> | `[]` | no |
| tags | Default tags to additionally apply to all resources. | `map` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| delegation\_sets | Created delegation sets. |
| public\_root\_zones | Created public root zones. |
| public\_subdomain\_custom\_ns\_records | Created public subdomain default ns records. |
| public\_subdomain\_default\_ns\_records | Created public subdomain default ns records. |
| public\_subdomain\_zones | Created public subdomain zones. |

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
public_subdomain_zones = {
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
