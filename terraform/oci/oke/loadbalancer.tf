#
# Internal load balancer
#

resource "oci_network_load_balancer_network_load_balancer" "internal" {
  compartment_id = var.compartment_id
  display_name   = "${local.name}-internal"
  subnet_id      = module.base_infra.private_subnet_id
  freeform_tags  = merge({ Name = "${local.base_domain}-internal" }, local.common_tags)
  is_private     = true
}

resource "oci_network_load_balancer_backend_set" "internal_kubeapi" {
  health_checker {
    protocol = "TCP"
    port     = var.kubeapi_port
  }
  name                     = "${local.base_domain}-internal-kubeapi"
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.internal.id
  policy                   = "FIVE_TUPLE"
}

resource "oci_network_load_balancer_listener" "internal_kubeapi" {
  default_backend_set_name = oci_network_load_balancer_backend_set.internal_kubeapi.name
  name                     = "internal_kubeapi_listener"
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.internal.id
  port                     = var.kubeapi_port
  protocol                 = "TCP"
}

resource "oci_network_load_balancer_listener" "internal_https" {
  default_backend_set_name = oci_network_load_balancer_backend_set.internal_https.name
  name                     = "internal_https_listener"
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.internal.id
  port                     = "443"
  protocol                 = "TCP"
}

resource "oci_network_load_balancer_backend_set" "internal_https" {
  health_checker {
    protocol            = "HTTP"
    port                = var.target_group_internal_https_port
    interval_in_millis  = 10000
    timeout_in_millis   = 6000
    url_path            = "/healthz/ready"
    return_code         = 200
    response_body_regex = "200-399"
  }
  name                     = "${local.base_domain}-internal-https"
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.internal.id
  policy                   = "FIVE_TUPLE"
}



resource "oci_network_load_balancer_listener" "internal_http" {
  default_backend_set_name = oci_network_load_balancer_backend_set.internal_http.name
  name                     = "internal_http_listener"
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.internal.id
  port                     = "80"
  protocol                 = "TCP"
}

resource "oci_network_load_balancer_backend_set" "internal_http" {
  health_checker {
    protocol            = "HTTP"
    port                = var.target_group_internal_http_port
    interval_in_millis  = 10000
    timeout_in_millis   = 6000
    url_path            = "/healthz/ready"
    return_code         = 200
    response_body_regex = "200-399"
  }
  name                     = "${local.base_domain}-internal-http"
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.internal.id
  policy                   = "FIVE_TUPLE"
}



#
# External load balancer
#

resource "oci_network_load_balancer_network_load_balancer" "lb" {
  compartment_id = var.compartment_id
  display_name   = "${local.base_domain}-public"
  subnet_id      = module.base_infra.public_subnet_id
  freeform_tags  = merge({ Name = "${local.base_domain}-public" }, local.common_tags)
  is_private     = false
}

resource "oci_network_load_balancer_listener" "external_https" {
  default_backend_set_name = oci_network_load_balancer_backend_set.external_https.name
  name                     = "external_https_listener"
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.lb.id
  port                     = "443"
  protocol                 = "TCP"
}

resource "oci_network_load_balancer_listener" "external_http" {
  default_backend_set_name = oci_network_load_balancer_backend_set.external_http.name
  name                     = "external_http_listener"
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.lb.id
  port                     = "80"
  protocol                 = "TCP"
}


resource "oci_network_load_balancer_listener" "wireguard" {
  default_backend_set_name = oci_network_load_balancer_backend_set.wireguard.name
  name                     = "wireguard_listener"
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.lb.id
  port                     = var.wireguard_port
  protocol                 = "UDP"
}


resource "oci_network_load_balancer_backend_set" "external_https" {
  health_checker {
    protocol           = "TCP"
    port               = var.target_group_external_https_port
    interval_in_millis = 10000
    timeout_in_millis  = 6000
  }
  name                     = "${local.base_domain}-external-https"
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.lb.id
  policy                   = "FIVE_TUPLE"
}


resource "oci_network_load_balancer_backend_set" "external_http" {
  health_checker {
    protocol           = "TCP"
    port               = var.target_group_external_http_port
    interval_in_millis = 10000
    timeout_in_millis  = 6000
  }
  name                     = "${local.base_domain}-external-http"
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.lb.id
  policy                   = "FIVE_TUPLE"
}



resource "oci_network_load_balancer_backend_set" "wireguard" {
  health_checker {
    protocol = "TCP"
    port     = var.target_group_external_http_port
  }
  name                     = "${local.base_domain}-wireguard"
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.lb.id
  policy                   = "FIVE_TUPLE"
}
