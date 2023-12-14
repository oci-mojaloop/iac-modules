resource "oci_core_volume_backup_policy" "backup_gitlab" {
  compartment_id = var.compartment_id
  display_name   = "Gitlab Backup Policy"
  freeform_tags  = var.tags
  schedules {
    backup_type       = "INCREMENTAL"
    period            = "ONE_DAY"
    retention_seconds = var.days_retain_gitlab_snapshot * 86400
    offset_seconds    = "82800"
    offset_type       = "NUMERIC_SECONDS"
    time_zone         = "REGIONAL_DATA_CENTER_TIME"
  }
}

resource "oci_core_volume_backup_policy_assignment" "test_volume_backup_policy_assignment" {
  asset_id  = var.gitlab_block_volume_id
  policy_id = oci_core_volume_backup_policy.backup_gitlab.id
}