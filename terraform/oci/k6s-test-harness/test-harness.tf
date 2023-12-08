resource "oci_core_instance" "docker_server" {
  availability_domain = data.oci_identity_availability_domain.ad.name
  agent_config {
    are_all_plugins_disabled = false
    is_management_disabled   = false
    is_monitoring_disabled   = false
    plugins_config {
      desired_state = "ENABLED"
      name          = "Bastion"
    }
    plugins_config {
      desired_state = "DISABLED"
      name          = "OS Management Service Agent"
    }
  }
  compartment_id = var.compartment_id
  create_vnic_details {
    assign_public_ip = false
    subnet_id        = var.subnet_id
    nsg_ids          = [oci_core_network_security_group.k6s_docker_server.id]
  }
  display_name = "${local.name}-docker-server"
  launch_options {
    boot_volume_type = "PARAVIRTUALIZED"
    network_type     = "PARAVIRTUALIZED"
    remote_data_volume_type = "PARAVIRTUALIZED"
  }
  metadata = {
    ssh_authorized_keys = var.key_pair_name
  }

  shape = lookup(var.operator_shape, "shape", "VM.Standard.E4.Flex")

  dynamic "shape_config" {
    for_each = length(regexall("Flex", lookup(var.operator_shape, "shape", "VM.Standard.E4.Flex"))) > 0 ? [1] : []
    content {
      ocpus         = max(1, lookup(var.operator_shape, "ocpus", 1))
      memory_in_gbs = (lookup(var.operator_shape, "memory", 4) / lookup(var.operator_shape, "ocpus", 1)) > 64 ? (lookup(var.operator_shape, "ocpus", 1) * 4) : lookup(var.operator_shape, "memory", 4)
    }
  }

  source_details {
    source_type = "image"
    source_id   = var.compute_image_id
    boot_volume_size_in_gbs = var.docker_server_root_vol_size
  }

  state = var.compute_state

  # prevent the operator from destroying and recreating itself if the image ocid/tagging/user data changes
  lifecycle {
    ignore_changes = [availability_domain, defined_tags, freeform_tags, metadata, source_details[0].source_id]
  }

  timeouts {
    create = "60m"
  }

}


resource "oci_core_volume" "docker_server_block_volume" {
    compartment_id = var.compartment_id
    availability_domain = data.oci_identity_availability_domain.ad.name
    display_name = "${local.name}-docker-server-block-volume"
    size_in_gbs = var.docker_server_extra_vol_size
    freeform_tags = merge({ Name = "${local.name}-docker-server" }, local.common_tags)
}


resource "oci_core_volume_attachment" "docker_server_volume_attachment" {
    attachment_type = "paravirtualized"
    instance_id = oci_core_instance.docker_server.id
    volume_id = oci_core_volume.docker_server_block_volume.id
}


resource "oci_core_network_security_group" "k6s_docker_server" {
  compartment_id = var.compartment_id
  vcn_id         = var.vcn_id
  display_name   = "k6s-docker-server"
  freeform_tags  = var.tags
}

resource "oci_core_network_security_group_security_rule" "k6s_docker_server_rule" {
  count = length(var.k6s_listening_ports)
  network_security_group_id = oci_core_network_security_group.k6s_docker_server.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = var.vcn_cidr
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      max = var.k6s_listening_ports[count.index]
      min = var.k6s_listening_ports[count.index]
    }
  }
    lifecycle {
    create_before_destroy = true
  }
}

resource "oci_core_network_security_group_security_rule" "k6s_docker_server_ssh" {
  network_security_group_id = oci_core_network_security_group.k6s_docker_server.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = var.vcn_cidr
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      max = 22
      min = 22
    }
  }
}

resource "oci_core_network_security_group_security_rule" "k6s_docker_server_egress_all" {
  network_security_group_id = oci_core_network_security_group.k6s_docker_server.id
  direction                 = "EGRESS"
  protocol                  = "all"
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"
}

resource "oci_dns_rrset" "test_harness_private" {
  domain          = "${var.test_harness_hostname}.${local.cluster_domain}"
  rtype           = "A"
  zone_name_or_id = var.public_zone_id
  compartment_id  = var.compartment_id
  items {
    domain = "${var.test_harness_hostname}.${local.cluster_domain}"
    rdata  = oci_core_instance.docker_server.private_ip
    rtype  = "A"
    ttl    = "300"
  }
}


resource "tls_private_key" "compute_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
