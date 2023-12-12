output "gitlab_root_password" {
  sensitive = true
  value     = random_password.gitlab_root_password.result
}

output "gitlab_root_token" {
  sensitive = true
  value     = random_password.gitlab_root_token.result
}

output "gitlab_s3_access_key" {
  sensitive = true
  value     = random_password.gitlab_s3_access_key.result
}

output "gitlab_s3_access_secret" {
  sensitive = true
  value     = random_password.gitlab_s3_access_secret.result
}

output "admin_s3_access_key" {
  sensitive = true
  value     = random_password.admin_s3_access_key.result
}

output "admin_s3_access_secret" {
  sensitive = true
  value     = random_password.admin_s3_access_secret.result
}

output "nexus_admin_password" {
  sensitive = true
  value     = random_password.nexus_admin_password.result
}

output "netmaker_oidc_callback_url" {
  value = var.enable_netmaker ? "https://${oci_dns_rrset.netmaker_api[0].domain}/api/oauth/callback" : ""
}

output "gitlab_server_hostname" {
  value = oci_dns_rrset.gitlab_server_public.domain
}

output "bastion_ssh_key" {
  sensitive = true
  value     = module.base_infra.ssh_private_key
}

output "bastion_public_ip" {
  value = module.base_infra.bastion_public_ip
}

output "bastion_os_username" {
  value = var.os_user_name
}

output "nexus_docker_repo_listening_port" {
  value = var.nexus_docker_repo_listening_port
}

output "nexus_fqdn" {
  value = oci_dns_rrset.nexus_server_private.domain
}

output "seaweedfs_s3_listening_port" {
  value = var.seaweedfs_s3_listening_port
}

output "seaweedfs_fqdn" {
  value = oci_dns_rrset.seaweedfs_server_private.domain
}

output "tenant_vault_listening_port" {
  value = "443"
}

output "vault_fqdn" {
  value = oci_dns_rrset.vault_server_private.domain
}

output "gitlab_hosts_var_maps" {
  sensitive = true
  value = {
    ansible_hostname        = oci_dns_rrset.gitlab_server_public.domain
    smtp_server_enable      = var.smtp_server_enable
    smtp_server_address     = var.smtp_server_address
    smtp_server_port        = var.smtp_server_port
    smtp_server_user        = var.smtp_server_user
    smtp_server_pw          = var.smtp_server_pw
    smtp_server_mail_domain = var.smtp_server_mail_domain
    enable_github_oauth     = var.enable_github_oauth
    github_oauth_id         = var.github_oauth_id
    github_oauth_secret     = var.github_oauth_secret
    letsencrypt_endpoint    = var.acme_api_endpoint
    server_password         = random_password.gitlab_root_password.result
    server_token            = random_password.gitlab_root_token.result
    server_hostname         = oci_dns_rrset.gitlab_server_public.domain
    enable_pages            = false
    gitlab_version          = var.gitlab_version
    s3_username             = random_password.gitlab_s3_access_key.result
    s3_password             = random_password.gitlab_s3_access_secret.result
    s3_server_url           = "http://${oci_dns_rrset.seaweedfs_server_private.domain}:${var.seaweedfs_s3_listening_port}"
    backup_ebs_volume_id    = oci_core_volume.gitlab_server_block_volume.id
    backup_volume_disk_name = "/dev/sdb"
  }
}

output "all_hosts_var_maps" {
  value = {
    ansible_ssh_user       = var.os_user_name
    ansible_ssh_retries    = "10"
    base_domain            = local.base_domain
    gitlab_external_url    = "https://${oci_dns_rrset.gitlab_server_public.domain}"
    netmaker_image_version = var.netmaker_image_version
    cloud_platform         = var.cloud_platform
  }
}

