# IAM user with permissions to be able to update route53 records, for use with external-dns
resource "oci_identity_user" "user_external_dns" {
  compartment_id = var.tenancy_id
  description    = "${var.name}-external-dns"
  name           = "${var.name}-external-dns"
  freeform_tags  = merge({ Name = "${var.name}-user-external-dns" }, var.tags)
}


resource "oci_identity_api_key" "user_external_dns_api_key" {
  key_value = tls_private_key.user_external_dns_key.public_key_pem
  user_id   = oci_identity_user.user_external_dns.id
}


resource "oci_identity_policy" "user_external_dns_policy" {
  compartment_id = var.tenancy_id
  description    = "Policy for user to manage dns records"
  name           = "${var.name}-external-dns"
  statements     = local.external_dns_compartment_statements
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
    "Allow ${oci_identity_user.user_external_dns.name} to manage dns-records  in compartment id ${var.compartment_id}  where target.dns-zone.id=${var.public_zone_id}",
    "Allow ${oci_identity_user.user_external_dns.name} to manage dns-records  in compartment id ${var.compartment_id}  where target.dns-zone.id=${var.private_zone_id}",
    "Allow ${oci_identity_user.user_external_dns.name} to inspect dns-zones in compartment id ${var.compartment_id}",
    "Allow ${oci_identity_user.user_external_dns.name} to inspect dns-records in compartment id ${var.compartment_id}"
  ]
}
