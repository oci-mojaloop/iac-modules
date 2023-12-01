terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">=4.67.3"
    }
  }
  required_version = ">= 1.0.0"
}

provider "oci" {
  tenancy_ocid     = var.tenancy_id
  user_ocid        = var.user_id
  fingerprint      = var.api_fingerprint
  private_key_path = var.api_private_key_path
  region           = var.region
}

# OCI Provider parameters
variable "api_fingerprint" {
  default     = ""
  description = "Fingerprint of the API private key to use with OCI API."
  type        = string
}

variable "api_private_key_path" {
  default     = ""
  description = "The path to the OCI API private key."
  type        = string
}

variable "tenancy_id" {
  description = "The tenancy id of the OCI Cloud Account in which to create the resources."
  type        = string
}

variable "bucket_namespace" {
  description = "The Object Storage namespace used for the request."
  type        = string
}

variable "user_id" {
  description = "The id of the user that terraform will use to create the resources."
  type        = string
  default     = ""
}

variable "region" {
  type        = string
  description = "The OCI region"
}

variable "compartment_id" {
  type        = string
  description = "compartment ocid"
}

variable "tags" {
  description = "Contains default tags for this project"
  type        = map(string)
  default     = {}
}


module "control-center-infra" {
  source                    = "./control-center-infra"
  tenancy_id                = var.tenancy_id
  compartment_id            = var.compartment_id
  cluster_name              = "test"
  domain                    = "oci.mojaloop"
  ad_count                  = 1
  tags                      = var.tags
}

# data "oci_identity_availability_domains" "ads" {
#   compartment_id = var.tenancy_id
# }

# module "subnet_addrs" {
#   source = "hashicorp/subnets/cidr"

#   base_cidr_block = "10.25.0.0/22"
#   networks = [
#     for subnet in concat(local.private_subnets_list, local.public_subnets_list) : {
#       name     = subnet
#       new_bits = 1
#     }
#   ]

# }

# locals {
#   ads                  = slice(data.oci_identity_availability_domains.ads.availability_domains, 0, 3)
#   # public_subnets_list  = [for ad in local.ads : "public-${ad.name}"]
#   # private_subnets_list = [for ad in local.ads : "private-${ad.name}"]
#   public_subnets_list  = ["public-subnet"]
#   private_subnets_list = ["private-subnet"]
#   public_subnet_cidrs  = [for subnet_name in local.public_subnets_list : module.subnet_addrs.network_cidr_blocks[subnet_name]]
#   private_subnet_cidrs = [for subnet_name in local.private_subnets_list : module.subnet_addrs.network_cidr_blocks[subnet_name]]

#   public_subnets = { for idx, name in local.public_subnets_list : "public_sub${idx + 1}" => {
#     name       = name
#     cidr_block = local.public_subnet_cidrs[idx]
#     type       = "public"
#   } }

#   private_subnets = { for idx, name in local.private_subnets_list : "private_sub${idx + 1}" => {
#     name       = name
#     cidr_block = local.private_subnet_cidrs[idx]
#     type       = "private"
#   } }

#   subnet_maps = merge(local.public_subnets, local.private_subnets)
# }




# output "public_subnets_list" {
#   description = "public subnet list"
#   value       = local.public_subnets_list
# }

# output "private_subnets_list" {
#   description = "private subnet list"
#   value       = local.private_subnets_list
# }

# output "public_subnets_cidrs" {
#   description = "public subnet cidr"
#   value       = local.public_subnet_cidrs
# }

# output "private_subnets_cidr" {
#   description = "private subnet cidr"
#   value       = local.private_subnet_cidrs
# }

# output "vcn_id" {
#   value = module.base_k8s.vcn_id
# }

