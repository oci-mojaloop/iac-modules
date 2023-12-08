module "subnet_addrs" {
  source = "hashicorp/subnets/cidr"

  base_cidr_block = var.vcn_cidr
  networks = [
    for subnet in concat(local.private_subnets_list, local.public_subnets_list) : {
      name     = subnet
      new_bits = var.new_bits
    }
  ]

}





module "vcn" {
  source                   = "oracle-terraform-modules/vcn/oci"
  version                  = "3.5.4"
  compartment_id           = var.compartment_id
  create_internet_gateway  = true
  create_nat_gateway       = true
  create_service_gateway   = true
  freeform_tags            = merge({}, local.common_tags)
  subnets                  = local.subnet_maps
  vcn_cidrs                = [var.vcn_cidr]
  vcn_name                 = local.cluster_domain
  lockdown_default_seclist = false
}


resource "oci_core_network_security_group" "bastion" {
  compartment_id = var.compartment_id
  vcn_id         = module.vcn.vcn_id
  display_name   = "${local.cluster_domain}-bastion"
  freeform_tags  = merge({ Name = "${local.cluster_domain}-bastion" }, local.common_tags)
}


resource "oci_core_network_security_group_security_rule" "bastion_ssh" {
  network_security_group_id = oci_core_network_security_group.bastion.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      max = 22
      min = 22
    }
  }
}


resource "oci_core_network_security_group_security_rule" "bastion_wireguard" {
  network_security_group_id = oci_core_network_security_group.bastion.id
  direction                 = "INGRESS"
  description               = "wireguard client access"
  protocol                  = "17"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
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

resource "oci_core_network_security_group_security_rule" "bastion_egress_all" {
  network_security_group_id = oci_core_network_security_group.bastion.id
  direction                 = "EGRESS"
  protocol                  = "all"
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"
}




resource "oci_core_instance" "bastion" {
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
    assign_public_ip = true
    subnet_id        = local.public_subnet_id
    nsg_ids          = [oci_core_network_security_group.bastion.id]
  }
  display_name = "${local.cluster_domain}-bastion"
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

resource "tls_private_key" "compute_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

