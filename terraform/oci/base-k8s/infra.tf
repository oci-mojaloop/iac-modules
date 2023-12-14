
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

