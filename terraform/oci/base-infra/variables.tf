

variable "tenancy_id" {
  description = "The tenancy id of the OCI Cloud Account in which to create the resources."
  type        = string
}

variable "compartment_id" {
  type        = string
  description = "compartment ocid"
}

variable "ad_count" {
  type        = number
  default     = 1
  description = "Number of ads"
}

variable "ad_number" {
  description = "the AD to place the operator host"
  default     = 1
  type        = number
}

variable "vcn_cidr" {
  default     = "10.25.0.0/22"
  type        = string
  description = "CIDR Subnet to use for the VCN, will be split into multiple /24s for the required private and public subnets"
}

variable "block_size" {
  type    = number
  default = 3
}

variable "cluster_name" {
  description = "Cluster name, lower case and without spaces. This will be used to set tags and name resources"
  type        = string
}

variable "tags" {
  description = "Contains default tags for this project"
  type        = map(string)
  default     = {}
}

variable "domain" {
  description = "Domain to attach the cluster to."
  type        = string
  default     = ""
}

variable "operator_shape" {
  description = "The shape of the operator instance."
  default = {
    shape = "VM.Standard.E4.Flex", ocpus = 1, memory = 1, boot_volume_size = 50
  }
  type = map(any)
}

variable "bastion_image_id" {
  description = "image id for bastion"
}

variable "bastion_state" {
  description = "The target state for the instance. Could be set to RUNNING or STOPPED. (Updatable)"
  default     = "RUNNING"
  type        = string
}

variable "enable_netmaker" {
  type    = bool
  default = false
}

variable "netmaker_vcn_cidr" {
  type    = string
  default = "10.26.0.0/24"
}

###
# Local copies of variables to allow for parsing
###
locals {
  cluster_domain       = "${replace(var.cluster_name, "-", "")}.${var.domain}"
  identifying_tags     = { Cluster = var.cluster_name, Domain = local.cluster_domain }
  common_tags          = merge(local.identifying_tags, var.tags)
  ads                  = slice(data.oci_identity_availability_domains.ads.availability_domains, 0, var.ad_count)
  public_subnets_list  = ["public-subnet"]
  private_subnets_list = ["private-subnet"]
  public_subnet_cidrs  = [for subnet_name in local.public_subnets_list : module.subnet_addrs.network_cidr_blocks[subnet_name]]
  private_subnet_cidrs = [for subnet_name in local.private_subnets_list : module.subnet_addrs.network_cidr_blocks[subnet_name]]
  public_subnets = { for idx, name in local.public_subnets_list : "public_sub${idx + 1}" => {
    name       = name
    cidr_block = local.public_subnet_cidrs[idx]
    type       = "public"
  } }
  private_subnets = { for idx, name in local.private_subnets_list : "private_sub${idx + 1}" => {
    name       = name
    cidr_block = local.private_subnet_cidrs[idx]
    type       = "private"
  } }
  subnet_maps                  = merge(local.public_subnets, local.private_subnets)
  public_subnet_id             = lookup(module.vcn.subnet_id, "public-subnet", null)
  netmaker_public_subnet_id    = lookup(module.vcn_netmaker[0].subnet_id, "netmaker-public", null)
  ssh_keys                     = []
  netmaker_public_subnets_list = ["netmaker-public"]
  netmaker_public_subnet_cidrs = [for subnet_name in local.netmaker_public_subnets_list : module.netmaker_subnet_addrs[0].network_cidr_blocks[subnet_name]]
  netmaker_public_subnets = { for idx, name in local.netmaker_public_subnets_list : "netmaker_public_sub${idx + 1}" => {
    name       = name
    cidr_block = local.netmaker_public_subnet_cidrs[idx]
    type       = "public"
  } }

}