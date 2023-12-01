resource "oci_network_load_balancer_network_load_balancer" "internal" {
  compartment_id = var.compartment_id
  display_name   = "${local.name}-internal"
  subnet_id      = module.base_infra.private_subnet_id
  freeform_tags  = merge({ Name = "${local.base_domain}-internal" }, local.common_tags)
  is_private     = true
}


resource "oci_network_load_balancer_backend_set" "internal_vault" {
  health_checker {
    protocol = "TCP"
    port     = var.vault_listening_port
  }
  name                     = "${local.name}-vault-8200"
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.internal.id
  policy                   = "FIVE_TUPLE"
}

resource "oci_network_load_balancer_backend" "internal_vault_backend" {
  backend_set_name         = oci_network_load_balancer_backend_set.internal_vault.name
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.internal.id
  port                     = 8200
  name                     = "internal_vault_backend"
  ip_address               = oci_core_instance.docker_server.private_ip
  target_id                = oci_core_instance.docker_server.id
}

resource "oci_network_load_balancer_listener" "internal_https" {
  default_backend_set_name = oci_network_load_balancer_backend_set.internal_vault.name
  name                     = "internal_vault_listener"
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.internal.id
  port                     = "443"
  protocol                 = "TCP"
}

