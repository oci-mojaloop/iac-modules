### For OCI , we created api key for external dns user. Need to figure out how this return value will be used. 
### Till that time we will keep it commented
output "secrets_var_map" {
  sensitive = true
  value = {
    # route53_external_dns_access_key = aws_iam_access_key.route53-external-dns.id
    # route53_external_dns_secret_key = aws_iam_access_key.route53-external-dns.secret
    longhorn_backups_access_key     = oci_identity_customer_secret_key.longhorn_backups_secret_key.id
    longhorn_backups_secret_key     = oci_identity_customer_secret_key.longhorn_backups_secret_key.key
  }
}

output "properties_var_map" {
  value = {
    longhorn_backups_bucket_name = oci_objectstorage_bucket.longhorn_backups.name
  }
}

### For OCI , we created api key for external dns user. Need to figure out how this return value will be used. 
### Till that time we will keep it commented
output "post_config_secrets_key_map" {
  value = {
    # external_dns_cred_id_key         = "route53_external_dns_access_key"
    # external_dns_cred_secret_key     = "route53_external_dns_secret_key"
    longhorn_backups_cred_id_key     = "longhorn_backups_access_key"
    longhorn_backups_cred_secret_key = "longhorn_backups_secret_key"
  }
}

output "post_config_properties_key_map" {
  value = {
    longhorn_backups_bucket_name_key = "longhorn_backups_bucket_name"
  }
}
