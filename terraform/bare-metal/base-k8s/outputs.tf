output "bastion_ssh_key" {
  sensitive = true
  value = module.base_infra.ssh_private_key
}

output "bastion_public_ip" {
  value = module.base_infra.bastion_public_ip
}

output "bastion_os_username" {
  value = var.os_user_name
}

output "master_hosts_var_maps" {
  sensitive = true
  value = {
    repo_url = var.gitlab_project_url
    gitlab_server_url = var.gitlab_server_url
    gitlab_project_id = var.current_gitlab_project_id
    repo_username = var.gitlab_username
    repo_password = var.gitlab_token
  }
}

output "all_hosts_var_maps" {
  sensitive = true
  value = {
    ansible_ssh_user             = var.os_user_name
    ansible_ssh_retries          = "10"
    base_domain                  = local.base_domain
    netmaker_join_token = module.post_config.netmaker_token
  }
}

output "agent_hosts_var_maps" {
  sensitive = false
  value = {
    master_ip = data.aws_instances.master.private_ips[0]
  }
}

output "bastion_hosts_var_maps" {
  sensitive = true
  value = {
    ansible_ssh_common_args = "-o StrictHostKeyChecking=no"
  }
}

output "bastion_hosts" {
  value = { bastion = module.base_infra.bastion_public_ip }
}

output "agent_hosts" {
  value = { for i, id in data.aws_instances.agent[0].ids : id => data.aws_instances.agent[0].private_ips[i] }
}

output "master_hosts" {
  value = { for i, id in data.aws_instances.master.ids : id => data.aws_instances.master.private_ips[i] }
}