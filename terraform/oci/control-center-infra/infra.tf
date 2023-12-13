module "ubuntu_canonical_image" {
  source                         = "../ubuntu-img-id"
  compartment_id                 = var.compartment_id
  image_operating_system_version = "20.04"
}

module "base_infra" {
  source              = "../base-infra"
  tenancy_id          = var.tenancy_id
  compartment_id      = var.compartment_id
  region              = var.region
  cluster_name        = var.cluster_name
  domain              = var.domain
  tags                = var.tags
  vcn_cidr            = var.vcn_cidr
  create_public_zone  = var.create_public_zone
  create_private_zone = var.create_private_zone
  ad_count            = var.ad_count
  bastion_image_id    = module.ubuntu_canonical_image.id
  enable_netmaker     = var.enable_netmaker
  block_size          = 2
}



module "post_config" {
  source                      = "../post-config-control-center"
  tenancy_id                  = var.tenancy_id
  compartment_id              = var.compartment_id
  name                        = local.name
  domain                      = local.base_domain
  public_zone_id              = module.base_infra.public_zone.id
  private_zone_id             = module.base_infra.private_zone.id
  tags                        = var.tags
  days_retain_gitlab_snapshot = var.days_retain_gitlab_snapshot
  gitlab_block_volume_id      = oci_core_volume.gitlab_server_block_volume.id
}

resource "oci_core_instance" "gitlab_server" {
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
    subnet_id        = module.base_infra.public_subnet_id
    nsg_ids          = [oci_core_network_security_group.gitlab_server.id]
    hostname_label   = "${local.name}-gitlab-server"
  }
  display_name = "${local.name}-gitlab-server"
  launch_options {
    boot_volume_type        = "PARAVIRTUALIZED"
    network_type            = "PARAVIRTUALIZED"
    remote_data_volume_type = "PARAVIRTUALIZED"
  }
  metadata = {
    ssh_authorized_keys = module.base_infra.ssh_public_key
    user_data           = base64encode(templatefile("${path.module}/templates/gitlab.user_data.tmpl", { vcn_cidr = var.vcn_cidr, nat_cidr = "${module.base_infra.nat_public_ips}/32" }))
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
    source_type             = "image"
    source_id               = module.ubuntu_canonical_image.id
    boot_volume_size_in_gbs = var.gitlab_server_root_vol_size
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

resource "oci_core_volume" "gitlab_server_block_volume" {
  compartment_id      = var.compartment_id
  availability_domain = data.oci_identity_availability_domain.ad.name
  display_name        = "${local.name}-gitlab-server-block-volume"
  size_in_gbs         = var.gitlab_server_extra_vol_size
  freeform_tags       = merge({ Name = "${local.name}-gitlab-server" }, local.common_tags)
}


resource "oci_core_volume_attachment" "gitlab_server_volume_attachment" {
  attachment_type = "paravirtualized"
  instance_id     = oci_core_instance.gitlab_server.id
  volume_id       = oci_core_volume.gitlab_server_block_volume.id
}



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
    subnet_id        = module.base_infra.private_subnet_id
    nsg_ids          = [oci_core_network_security_group.docker_server.id]
  }
  display_name = "${local.name}-docker-server"
  launch_options {
    boot_volume_type        = "PARAVIRTUALIZED"
    network_type            = "PARAVIRTUALIZED"
    remote_data_volume_type = "PARAVIRTUALIZED"
  }
  metadata = {
    ssh_authorized_keys = module.base_infra.ssh_public_key
    user_data           = base64encode(templatefile("${path.module}/templates/docker.user_data.tmpl", { vcn_cidr = var.vcn_cidr, nat_cidr = "${module.base_infra.nat_public_ips}/32" }))
  }

  shape = lookup(var.docker_server_shape, "shape", "VM.Standard.E4.Flex")

  dynamic "shape_config" {
    for_each = length(regexall("Flex", lookup(var.docker_server_shape, "shape", "VM.Standard.E4.Flex"))) > 0 ? [1] : []
    content {
      ocpus         = max(1, lookup(var.docker_server_shape, "ocpus", 1))
      memory_in_gbs = (lookup(var.docker_server_shape, "memory", 4) / lookup(var.docker_server_shape, "ocpus", 1)) > 64 ? (lookup(var.docker_server_shape, "ocpus", 1) * 4) : lookup(var.docker_server_shape, "memory", 4)
    }
  }

  source_details {
    source_type             = "image"
    source_id               = module.ubuntu_canonical_image.id
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
  compartment_id      = var.compartment_id
  availability_domain = data.oci_identity_availability_domain.ad.name
  display_name        = "${local.name}-docker-server-block-volume"
  size_in_gbs         = var.docker_server_extra_vol_size
  freeform_tags       = merge({ Name = "${local.name}-docker-server" }, local.common_tags)
}


resource "oci_core_volume_attachment" "docker_server_volume_attachment" {
  attachment_type = "paravirtualized"
  instance_id     = oci_core_instance.docker_server.id
  volume_id       = oci_core_volume.docker_server_block_volume.id
}


resource "tls_private_key" "compute_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}