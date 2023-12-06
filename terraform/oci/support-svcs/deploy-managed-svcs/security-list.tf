#############################
### Access Control
#############################
resource "oci_core_security_list" "managed_svcs" {
  compartment_id = var.compartment_id
  vcn_id         = module.base_infra[0].vcn_id
  display_name   = "${var.deployment_name}-managed-svcs"
  egress_security_rules {
    destination      = "0.0.0.0/0"
    protocol         = "all"
    destination_type = "CIDR_BLOCK"
    stateless        = false
  }
  freeform_tags = merge({ Name = "${var.deployment_name}-mgmt-svcs" }, local.common_tags)
  ingress_security_rules {
    protocol    = 6
    source      = "0.0.0.0/0"
    description = "Allow mysql client access"
    source_type = "CIDR_BLOCK"
    stateless   = false
    tcp_options {
      max = 3306
      min = 3306
      source_port_range {
        max = 3306
        min = 3306
      }
    }
  }
}
