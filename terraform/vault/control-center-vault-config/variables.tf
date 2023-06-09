variable "vault_token" {
  description = "token for connecting to vault"
  sensitive = true
}
variable "gitlab_admin_rbac_group" {
  type        = string
  description = "rbac group in gitlab for admin access via oidc"
}
variable "gitlab_hostname" {
  description = "gitlab hostname for oidc"
}

variable "vault_oauth_app_client_id" {
  description = "client id for gitlab oidc"
  sensitive = true
}
variable "vault_oauth_app_client_secret" {
  description = "client secret for gitlab oidc"
  sensitive = true
}
variable "vault_fqdn" {
  description = "vault_fqdn"
}