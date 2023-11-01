data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_id
}

data "oci_identity_availability_domain" "ad" {
  compartment_id = var.compartment_id
  ad_number      = var.ad_number
}

data "oci_core_subnets" "public_subnet" {
  compartment_id = var.compartment_id
  display_name   = "public-subnet"
  vcn_id         = module.vcn.vcn_id
}

data "oci_core_nat_gateway" "nat_gateway" {
    nat_gateway_id = module.vcn.nat_gateway_id
}

