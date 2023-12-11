provider "oci" {
  alias  = "home_region"
  region = lookup(data.oci_identity_regions.home_region.regions[0], "name")
}