output "docker_hosts_var_maps" {
  sensitive = true
  value = {
    ansible_hostname                 = oci_dns_rrset.gitlab_runner_server_private.domain
    gitlab_server_hostname           = oci_dns_rrset.gitlab_server_public.domain
    gitlab_runner_version            = var.gitlab_runner_version
    seaweedfs_s3_server_host         = oci_dns_rrset.seaweedfs_server_private.domain
    seaweedfs_s3_listening_port      = var.seaweedfs_s3_listening_port
    seaweedfs_s3_admin_user          = "admin"
    seaweedfs_s3_admin_access_key    = random_password.admin_s3_access_key.result
    seaweedfs_s3_admin_secret_key    = random_password.admin_s3_access_secret.result
    seaweedfs_s3_gitlab_user         = "gitlab"
    seaweedfs_s3_gitlab_access_key   = random_password.gitlab_s3_access_key.result
    seaweedfs_s3_gitlab_secret_key   = random_password.gitlab_s3_access_secret.result
    nexus_admin_password             = random_password.nexus_admin_password.result
    nexus_docker_repo_listening_port = var.nexus_docker_repo_listening_port
    docker_extra_volume_name         = "docker-extra"
    docker_extra_vol_mount           = true
    docker_extra_ebs_volume_id       = oci_core_volume.docker_server_block_volume.id
    docker_extra_disk_name           = "/dev/sdb"
    docker_extra_volume_size_mb      = var.docker_server_extra_vol_size * 1074
    seaweedfs_num_volumes            = 100
    vault_listening_port             = var.vault_listening_port
    vault_fqdn                       = oci_dns_rrset.vault_server_private.domain
    vault_gitlab_token               = random_password.gitlab_root_token.result
    cloud_platform                   = var.cloud_platform
  }
}

output "netmaker_hosts_var_maps" {
  sensitive = true
  value = {
    netmaker_base_domain                        = oci_dns_zone.public_netmaker[0].name
    netmaker_server_public_ip                   = module.base_infra.netmaker_public_ip
    netmaker_master_key                         = random_password.netmaker_master_key.result
    netmaker_mq_pw                              = random_password.netmaker_mq_pw.result
    netmaker_admin_password                     = random_password.netmaker_admin_password.result
    netmaker_oidc_issuer                        = "https://${oci_dns_rrset.gitlab_server_public.domain}"
    netmaker_control_network_name               = var.netmaker_control_network_name
    ansible_ssh_common_args                     = "-o StrictHostKeyChecking=no"
    cloud_platform                              = var.cloud_platform
    netmaker_control_network_address_cidr_start = var.vcn_cidr
  }
}

output "bastion_hosts_var_maps" {
  sensitive = true
  value = {
    netmaker_api_host       = oci_dns_rrset.netmaker_api[0].domain
    netmaker_image_version  = var.netmaker_image_version
    ansible_ssh_common_args = "-o StrictHostKeyChecking=no"
    egress_gateway_cidr     = var.vcn_cidr
    netmaker_master_key     = random_password.netmaker_master_key.result
    cloud_platform          = var.cloud_platform
  }
}

output "bastion_hosts" {
  value = { bastion = module.base_infra.bastion_public_ip }
}

output "docker_hosts" {
  value = { docker = oci_core_instance.docker_server.private_ip }
}

output "gitlab_hosts" {
  value = { gitlab_server = oci_core_instance.gitlab_server.private_ip }
}

output "netmaker_hosts" {
  value = { netmaker_server = module.base_infra.netmaker_public_ip }
}

## We need to figure out an equivalent of this for oci.
output "iac_user_key_id" {
  description = "key id for iac user for gitlab-ci"
  value       = "dummy-value"
  sensitive   = false
}

output "iac_user_key_secret" {
  description = "key secret for iac user for gitlab-ci"
  value       = "dummy-value"
  sensitive   = true
}

output "iac_user_instance_principal" {
  description = "Env variable for using instance principal based authentication"
  value       = "instance_principal"
}

output "public_zone_name" {
  value = module.base_infra.public_zone.name
}
