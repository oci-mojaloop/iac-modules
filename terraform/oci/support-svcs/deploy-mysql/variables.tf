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

variable "db_subnet_id" {
  description = "The subnet id for db services"
  type        = string
}

variable "ad_number" {
  description = "the AD to place the operator host"
  default     = 1
  type        = number
}

variable "deployment_name" {
  description = "Cluster name, lower case and without spaces. This will be used to set tags and name resources"
  type        = string
}

variable "tags" {
  description = "Contains default tags for this project"
  type        = map(string)
}

variable "db_services" {
  description = "db services to create"
}


variable "block_size" {
  type    = number
  default = 3
}

###
# Local copies of variables to allow for parsing
###
locals {
  identifying_tags = { vpc = var.deployment_name }
  common_tags      = merge(local.identifying_tags, var.tags)
}