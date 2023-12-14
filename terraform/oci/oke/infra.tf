
module "ubuntu_canonical_image" {
  source                         = "../ubuntu-img-id"
  compartment_id                 = var.compartment_id
  image_operating_system_version = "20.04"
}

module "base_infra" {
  source                    = "../base-infra"
  tenancy_id                = var.tenancy_id
  compartment_id            = var.compartment_id
  region                    = var.region
  cluster_name              = var.cluster_name
  domain                    = var.domain
  tags                      = var.tags
  vcn_cidr                  = var.vcn_cidr
  create_public_zone        = var.create_public_zone
  create_private_zone       = var.create_private_zone
  manage_parent_domain      = var.manage_parent_domain
  manage_parent_domain_ns   = var.manage_parent_domain_ns
  ad_count                  = var.ad_count
  block_size                = var.block_size
  bastion_image_id          = module.ubuntu_canonical_image.id
  create_haproxy_dns_record = true
}

module "post_config" {
  source                     = "../post-config-k8s"
  tenancy_id                 = var.tenancy_id
  compartment_id             = var.compartment_id
  region                     = var.region
  bucket_namespace           = var.bucket_namespace
  name                       = var.cluster_name
  domain                     = var.domain
  tags                       = var.tags
  private_zone_id            = module.base_infra.private_zone.id
  public_zone_id             = module.base_infra.public_zone.id
  longhorn_backup_s3_destroy = var.longhorn_backup_object_store_destroy
}

module "k6s_test_harness" {
  count                       = var.enable_k6s_test_harness ? 1 : 0
  source                      = "../k6s-test-harness"
  compartment_id              = var.compartment_id
  region                      = var.region
  cluster_name                = var.cluster_name
  domain                      = var.domain
  tags                        = var.tags
  vcn_cidr                    = var.vcn_cidr
  vcn_id                      = module.base_infra.vcn_id
  compute_image_id            = module.ubuntu_canonical_image.id
  docker_server_instance_type = var.k6s_docker_server_instance_type
  subnet_id                   = module.base_infra.private_subnet_id
  key_pair_name               = module.base_infra.ssh_public_key
  public_zone_id              = module.base_infra.public_zone.id
  test_harness_hostname       = var.k6s_docker_server_fqdn
}




module "oke" {
  source                       = "oracle-terraform-modules/oke/oci"
  version                      = "5.1.0"
  compartment_id               = var.compartment_id
  worker_compartment_id        = var.compartment_id
  home_region                  = local.home_region
  region                       = var.region
  create_vcn                   = "false"
  vcn_id                       = module.base_infra.vcn_id
  subnets                      = local.oke_subnets
  pods_cidr                    = local.oke_pod_cidrs
  cni_type                     = "npn"
  cluster_name                 = local.oke_name
  create_cluster               = true
  kubernetes_version           = var.kubernetes_version
  control_plane_is_public      = false
  create_bastion               = false
  create_operator              = false
  allow_bastion_cluster_access = true
  allow_pod_internet_access    = true
  cluster_freeform_tags        = var.tags
  control_plane_allowed_cidrs  = local.cp_allowed_cidrs
  load_balancers               = "public"
  worker_image_os_version      = 7.9
  worker_shape                 = var.worker_shape
  worker_pools                 = local.worker_pools
  allow_worker_ssh_access      = true

  providers = {
    oci      = oci.current_region
    oci.home = oci.home
  }


}


locals {
  oke_subnets = {
    "bastion" = {
      "create" = "never"
      "id"     = module.base_infra.private_subnet_id
      "cidr"   = module.base_infra.private_subnets_cidr_blocks
    },
    "pub_lb" = {
      "create" = "never"
      "id"     = module.base_infra.public_subnet_id
      "cidr"   = module.base_infra.public_subnets_cidr_blocks
    },
    "cp" = {
      "create" = "never"
      "id"     = module.base_infra.private_subnet_id
      "cidr"   = module.base_infra.private_subnets_cidr_blocks
    },
    "int_lb" = {
      "create" = "never"
      "id"     = module.base_infra.private_subnet_id
      "cidr"   = module.base_infra.private_subnets_cidr_blocks
    },
    "operator" = {
      "create" = "never"
      "id"     = module.base_infra.private_subnet_id
      "cidr"   = module.base_infra.private_subnets_cidr_blocks
    },
    "pods" = {
      "create" = "never"
      "id"     = module.base_infra.private_subnet_id
      "cidr"   = module.base_infra.private_subnets_cidr_blocks
    },
    "workers" = {
      "create" = "never"
      "id"     = module.base_infra.private_subnet_id
      "cidr"   = module.base_infra.private_subnets_cidr_blocks
    }
  }
}


locals {

  worker_pools = {
    np1 = {
      mode   = "node-pool",
      size   = var.agent_node_count,
      shape  = "VM.Standard.E4.Flex",
      create = true
    }
  }
}

locals {
  oke_pod_cidrs    = module.base_infra.private_subnets_cidr_blocks
  cp_allowed_cidrs = ["${module.base_infra.private_subnets_cidr_blocks}", "${module.base_infra.public_subnets_cidr_blocks}"]
  home_region      = lookup(data.oci_identity_regions.home_region.regions[0], "name")
  oke_name         = substr(replace(local.base_domain, ".", "-"), 0, 16)
}
