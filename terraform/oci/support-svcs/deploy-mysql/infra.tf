
resource "oci_mysql_mysql_db_system" "mysql_db_system" {
  for_each = var.db_services

  availability_domain = data.oci_identity_availability_domain.ad.name
  compartment_id      = var.compartment_id
  shape_name          = each.value.external_resource_config.shape_name
  subnet_id           = var.db_subnet_id
  admin_password      = each.value.external_resource_config.password
  admin_username      = each.value.external_resource_config.username
  backup_policy {
    is_enabled = true
    pitr_policy {
      is_enabled = true
    }
    retention_in_days = each.value.external_resource_config.backup_retention_days
  }
  # configuration_id = oci_audit_configuration.test_configuration.id   ### Need to revisit this
  data_storage_size_in_gb = each.value.external_resource_config.allocated_storage
  deletion_policy {
    is_delete_protected = false
  }
  display_name        = each.value.external_resource_config.display_name
  hostname_label      = each.value.external_resource_config.hostname_label
  is_highly_available = each.value.external_resource_config.is_highly_available
  port = each.value.external_resource_config.port
  mysql_version = each.value.external_resource_config.engine_version

}