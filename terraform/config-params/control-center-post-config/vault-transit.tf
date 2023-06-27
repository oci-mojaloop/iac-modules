resource "vault_mount" "kv_secret" {
  path                      = var.kv_path
  type                      = "kv-v2"
  options                   = { version = "2" }
  default_lease_ttl_seconds = "120"
}

resource "vault_mount" "transit" {
  path        = "transit"
  type        = "transit"
  description = "transit mount for cluster vault unsealing"
}

resource "vault_transit_secret_backend_key" "unseal_key" {
  for_each = var.env_map
  backend  = vault_mount.transit.path
  name     = "unseal-key-${each.key}"
}

resource "vault_policy" "env_transit" {
  for_each = var.env_map
  name     = "env-transit-${each.key}"

  policy = <<EOT
path "${vault_mount.kv_secret.path}/${each.key}/*" {
  capabilities = ["read", "list"]
}

path "${vault_mount.transit.path}/encrypt/${vault_transit_secret_backend_key.unseal_key[each.key].name}" {
  capabilities = [ "update" ]
}

path "${vault_mount.transit.path}/decrypt/${vault_transit_secret_backend_key.unseal_key[each.key].name}" {
  capabilities = [ "update" ]
}
EOT
}

resource "vault_token" "env_token" {
  for_each  = var.env_map
  policies  = [vault_policy.env_transit[each.key].name]
  no_parent = true
}

resource "vault_kv_secret_v2" "env_token" {
  for_each            = var.env_map
  mount               = vault_mount.kv_secret.path
  name                = "${each.key}/env_token"
  delete_all_versions = true
  data_json = jsonencode(
    {
      value = vault_token.env_token[each.key].client_token
    }
  )
}
