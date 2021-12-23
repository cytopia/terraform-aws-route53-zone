# Terraform module: AWS Route53 Zone

**[Usage](#usage)** |
**[Tagging](#resource-tagging)** |
**[Importing](#importing-existing-resources)** |
**[Examples](#examples)** |
**[Requirements](#requirements)** |
**[Providers](#providers)** |
**[Inputs](#inputs)** |
**[Outputs](#outputs)** |
**[License](#license)**

![terraform workflow](https://github.com/flaconi/terraform-aws-route53-zone/actions/workflows/terraform.yml/badge.svg)
![master workflow](https://github.com/flaconi/terraform-aws-route53-zone/actions/workflows/master.yml/badge.svg)
[![Tag](https://img.shields.io/github/tag/Flaconi/terraform-aws-route53-zone.svg)](https://github.com/Flaconi/terraform-aws-route53-zone/releases)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)

This Terraform module is able to create an arbitrary number of **delegation sets**, **public** and **private** hosted zones for root and delegated domains.

**Public** hosted zones can be created with or without a delegation set.
**Private** hosted zones will always have the default VPC from the current region attached, but can optionally also attach more VPCs from any region.

When adding delegated secondary zones, the **NS records** are added automatically to their corresponding root zone.
The only thing you need to choose, is the TTL (in seconds), of those NS records, per item.


## Usage

```hcl
module "public_zone" {
  source = "github.com/Flaconi/terraform-aws-route53-zone?ref=v1.3.0"

  # Create as many delegation sets by reference name as are required.
  delegation_sets = [
    "root-zone",
    "sub-zone",
  ]

  # Specify your root zones.
  # Tld or subdomain of any level to make this your starting point on the current AWS account.
  # If delegation set is null, it will use AWS defaults. otherwise specify the delegation set
  # by reference name as defined in 'delegation_sets' above.
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

  # Specify your delegated secondary zones (must have their parents defined in 'public_zones')
  # If delegation set is null, it will use AWS defaults. otherwise specify the delegation set
  # by reference name as defined in 'delegation_sets' above.
  # Specify your own name servers or use an empty list to use AWS defaults.
  public_delegated_secondary_zones = [
    {
      name           = "internal.example.org",
      parent         = "example.org",
      ns_ttl         = 30,
      ns_list        = [],
      delegation_set = null,
    },
    {
      name           = "private.example.org",
      parent         = "example.org",
      ns_ttl         = 30,
      ns_list        = ["1.1.1.1", "2.2.2.2", "3.3.3.3", "4.4.4.4"],
      delegation_set = "sub-zone",
    },
  ]

  # Specify your private zones.
  # All private zones will be attached to the default VPC of the current region.
  # Optionally also attach more VPCs by id and region.
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

  # A set of default tags to add to all managed resources.
  # The 'Name' tag will be added automatically with the value of the domain of each item.
  tags = {
    Environment    = "prod"
    Infrastructure = "core"
    Owner          = "terraform"
    Project        = "route53-zone"
  }

  # The default comment to add to all managed resources.
  comment = "Managed by Terraform"
}
```


## Resource tagging

This module will add certain tags to specific resources by default. The `tags` variable extends these and adds additional tags to the resources.

| Tags                | Condition                                         | Description            |
|---------------------|---------------------------------------------------|------------------------|
| `Name`              | Always on all zones                               | Name of domain         |
| `Parent`            | On public delegated zones                         | Name of parent domain  |
| `DelegationSetId`   | On public zones which are using a delegation set  | Name of delegation set |
| `DelegationSetName` | On public zones which are using a delegation set  | ID of delegation set   |


## Importing existing resources

In case you have existing resources and want to import them into this module, use the following commands:

### Delegation sets
```bash
# List available delegation sets
aws route53 list-reusable-delegation-sets

# Define them in tfvars
delegation_sets = [
  "",  # <- If a delegation set is nameless, use an empty string
  "deleg1",
]

# Import them
terraform import 'aws_route53_delegation_set.delegation_sets[""]' <DELEG-ID>
terraform import 'aws_route53_delegation_set.delegation_sets["deleg1"]' <DELEG-ID>
```

### Zones
```bash
# Public root zone
terraform import 'aws_route53_zone.public_root_zones["www.example.com"]' <ZONE-ID>

# Private root zone
terraform import 'aws_route53_zone.private_root_zones["private.example.com"]' <ZONE-ID>
```

### Secondary zones
Secondary zones will create NS records in their parent zone. So in order to import them, you will
first have to identify the currently existing NS record in the parent zone, import it
and then import the secondary zone.
```bash
# List records in parent zone
aws route53 list-resource-record-sets --hosted-zone-id <PARENT-ZONE-ID>

# Import NS record (from parent zone)
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record#import
terraform import 'aws_route53_record.public_delegated_secondary_ns_records["sub.www.example.com"]' <PARENT-ZONE-ID>_sub.www.example.com_NS

# Import Sub zone
terraform import 'aws_route53_zone.public_delegated_secondary_zones["sub.www.example.com"]' <ZONE-ID>
```


## Examples

* [private-domains](examples/private-domains)
* [public-domains](examples/public-domains)
* [public-subdomains](examples/public-subdomains)


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_route53_delegation_set.delegation_sets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_delegation_set) | resource |
| [aws_route53_record.public_delegated_secondary_ns_records](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_zone.private_root_zones](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone) | resource |
| [aws_route53_zone.public_delegated_secondary_zones](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone) | resource |
| [aws_route53_zone.public_root_zones](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone) | resource |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_comment"></a> [comment](#input\_comment) | Default comment to add to all resources. | `string` | `"Managed by Terraform"` | no |
| <a name="input_delegation_sets"></a> [delegation\_sets](#input\_delegation\_sets) | A list of delegation sets to create. You only need to specify the alias names that can then be referenced by other variables in this module via this unique name. A delegation set is a set of four authoritative name servers that you can use with more than one hosted zone. By default, Route 53 assigns a random selection of name servers to each new hosted zone. To make it easier to migrate DNS service to Route 53 for a large number of domains, you can create a reusable delegation set and then associate the reusable delegation set with new hosted zones. | `list(string)` | `[]` | no |
| <a name="input_private_root_zones"></a> [private\_root\_zones](#input\_private\_root\_zones) | Private Route53 root zone (also allows subdomain if this is your root starting point). Note, by default the default VPC will always be attached, even if vpc\_ids or vpc\_tags are empty. | <pre>list(object({<br>    name = string,<br>    vpc_ids = list(object({<br>      id     = string,<br>      region = string,<br>    })),<br>  }))</pre> | `[]` | no |
| <a name="input_public_delegated_secondary_zones"></a> [public\_delegated\_secondary\_zones](#input\_public\_delegated\_secondary\_zones) | A list of public Route53 delegated secondary zones. Each item must specify its 'parent' by name, which must match the name defined in the 'public\_root\_zones' variables and must also be exactly one level deeper than the corresponding root zone item. By doing so, this module will automatically add nameservers into the root zone to create the delegation. You can also attach a delegation\_set to this zone by its reference name (if it has been defined in the 'delegation\_sets' list) or set it to 'null' to use no delegation set. Additionally you can also define your own name servers for this zone by specifying them in the `ns_list` list or just leave the list empty to use AWS default name server. | <pre>list(object({<br>    name           = string,<br>    parent         = string,<br>    ns_ttl         = number,<br>    ns_list        = list(string),<br>    delegation_set = string,<br>  }))</pre> | `[]` | no |
| <a name="input_public_root_zones"></a> [public\_root\_zones](#input\_public\_root\_zones) | A list of public Route53 root zones. A 'root zone' can be anything from a tld to any level of subdomain, if and only if this is your root starting point for this (sub-)domain on the current AWS account. You can also attach a delegation\_set to this root zone by its reference name (if it has been defined in the 'delegation\_sets' list) or set it to 'null' to use no delegation set. | <pre>list(object({<br>    name           = string,<br>    delegation_set = string,<br>  }))</pre> | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Default tags to additionally apply to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_delegation_sets"></a> [delegation\_sets](#output\_delegation\_sets) | Created delegation sets. |
| <a name="output_private_root_zones"></a> [private\_root\_zones](#output\_private\_root\_zones) | Created private root zones. |
| <a name="output_public_delegated_secondary_ns_records"></a> [public\_delegated\_secondary\_ns\_records](#output\_public\_delegated\_secondary\_ns\_records) | Created NS records in your root zone for delegated secondary zones. |
| <a name="output_public_delegated_secondary_zones"></a> [public\_delegated\_secondary\_zones](#output\_public\_delegated\_secondary\_zones) | Created public delegated secondary zones. |
| <a name="output_public_root_zones"></a> [public\_root\_zones](#output\_public\_root\_zones) | Created public root zones. |

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
public_delegated_secondary_ns_records = {
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
public_delegated_secondary_zones = {
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
