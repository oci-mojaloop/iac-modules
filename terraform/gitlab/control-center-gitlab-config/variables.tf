
variable "iac_user_key_secret" {
  description = "iam user key secret"
}

variable "iac_user_key_id" {
  description = "iam user keyid"
}

variable "gitlab_admin_rbac_group" {
  type        = string
  description = "rbac group in gitlab for admin access via oidc"
}

variable "gitlab_readonly_rbac_group" {
  type        = string
  description = "rbac group in gitlab for readonly access via oidc"
}

variable "two_factor_grace_period" {
  description = "two_factor_grace_period in hours"
  default     = 0
}

variable "enable_netmaker_oidc" {
  type        = bool
  default     = true
  description = "enable oidc config of netmaker"
}

variable "netmaker_oidc_redirect_url" {
  description = "netmaker_oidc_redirect_url"
  default     = ""
}

variable "private_repo_user" {
  default = ""
}

variable "private_repo_token" {
  default = ""
}
variable "iac_terraform_modules_tag" {
  description = "tag for repo for modules"
}
variable "iac_templates_tag" {
  description = "tag for repo for templates"
}
variable "control_center_cloud_provider" {
  description = "control_center_cloud_provider"
}