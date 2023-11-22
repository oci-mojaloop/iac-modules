resource "oci_objectstorage_bucket" "longhorn_backups" {
  compartment_id = var.compartment_id
  name           = "${var.name}-longhorn_backups"
  namespace      = var.bucket_namespace
  freeform_tags  = merge({ Name = "${var.name}-longhorn_backups" }, var.tags)
}

resource "oci_identity_user" "longhorn_backups" {
  compartment_id = var.tenancy_id
  description    = "${local.base_domain}-lhbck"
  name           = "${local.base_domain}-lhbck"
  freeform_tags  = merge({ Name = "${var.name}-longhorn_backups" }, var.tags)
  provider       = oci.home_region
}

resource "oci_identity_customer_secret_key" "longhorn_backups_secret_key" {
  display_name = "${local.base_domain}-lhbck-s3-keys"
  user_id      = oci_identity_user.longhorn_backups.id
  provider       = oci.home_region
}

resource "oci_identity_policy" "longhorn_backups_policy" {
  compartment_id = var.tenancy_id
  description    = "IAM Policy to allow longhorn store objects"
  name           = "${local.base_domain}-lhbck"
  statements     = local.longhorn_backups_statements
  provider       = oci.home_region
}


locals {
  longhorn_backups_statements = concat(
    local.oci_longhorn_backups_statements
  )
}

locals {
  oci_longhorn_backups_statements = [
    "Allow ${oci_identity_user.longhorn_backups.name} to manage objects  in compartment id ${var.compartment_id}  where target.bucket.name=${oci_objectstorage_bucket.longhorn_backups.name}",
    "Allow ${oci_identity_user.longhorn_backups.name} to inspect buckets in compartment id ${var.compartment_id}"
  ]
}