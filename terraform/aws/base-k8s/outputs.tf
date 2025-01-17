output "nat_public_ips" {
  description = "nat gateway public ips"
  value       = module.base_infra.nat_public_ips
}

output "internal_load_balancer_dns" {
  value = aws_lb.internal.dns_name
}

output "external_load_balancer_dns" {
  value = aws_lb.lb.dns_name
}

output "private_subdomain" {
  value = module.base_infra.private_zone.name
}

output "public_subdomain" {
  value = module.base_infra.public_zone.name
}

output "internal_interop_switch_fqdn" {
  value = "${var.int_interop_switch_subdomain}.${trimsuffix(module.base_infra.public_zone.name, ".")}"
}

output "external_interop_switch_fqdn" {
  value = "${var.ext_interop_switch_subdomain}.${trimsuffix(module.base_infra.public_zone.name, ".")}"
}

output "target_group_internal_https_port" {
  value = var.target_group_internal_https_port
}
output "target_group_internal_http_port" {
  value = var.target_group_internal_http_port
}
output "target_group_external_https_port" {
  value = var.target_group_external_https_port
}
output "target_group_external_http_port" {
  value = var.target_group_external_http_port
}

output "target_group_internal_health_port" {
  value = var.target_group_internal_health_port
}
output "target_group_external_health_port" {
  value = var.target_group_external_health_port
}

output "private_network_cidr" {
  value = var.vpc_cidr
}

###new items

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

output "haproxy_server_fqdn" {
  value = module.base_infra.haproxy_server_fqdn
}

output "master_hosts_var_maps" {
  value = {}
}

output "master_hosts_yaml_maps" {
  value = {}
}

output "secrets_var_map" {
  sensitive = true
  value     = module.post_config.secrets_var_map
}

output "properties_var_map" {
  value = module.post_config.properties_var_map
}

output "properties_key_map" {
  value = module.post_config.post_config_properties_key_map
}

output "secrets_key_map" {
  value = module.post_config.post_config_secrets_key_map
}

output "all_hosts_var_maps" {
  sensitive = false
  value = {
    ansible_ssh_user             = var.os_user_name
    ansible_ssh_retries          = "10"
    base_domain                  = local.base_domain
    internal_interop_switch_fqdn = "${var.int_interop_switch_subdomain}.${trimsuffix(module.base_infra.public_zone.name, ".")}"
    external_interop_switch_fqdn = "${var.ext_interop_switch_subdomain}.${trimsuffix(module.base_infra.public_zone.name, ".")}"
    kubeapi_loadbalancer_fqdn    = aws_lb.internal.dns_name
  }
}

output "agent_hosts_var_maps" {
  sensitive = true
  value = {
    master_ip = data.aws_instances.master.private_ips[0]
  }
}

output "agent_hosts_yaml_maps" {
  value = {}
}

output "bastion_hosts_var_maps" {
  sensitive = false
  value = {
    ansible_ssh_common_args = "-o StrictHostKeyChecking=no"
    egress_gateway_cidr     = var.vpc_cidr
  }
}

output "bastion_hosts_yaml_maps" {
  value = {}
}

output "bastion_hosts" {
  value = { bastion = module.base_infra.bastion_public_ip }
}

output "agent_hosts" {
  value = var.agent_node_count > 0 ? { for i, id in data.aws_instances.agent[0].ids : id => data.aws_instances.agent[0].private_ips[i] } : {}
}

output "master_hosts" {
  value = { for i, id in data.aws_instances.master.ids : id => data.aws_instances.master.private_ips[i] }
}

output "test_harness_hosts" {
  value = var.enable_k6s_test_harness ? { test_harness = module.k6s_test_harness[0].test_harness_private_ip } : {}
}

output "test_harness_hosts_var_maps" {
  value = var.enable_k6s_test_harness ? module.k6s_test_harness[0].var_map : {}
}
