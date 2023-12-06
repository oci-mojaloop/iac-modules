#############################
### Access Control
#############################

resource "oci_core_network_security_group" "ingress" {
  compartment_id = var.compartment_id
  vcn_id         = module.base_infra.vcn_id
  display_name   = "${local.base_domain}-ingress"
  freeform_tags  = merge({ Name = "${local.base_domain}-ingress" }, local.common_tags)
}

resource "oci_core_network_security_group_security_rule" "ingress_http" {
  network_security_group_id = oci_core_network_security_group.ingress.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  stateless                 = true
  tcp_options {
    destination_port_range {
      max = var.target_group_external_http_port
      min = var.target_group_external_http_port
    }
    source_port_range {
      max = var.target_group_external_http_port
      min = var.target_group_external_http_port
    }
  }
}

resource "oci_core_network_security_group_security_rule" "ingress_https" {
  network_security_group_id = oci_core_network_security_group.ingress.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  stateless                 = true
  tcp_options {
    destination_port_range {
      max = var.target_group_external_https_port
      min = var.target_group_external_https_port
    }
    source_port_range {
      max = var.target_group_external_https_port
      min = var.target_group_external_https_port
    }
  }
}

resource "oci_core_network_security_group_security_rule" "ingress_health_external" {
  network_security_group_id = oci_core_network_security_group.ingress.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  stateless                 = true
  tcp_options {
    destination_port_range {
      max = var.target_group_external_health_port
      min = var.target_group_external_health_port
    }
    source_port_range {
      max = var.target_group_external_health_port
      min = var.target_group_external_health_port
    }
  }
}

resource "oci_core_network_security_group_security_rule" "ingress_http_internal" {
  network_security_group_id = oci_core_network_security_group.ingress.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = var.vcn_cidr
  source_type               = "CIDR_BLOCK"
  stateless                 = true
  tcp_options {
    destination_port_range {
      max = var.target_group_internal_http_port
      min = var.target_group_internal_http_port
    }
    source_port_range {
      max = var.target_group_internal_http_port
      min = var.target_group_internal_http_port
    }
  }
}

resource "oci_core_network_security_group_security_rule" "ingress_https_internal" {
  network_security_group_id = oci_core_network_security_group.ingress.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = var.vcn_cidr
  source_type               = "CIDR_BLOCK"
  stateless                 = true
  tcp_options {
    destination_port_range {
      max = var.target_group_internal_https_port
      min = var.target_group_internal_https_port
    }
    source_port_range {
      max = var.target_group_internal_https_port
      min = var.target_group_internal_https_port
    }
  }
}

resource "oci_core_network_security_group_security_rule" "ingress_health_internal" {
  network_security_group_id = oci_core_network_security_group.ingress.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = var.vcn_cidr
  source_type               = "CIDR_BLOCK"
  stateless                 = true
  tcp_options {
    destination_port_range {
      max = var.target_group_internal_health_port
      min = var.target_group_internal_health_port
    }
    source_port_range {
      max = var.target_group_internal_health_port
      min = var.target_group_internal_health_port
    }
  }
}

resource "oci_core_network_security_group_security_rule" "ingress_istio_webhook_internal" {
  network_security_group_id = oci_core_network_security_group.ingress.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = var.vcn_cidr
  source_type               = "CIDR_BLOCK"
  stateless                 = true
  tcp_options {
    destination_port_range {
      max = "15017"
      min = "15017"
    }
    source_port_range {
      max = "15017"
      min = "15017"
    }
  }
}

resource "oci_core_network_security_group_security_rule" "ingress_vpn" {
  network_security_group_id = oci_core_network_security_group.ingress.id
  direction                 = "INGRESS"
  protocol                  = "17"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  stateless                 = true
  udp_options {
    destination_port_range {
      max = var.wireguard_port
      min = var.wireguard_port
    }
    source_port_range {
      max = var.wireguard_port
      min = var.wireguard_port
    }
  }
}


resource "oci_core_network_security_group_security_rule" "ingress_self" {
  network_security_group_id = oci_core_network_security_group.ingress.id
  direction                 = "INGRESS"
  protocol                  = "all"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  stateless                 = true
}

resource "oci_core_network_security_group_security_rule" "ingress_egress_all" {
  network_security_group_id = oci_core_network_security_group.ingress.id
  direction                 = "EGRESS"
  protocol                  = "all"
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"
  stateless                 = true
}


resource "oci_core_network_security_group" "self" {
  compartment_id = var.compartment_id
  vcn_id         = module.base_infra.vcn_id
  display_name   = "${local.base_domain}-self"
  freeform_tags  = merge({ Name = "${local.base_domain}-self" }, local.common_tags)
}


resource "oci_core_network_security_group_security_rule" "self_self" {
  network_security_group_id = oci_core_network_security_group.self.id
  direction                 = "INGRESS"
  protocol                  = "all"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  stateless                 = true
}

resource "oci_core_network_security_group_security_rule" "internal_ssh" {
  network_security_group_id = oci_core_network_security_group.self.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = var.vcn_cidr
  source_type               = "CIDR_BLOCK"
  stateless                 = true
  tcp_options {
    destination_port_range {
      max = "22"
      min = "22"
    }
    source_port_range {
      max = "22"
      min = "22"
    }
  }
}

resource "oci_core_network_security_group_security_rule" "self_master" {
  network_security_group_id = oci_core_network_security_group.self.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = var.vcn_cidr
  source_type               = "CIDR_BLOCK"
  stateless                 = true
  tcp_options {
    destination_port_range {
      max = "6443"
      min = "6443"
    }
    source_port_range {
      max = "6443"
      min = "6443"
    }
  }
}


resource "oci_core_network_security_group_security_rule" "self_https_external" {
  network_security_group_id = oci_core_network_security_group.self.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = var.vcn_cidr
  source_type               = "CIDR_BLOCK"
  stateless                 = true
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
    source_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource "oci_core_network_security_group_security_rule" "self_http_external" {
  network_security_group_id = oci_core_network_security_group.self.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = var.vcn_cidr
  source_type               = "CIDR_BLOCK"
  stateless                 = true
  tcp_options {
    destination_port_range {
      max = "80"
      min = "80"
    }
    source_port_range {
      max = "80"
      min = "80"
    }
  }
}

resource "oci_core_network_security_group_security_rule" "self_https_internal" {
  network_security_group_id = oci_core_network_security_group.self.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = var.vcn_cidr
  source_type               = "CIDR_BLOCK"
  stateless                 = true
  tcp_options {
    destination_port_range {
      max = "8443"
      min = "8443"
    }
    source_port_range {
      max = "8443"
      min = "8443"
    }
  }
}

resource "oci_core_network_security_group_security_rule" "self_http_internal" {
  network_security_group_id = oci_core_network_security_group.self.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = var.vcn_cidr
  source_type               = "CIDR_BLOCK"
  stateless                 = true
  tcp_options {
    destination_port_range {
      max = "8080"
      min = "8080"
    }
    source_port_range {
      max = "8080"
      min = "8080"
    }
  }
}



resource "oci_core_network_security_group_security_rule" "self_egress_all" {
  network_security_group_id = oci_core_network_security_group.self.id
  direction                 = "EGRESS"
  protocol                  = "all"
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"
  stateless                 = true
}