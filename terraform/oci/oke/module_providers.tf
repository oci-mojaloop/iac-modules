provider "oci" {
  alias            = "current_region"
  region           = var.region
}

provider "oci" {
  alias            = "home"
  region           = lookup(data.oci_identity_regions.home_region.regions[0], "name")
}