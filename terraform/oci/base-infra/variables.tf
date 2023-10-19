

variable "tenancy_id" {
  description = "The tenancy id of the OCI Cloud Account in which to create the resources."
  type        = string
}

variable "ad_count" {
  type        = number
  default     = 1
  description = "Number of ads"
}

variable "vcn_cidr" {
  default     = "10.25.0.0/22"
  type        = string
  description = "CIDR Subnet to use for the VCN, will be split into multiple /24s for the required private and public subnets"
}

variable "block_size" {
  type = number
  default = 3
}

###
# Local copies of variables to allow for parsing
###
locals {
  ads = slice(data.oci_identity_availability_domains.ads.availability_domains, 0, var.ad_count)
  public_subnets_list  = [for ad in local.ads : "public-${ad.name}"]
  private_subnets_list = [for ad in local.ads : "private-${ad.name}"]
  public_subnet_cidrs  = [for subnet_name in local.public_subnets_list : module.subnet_addrs.network_cidr_blocks[subnet_name]]
  private_subnet_cidrs = [for subnet_name in local.private_subnets_list : module.subnet_addrs.network_cidr_blocks[subnet_name]]
}