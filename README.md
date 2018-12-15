# Terraform module: AWS Route53 Zone

[![Build Status](https://travis-ci.org/cytopia/terraform-aws-route53-zone.svg?branch=master)](https://travis-ci.org/cytopia/terraform-aws-route53-zone)
[![Tag](https://img.shields.io/github/tag/cytopia/terraform-aws-route53-zone.svg)](https://github.com/cytopia/terraform-aws-route53-zone/releases)
[![Terraform](https://img.shields.io/badge/Terraform--registry-aws--route53--zone-brightgreen.svg)](https://registry.terraform.io/modules/cytopia/route53-zone/aws/)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)

This Terraform module creates hosted zones for domains and subdomains. All specified hosted zones
can be created without any delegation, with an already existing delegation set or by creating a
new delegation set for all specified (sub)domains.

This module is also be able to automatically distinguish between domains and subdomains. Subdomains
require additional nameserver records to be set after creating the zone. Custom nameserver can be
supplied via input variables or if left empty, AWS default nameserver will be assigned.


## Usage

```hcl
module "public_zone" {
  source = "github.com/cytopia/terraform-aws-route53-zone?ref=v0.1.0"

  public_hosted_zones = "[
    "example.com",
    "example.org",
  ]

  delegation_set_name = "root-domains"

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
* [public-domains-and-subdomains](examples/public-domains-and-subdomains)


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| public\_hosted\_zones | List of domains or subdomains for which to create public hosted zones. | list | `<list>` | no |
| delegation\_set\_name | Create a shared delegation set among specefied hosted zones domains if not empty. (nmutually exclusive to 'delegation_set_id'). | string | `""` | no |
| delegation\_set\_id | Assign specified hosted zones to a delegation set specified by ID if not empty. (mutually exclusive to 'delegation_set_reference_name'). | string | `""` | no |
| custom\_subdomain\_ns | Hosted zones for subdomains require nameserver to be specified explicitly. You can use this variable to add a list of custom nameserver IP addresses. If left empty it will be populated by four AWS default nameserver. | list | `<list>` | no |
| default\_subdomain\_ns\_ttl | Hosted zones for subdomains require nameserver to be specified explicitly. This sets their default TTL. | string | `"30"` | no |
| tags | The resource tags that should be added to all hosted zone resources. | map | `<map>` | no |
| comment | The hosted zone comment that should be added to all hosted zone resources. | string | `"Managed by Terraform"` | no |


## Outputs

| Name | Description |
|------|-------------|
| created\_delegation\_set\_id | The ID of the shared delegation set applied to all zones that has been created by this module if it was specified by name. |
| created\_delegation\_set\_name | The name of the shared delegation set applied to all zones that has been created by this module if it was specified by name. |
| created\_delegation\_set\_name\_servers | A list of name servers of the shared delegation set applied to all zones that has been created by this module if it was specified by name. |
| existing\_delegation\_set\_id | The ID of the shared delegation set applied to all zones that alreday existed and was specified by its ID. |
| existing\_delegation\_set\_name | The name of the shared delegation set applied to all zones that alreday existed and was specified by its ID. |
| existing\_delegation\_set\_name\_servers | A list of name servers of the shared delegation set applied to all zones that alreday existed and was specified by its ID. |
| public\_zones\_delegation\_set\_id | The ID of the shared delegation set applied to all zones that is actually used by the zones. |
| public\_zones | List of created public zones. |
| public\_zones\_ids | List of zone-id mappings for created public zones. |


## Example output

```bash
$ terraform output
```
```
Outputs:

created_delegation_set_id = ABCDEFGHIJKL
created_delegation_set_name = root-domains
created_delegation_set_name_servers = [
    ns-www.awsdns-00.org,
    ns-xxx.awsdns-11.co.uk,
    ns-yyy.awsdns-22.com,
    ns-zzz.awsdns-33.net
]
existing_delegation_set_id =
existing_delegation_set_name =
existing_delegation_set_name_servers = []
public_zones = [
    example.com.,
    example.org.
]
public_zones_delegation_set_id = ABCDEFGHIJKL
public_zones_ids = [
    {"example.com.": "ABCDEFGHIJKL"},
    {"example.org.": "ABCDEFGHIJKL"}
]
public_zones_name_servers = [
    {"example.com.": "ns-www.awsdns-00.org,ns-xxx.awsdns-11.co.uk,ns-yy.awsdns-22.com,ns-zzz.awsdns-22.net"},
    {"example.org.": "ns-www.awsdns-00.org,ns-xxx.awsdns-11.co.uk,ns-yy.awsdns-22.com,ns-zzz.awsdns-22.net"}
]
```

## Authors

Module managed by [cytopia](https://github.com/cytopia).

## License

[MIT License](LICENSE)

Copyright (c) 2018 [cytopia](https://github.com/cytopia)
