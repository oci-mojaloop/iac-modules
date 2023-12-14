module "deploy_db" {
  count           = length(local.db_services) > 0 ? 1 : 0
  source          = "../deploy-mysql"
  tenancy_id      = var.tenancy_id
  compartment_id  = var.compartment_id
  region          = var.region
  deployment_name = var.deployment_name
  tags            = var.tags
  db_services     = local.db_services
  db_subnet_id    = oci_core_subnet.mysql_subnet.id
}

module "ubuntu_canonical_image" {
  count                          = length(local.external_services) > 0 ? 1 : 0
  source                         = "../../ubuntu-img-id"
  compartment_id                 = var.compartment_id
  image_operating_system_version = "20.04"
}

module "base_infra" {
  count                     = length(local.external_services) > 0 ? 1 : 0
  source                    = "../../base-infra"
  tenancy_id                = var.tenancy_id
  compartment_id            = var.compartment_id
  region                    = var.region
  cluster_name              = var.deployment_name
  tags                      = var.tags
  vcn_cidr                  = var.vcn_cidr
  new_bits                  = var.new_bits
  create_public_zone        = false
  create_private_zone       = false
  manage_parent_domain      = false
  manage_parent_domain_ns   = false
  ad_count                  = var.ad_count
  bastion_image_id          = module.ubuntu_canonical_image[0].id
  create_haproxy_dns_record = false
  configure_dns             = false
}
