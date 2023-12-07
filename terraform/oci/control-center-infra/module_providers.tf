# terraform {
#   required_providers {
#     oci = {
#       source  = "oracle/oci"
#       version = ">=4.67.3"
#     }
#   }
#   required_version = ">= 1.0.0"
# }

provider "oci" {
  alias            = "home_region"
  tenancy_ocid     = var.tenancy_id
  region           = lookup(data.oci_identity_regions.home_region.regions[0], "name")
  user_ocid        = var.user_id
  fingerprint      = var.api_fingerprint
  private_key_path = var.api_private_key_path
}