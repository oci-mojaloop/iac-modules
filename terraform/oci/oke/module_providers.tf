provider "oci" {
  alias            = "current_region"
  region           = var.region
  auth             = "InstancePrincipal"
}

provider "oci" {
  alias            = "home"
  region           = lookup(data.oci_identity_regions.home_region.regions[0], "name")
  auth             = "InstancePrincipal"
}