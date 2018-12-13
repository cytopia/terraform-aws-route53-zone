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

  public_hosted_zones = [
    "example.org",
    "example.com",
    "www.example.org",
    "www.example.com",
  ]

  default_subdomain_ns_ttl = "30"

  comment = "Managed by Terraform"

  tags = {
    Environment = "example"
    Owner       = "terraform"
  }
}
