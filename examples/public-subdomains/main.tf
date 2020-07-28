# -------------------------------------------------------------------------------------------------
# AWS Settings
# -------------------------------------------------------------------------------------------------
provider "aws" {
  region = "eu-central-1"
}

# -------------------------------------------------------------------------------------------------
# Modules Settings
# -------------------------------------------------------------------------------------------------
module "aws_route53zone" {
  source = "../.."

  delegation_sets = []

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
      delegation_set = null,
    },
  ]
}
