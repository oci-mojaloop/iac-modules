variable "compartment_id" {
  type        = string
  description = "compartment ocid"
}

variable "region" {
  type        = string
  description = "The OCI region"
}

variable "operator_shape" {
  description = "The shape of the operator instance."
  default = {
    shape = "VM.Standard.E4.Flex", ocpus = 4, memory = 32, boot_volume_size = 50
  }
  type = map(any)
}

variable "compute_state" {
  description = "The target state for the instance. Could be set to RUNNING or STOPPED. (Updatable)"
  default     = "RUNNING"
  type        = string
}

variable "ad_number" {
  description = "the AD to place the operator host"
  default     = 1
  type        = number
}

variable "cluster_name" {
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

variable "compute_image_id" {
  description = "compute image id for docker server"
}

variable "vcn_cidr" {
  description = "CIDR Subnet to use for the VPC"
}

variable "vcn_id" {
  description = "vpc id for security group"
}

variable "subnet_id" {
  description = "subnet to place docker server"
}

variable "key_pair_name" {
  description = "key_pair_name for docker server"
}

variable "os_user_name" {
  default     = "ubuntu"
  type        = string
  description = "os username for bastion host"
}

variable "delete_storage_on_term" {
  description = "delete_storage_on_term"
  type        = bool
  default     = false
}

variable "k6s_listening_ports" {
  type        = list
  default     = ["5050", "5000", "6060", "25001", "25002", "25003", "25004", "25005", "25006", "25007", "25008", "9999", "9090", "9080"]
  description = "which ports to listen for k6s"
}

variable "docker_server_instance_type" {
  type        = string
  default     = "m5.2xlarge"
  description = "vm size for docker server"
}

variable "docker_server_root_vol_size" {
  type        = number
  default     = 50
  description = "root vol size for docker server"
}

variable "docker_server_extra_vol_size" {
  type        = number
  default     = 100
  description = "extra vol size for docker server"
}

variable "public_zone_id" {
  description = "zone id to add dns record"
}

variable "test_harness_hostname" {
  description = "hostname to add to dns"
  default     = "test-harness"
}

locals {
  cluster_domain        = "${replace(var.cluster_name, "-", "")}.${var.domain}"
  name             = var.cluster_name
  base_domain      = "${replace(var.cluster_name, "-", "")}.${var.domain}"
  identifying_tags = { Cluster = var.cluster_name, Domain = local.base_domain }
  common_tags      = merge(local.identifying_tags, var.tags)
}
