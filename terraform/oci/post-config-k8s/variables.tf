###
# Required variables without default values
###

variable "compartment_id" {
  type        = string
  description = "compartment ocid"
}

variable "tenancy_id" {
  description = "The tenancy id of the OCI Cloud Account in which to create the resources."
  type        = string
}

variable "region" {
  type        = string
  description = "The OCI region"
}

# variable "api_fingerprint" {
#   default     = ""
#   description = "Fingerprint of the API private key to use with OCI API."
#   type        = string
# }

# variable "api_private_key_path" {
#   default     = ""
#   description = "The path to the OCI API private key."
#   type        = string
# }

# variable "user_id" {
#   description = "The id of the user that terraform will use to create the resources."
#   type        = string
#   default     = ""
# }

variable "bucket_namespace" {
  description = "The Object Storage namespace used for the request."
  type        = string
}

variable "name" {
  description = "Cluster name, lower case and without spaces. This will be used to set tags and name resources"
  type        = string
}

variable "domain" {
  description = "Base domain to attach the cluster to."
  type        = string
}

variable "tags" {
  description = "Contains default tags for this project"
  type        = map(string)
  default     = {}
}

variable "public_zone_id" {
  type        = string
  description = "public_zone_id"
}

variable "private_zone_id" {
  type        = string
  description = "private_zone_id"
}

variable "longhorn_backup_s3_destroy" {
  description = "destroy s3 backup on destroy of env"
  type        = bool
  default     = false
}

###
# Local copies of variables to allow for parsing
###
locals {
  base_domain = "${replace(var.name, "-", "")}.${var.domain}"
}