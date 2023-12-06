# IAM user with permissions to be able to update route53 records, for use with external-dns
resource "oci_identity_user" "user_external_dns" {
  compartment_id = var.tenancy_id
  description    = "${var.name}-user-external-dns"
  name           = "${var.name}-user-external-dns"
  freeform_tags  = merge({ Name = "${var.name}-user-external-dns" }, var.tags)
  provider       = oci.home_region
}

resource "oci_identity_group" "group_external_dns" {
    #Required
    compartment_id = var.tenancy_id
    description = "${var.name}-group-external-dns"
    name = "${var.name}-group-external-dns"
    freeform_tags = merge({ Name = "${var.name}-group-external-dns" }, var.tags)
    provider       = oci.home_region
}

resource "oci_identity_user_group_membership" "external_dns_user_group_membership" {
    group_id = oci_identity_group.group_external_dns.id
    user_id = oci_identity_user.user_external_dns.id
    provider       = oci.home_region
}

resource "oci_identity_api_key" "user_external_dns_api_key" {
  key_value = tls_private_key.user_external_dns_key.public_key_pem
  user_id   = oci_identity_user.user_external_dns.id
  provider       = oci.home_region
}


resource "oci_identity_policy" "user_external_dns_policy" {
  compartment_id = var.tenancy_id
  description    = "Policy for user to manage dns records"
  name           = "${var.name}-external-dns"
  statements     = local.external_dns_compartment_statements
  provider       = oci.home_region
}


locals {
  external_dns_compartment_statements = concat(
    local.oci_external_dns_statements
  )
}

locals {
  ### For the aws implmentation , there was one more policy which is required if we use Route53 as the DNS01 provider for cert-manger. 
  ### We dont know much about it as of now..so will go with HTTP01 challenge
  oci_external_dns_statements = [
    "Allow group ${oci_identity_group.group_external_dns.name} to manage dns-records  in compartment id ${var.compartment_id}  where target.dns-zone.id=${var.public_zone_id}",
    "Allow group ${oci_identity_group.group_external_dns.name} to manage dns-records  in compartment id ${var.compartment_id}  where target.dns-zone.id=${var.private_zone_id}",
    "Allow group ${oci_identity_group.group_external_dns.name} to inspect dns-zones in compartment id ${var.compartment_id}",
    "Allow group ${oci_identity_group.group_external_dns.name} to inspect dns-records in compartment id ${var.compartment_id}"
  ]
}
