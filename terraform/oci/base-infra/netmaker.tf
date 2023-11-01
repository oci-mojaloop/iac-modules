module "netmaker_subnet_addrs" {
  count  = var.enable_netmaker ? 1 : 0
  source = "hashicorp/subnets/cidr"

  base_cidr_block = var.netmaker_vcn_cidr
  networks = [
    {
      name     = "netmaker-public"
      new_bits = 1
    },
  ]

}


module "vcn_netmaker" {
  count                    = var.enable_netmaker ? 1 : 0
  source                   = "oracle-terraform-modules/vcn/oci"
  version                  = "3.5.4"
  compartment_id           = var.compartment_id
  create_internet_gateway  = true
  create_nat_gateway       = true
  create_service_gateway   = true
  freeform_tags            = merge({}, local.common_tags)
  subnets                  = local.netmaker_public_subnets
  vcn_cidrs                = [var.netmaker_vcn_cidr]
  vcn_name                 = "${var.cluster_name}-netmaker"
  lockdown_default_seclist = false
}

resource "oci_core_network_security_group" "netmaker" {
  count          = var.enable_netmaker ? 1 : 0
  compartment_id = var.compartment_id
  vcn_id         = module.vcn_netmaker[0].vcn_id
  display_name   = "${local.cluster_domain}-netmaker"
  freeform_tags  = merge({ Name = "${local.cluster_domain}-netmaker" }, local.common_tags)
}

resource "oci_core_network_security_group_security_rule" "netmaker_ssh" {
  count                     = var.enable_netmaker ? 1 : 0
  network_security_group_id = oci_core_network_security_group.netmaker[0].id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  stateless                 = true
  tcp_options {
    destination_port_range {
      max = 22
      min = 22
    }
    source_port_range {
      max = 22
      min = 22
    }
  }
}

resource "oci_core_network_security_group_security_rule" "netmaker_wireguard" {
  count                     = var.enable_netmaker ? 1 : 0
  network_security_group_id = oci_core_network_security_group.netmaker[0].id
  direction                 = "INGRESS"
  description               = "wireguard client access"
  protocol                  = "17"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  stateless                 = true
  udp_options {
    destination_port_range {
      max = 51825
      min = 51825
    }
    source_port_range {
      max = 51820
      min = 51820
    }
  }
}

resource "oci_core_network_security_group_security_rule" "netmaker_stun" {
  count                     = var.enable_netmaker ? 1 : 0
  network_security_group_id = oci_core_network_security_group.netmaker[0].id
  direction                 = "INGRESS"
  description               = "netmaker stun server access"
  protocol                  = "17"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  stateless                 = true
  udp_options {
    destination_port_range {
      max = 3478
      min = 3478
    }
    source_port_range {
      max = 3478
      min = 3478
    }
  }
}

resource "oci_core_network_security_group_security_rule" "netmaker_proxy" {
  count                     = var.enable_netmaker ? 1 : 0
  network_security_group_id = oci_core_network_security_group.netmaker[0].id
  direction                 = "INGRESS"
  description               = "netmaker proxy access"
  protocol                  = "6"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  stateless                 = true
  tcp_options {
    destination_port_range {
      max = 443
      min = 443
    }
    source_port_range {
      max = 443
      min = 443
    }
  }
}

resource "oci_core_network_security_group_security_rule" "netmaker_egress_all" {
  count                     = var.enable_netmaker ? 1 : 0
  network_security_group_id = oci_core_network_security_group.netmaker[0].id
  direction                 = "EGRESS"
  protocol                  = "all"
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"
  stateless                 = true
}

resource "oci_core_instance" "netmaker" {
  count         = var.enable_netmaker ? 1 : 0
  availability_domain = data.oci_identity_availability_domain.ad.name
  agent_config {
    are_all_plugins_disabled = false
    is_management_disabled   = false
    is_monitoring_disabled   = false
    plugins_config {
      desired_state = "DISABLED"
      name          = "OS Management Service Agent"
    }
  }
  compartment_id = var.compartment_id
  create_vnic_details {
    assign_public_ip = true
    subnet_id        = local.netmaker_public_subnet_id
    nsg_ids          = [oci_core_network_security_group.netmaker[0].id]
  }
  display_name = "${local.cluster_domain}-netmaker"
  launch_options {
    boot_volume_type = "PARAVIRTUALIZED"
    network_type     = "PARAVIRTUALIZED"
  }
  metadata = {
    ssh_authorized_keys = tls_private_key.compute_ssh_key.public_key_openssh
    user_data           = base64encode(templatefile("${path.module}/templates/bastion.user_data.tmpl", { ssh_keys = local.ssh_keys }))

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
    source_id   = var.bastion_image_id
  }

  state = var.bastion_state

  # prevent the operator from destroying and recreating itself if the image ocid/tagging/user data changes
  lifecycle {
    ignore_changes = [availability_domain, defined_tags, freeform_tags, metadata, source_details[0].source_id]
  }

  timeouts {
    create = "60m"
  }

}