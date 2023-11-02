data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_id
}

data "oci_identity_availability_domain" "ad" {
  compartment_id = var.compartment_id
  ad_number      = var.ad_number
}


data "oci_core_nat_gateway" "nat_gateway" {
  nat_gateway_id = module.vcn.nat_gateway_id
}


data "oci_dns_zones" "private" {
  count          = (var.create_private_zone || !var.configure_dns) ? 0 : 1
  compartment_id = var.compartment_id
  name           = "${local.cluster_domain}.internal."
}

data "oci_dns_zones" "public" {
  count          = (var.create_public_zone || !var.configure_dns) ? 0 : 1
  compartment_id = var.compartment_id
  name           = "${local.cluster_domain}."
}