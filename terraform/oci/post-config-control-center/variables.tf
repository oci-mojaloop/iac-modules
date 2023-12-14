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

variable "spf_record" {
  description = "An SPF TXT record is used to establish trust between sending and receiving mail servers."
  type        = string
  # default     = "=spf1 include:rp.oracleemaildelivery.com include:ap.rp.oracleemaildelivery.com include:eu.rp.oracleemaildelivery.com ~all"
  default     = "v=spf1 include:ap.rp.oracleemaildelivery.com ~all"
}

variable "gitlab_block_volume_id" {
  description = "The block volume id of gitlab."
  type        = string
}

variable "public_zone_id" {
  type        = string
  description = "route53 public zone id"
}

variable "private_zone_id" {
  type        = string
  description = "route53 private zone id"
}

variable "name" {
  type        = string
  description = "unique name for deployment"
}

variable "domain" {
  type        = string
  description = "domain name for deployment"
}

variable "tags" {
  description = "Contains default tags for this project"
  type        = map(string)
  default     = {}
}
variable "days_retain_gitlab_snapshot" {
  type        = number
  description = "number of days to retain gitlab snapshots"
  default     = 7
}