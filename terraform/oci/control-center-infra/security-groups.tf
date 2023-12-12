resource "oci_core_network_security_group" "gitlab_server" {
  compartment_id = var.compartment_id
  vcn_id         = module.base_infra.vcn_id
  display_name   = "gitlab_server"
  freeform_tags  = var.tags
}



resource "oci_core_network_security_group_security_rule" "gitlab_server_egress_all" {
  network_security_group_id = oci_core_network_security_group.gitlab_server.id
  direction                 = "EGRESS"
  protocol                  = "all"
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"
}

resource "oci_core_network_security_group_security_rule" "gitlab_server_ingress_ssh" {
  network_security_group_id = oci_core_network_security_group.gitlab_server.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = var.vcn_cidr
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      max = "22"
      min = "22"
    }
  }
}

resource "oci_core_network_security_group_security_rule" "gitlab_server_ingress_http" {
  network_security_group_id = oci_core_network_security_group.gitlab_server.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      max = "80"
      min = "80"
    }
  }
}

resource "oci_core_network_security_group_security_rule" "gitlab_server_ingress_https" {
  network_security_group_id = oci_core_network_security_group.gitlab_server.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}


resource "oci_core_network_security_group_security_rule" "gitlab_server_ingress_registry" {
  network_security_group_id = oci_core_network_security_group.gitlab_server.id
  direction                 = "INGRESS"
  description               = "GitLab Container Registry"
  protocol                  = "6"
  source                    = var.vcn_cidr
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      max = "5050"
      min = "5050"
    }
  }
}

resource "oci_core_network_security_group_security_rule" "gitlab_server_ingress_registry_nat" {
  network_security_group_id = oci_core_network_security_group.gitlab_server.id
  direction                 = "INGRESS"
  description               = "GitLab Container Registry from NAT"
  protocol                  = "6"
  source                    = "${module.base_infra.nat_public_ips}/32"
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      max = "5050"
      min = "5050"
    }
  }
}


resource "oci_core_network_security_group" "docker_server" {
  compartment_id = var.compartment_id
  vcn_id         = module.base_infra.vcn_id
  display_name   = "docker_server"
  freeform_tags  = var.tags
}

resource "oci_core_network_security_group_security_rule" "docker_server_ingress_ssh" {
  network_security_group_id = oci_core_network_security_group.docker_server.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = var.vcn_cidr
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      max = "22"
      min = "22"
    }
  }
}

resource "oci_core_network_security_group_security_rule" "docker_server_ingress_nexus_admin" {
  network_security_group_id = oci_core_network_security_group.docker_server.id
  direction                 = "INGRESS"
  description               = "nexus admin access"
  protocol                  = "6"
  source                    = var.vcn_cidr
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      max = var.nexus_admin_listening_port
      min = var.nexus_admin_listening_port
    }
  }
}

resource "oci_core_network_security_group_security_rule" "docker_server_ingress_nexus_http" {
  network_security_group_id = oci_core_network_security_group.docker_server.id
  direction                 = "INGRESS"
  description               = "nexus docker repo http access"
  protocol                  = "6"
  source                    = var.vcn_cidr
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      max = var.nexus_docker_repo_listening_port
      min = var.nexus_docker_repo_listening_port
    }
  }
}

resource "oci_core_network_security_group_security_rule" "docker_server_ingress_seeweed" {
  network_security_group_id = oci_core_network_security_group.docker_server.id
  direction                 = "INGRESS"
  description               = "seaweedfs s3 access"
  protocol                  = "6"
  source                    = var.vcn_cidr
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      max = var.seaweedfs_s3_listening_port
      min = var.seaweedfs_s3_listening_port
    }
  }
}

resource "oci_core_network_security_group_security_rule" "docker_server_ingress_vault" {
  network_security_group_id = oci_core_network_security_group.docker_server.id
  direction                 = "INGRESS"
  description               = "vault access"
  protocol                  = "6"
  source                    = var.vcn_cidr
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      max = var.vault_listening_port
      min = var.vault_listening_port
    }
  }
}

resource "oci_core_network_security_group_security_rule" "docker_server_ingress_wireguard" {
  network_security_group_id = oci_core_network_security_group.docker_server.id
  direction                 = "INGRESS"
  description               = "wireguard access"
  protocol                  = "17"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  udp_options {
    destination_port_range {
      max = "51825"
      min = "51825"
    }
    source_port_range {
      max = "51820"
      min = "51820"
    }
  }
}


resource "oci_core_network_security_group_security_rule" "docker_server_egress_all" {
  network_security_group_id = oci_core_network_security_group.docker_server.id
  direction                 = "EGRESS"
  protocol                  = "all"
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"
}

