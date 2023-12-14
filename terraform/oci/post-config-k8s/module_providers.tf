terraform {
  required_providers {
    # oci = {
    #   source  = "oracle/oci"
    #   version = ">=4.67.3"
    # }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.4"
    }
  }
  required_version = ">= 1.0.0"
}

data "oci_identity_tenancy" "tenant_details" {
  tenancy_id = var.tenancy_id
}

data "oci_identity_regions" "home_region" {
  filter {
    name   = "key"
    values = [data.oci_identity_tenancy.tenant_details.home_region_key]
  }
}

provider "oci" {
  alias            = "home_region"
  region           = lookup(data.oci_identity_regions.home_region.regions[0], "name")
  auth             = "InstancePrincipal"
}

provider "oci" {
  region              = var.region
  auth                = "InstancePrincipal"
}