
resource "oci_dns_rrset" "gitlab_server_public" {
  domain          = "gitlab.${module.base_infra.public_zone.name}"
  rtype           = "A"
  zone_name_or_id = module.base_infra.public_zone.id
  compartment_id  = var.compartment_id
  items {
    domain = "gitlab.${module.base_infra.public_zone.name}"
    rdata  = oci_core_instance.gitlab_server.public_ip
    rtype  = "A"
    ttl    = "300"
  }
}

resource "oci_dns_zone" "public_netmaker" {
  count          = var.enable_netmaker ? 1 : 0
  compartment_id = var.compartment_id
  name           = "netmaker.${module.base_infra.public_zone.name}"
  zone_type      = "PRIMARY"
  freeform_tags  = merge({ Name = "${local.name}-public-netmaker" }, local.common_tags)
  lifecycle {
    ignore_changes = [
      freeform_tags,
      name,
    ]
  }
}

resource "oci_dns_rrset" "netmaker_dashboard" {
  count           = var.enable_netmaker ? 1 : 0
  domain          = "dashboard.${oci_dns_zone.public_netmaker[0].name}"
  rtype           = "A"
  zone_name_or_id = oci_dns_zone.public_netmaker[0].id
  compartment_id  = var.compartment_id
  items {
    domain = "dashboard.${oci_dns_zone.public_netmaker[0].name}"
    rdata  = module.base_infra.netmaker_public_ip
    rtype  = "A"
    ttl    = "300"
  }
}

resource "oci_dns_rrset" "netmaker_api" {
  count           = var.enable_netmaker ? 1 : 0
  domain          = "api.${oci_dns_zone.public_netmaker[0].name}"
  rtype           = "A"
  zone_name_or_id = oci_dns_zone.public_netmaker[0].id
  compartment_id  = var.compartment_id
  items {
    domain = "api.${oci_dns_zone.public_netmaker[0].name}"
    rdata  = module.base_infra.netmaker_public_ip
    rtype  = "A"
    ttl    = "300"
  }
}

resource "oci_dns_rrset" "netmaker_broker" {
  count           = var.enable_netmaker ? 1 : 0
  domain          = "broker.${oci_dns_zone.public_netmaker[0].name}"
  rtype           = "A"
  zone_name_or_id = oci_dns_zone.public_netmaker[0].id
  compartment_id  = var.compartment_id
  items {
    domain = "broker.${oci_dns_zone.public_netmaker[0].name}"
    rdata  = module.base_infra.netmaker_public_ip
    rtype  = "A"
    ttl    = "300"
  }
}

resource "oci_dns_rrset" "netmaker_stun" {
  count           = var.enable_netmaker ? 1 : 0
  domain          = "stun.${oci_dns_zone.public_netmaker[0].name}"
  rtype           = "A"
  zone_name_or_id = oci_dns_zone.public_netmaker[0].id
  compartment_id  = var.compartment_id
  items {
    domain = "stun.${oci_dns_zone.public_netmaker[0].name}"
    rdata  = module.base_infra.netmaker_public_ip
    rtype  = "A"
    ttl    = "300"
  }
}

resource "oci_dns_rrset" "nexus_server_private" {
  domain          = "nexus.${module.base_infra.public_zone.name}"
  rtype           = "A"
  zone_name_or_id = module.base_infra.public_zone.id
  compartment_id  = var.compartment_id
  items {
    domain = "nexus.${module.base_infra.public_zone.name}"
    rdata  = oci_core_instance.docker_server.private_ip
    rtype  = "A"
    ttl    = "300"
  }
}

resource "oci_dns_rrset" "seaweedfs_server_private" {
  domain          = "seaweedfs.${module.base_infra.public_zone.name}"
  rtype           = "A"
  zone_name_or_id = module.base_infra.public_zone.id
  compartment_id  = var.compartment_id
  items {
    domain = "seaweedfs.${module.base_infra.public_zone.name}"
    rdata  = oci_core_instance.docker_server.private_ip
    rtype  = "A"
    ttl    = "300"
  }
}

resource "oci_dns_rrset" "gitlab_runner_server_private" {
  domain          = "gitlab_runner.${module.base_infra.public_zone.name}"
  rtype           = "A"
  zone_name_or_id = module.base_infra.public_zone.id
  compartment_id  = var.compartment_id
  items {
    domain = "gitlab_runner.${module.base_infra.public_zone.name}"
    rdata  = oci_core_instance.docker_server.private_ip
    rtype  = "A"
    ttl    = "300"
  }
}

resource "oci_dns_rrset" "vault_server_private" {
  domain          = "vault.${module.base_infra.public_zone.name}"
  rtype           = "A"
  zone_name_or_id = module.base_infra.public_zone.id
  compartment_id  = var.compartment_id
  items {
    domain = "vault.${module.base_infra.public_zone.name}"
    rdata  = oci_network_load_balancer_network_load_balancer.internal.ip_addresses[0].ip_address
    rtype  = "A"
    ttl    = "300"
  }
}