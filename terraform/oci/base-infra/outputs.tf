output "bastion_public_ip" {
  description = "Bastion Instance Hostname"
  value       = oci_core_instance.bastion.public_ip
}

output "ssh_private_key" {
  description = "Private key in PEM format"
  value       = tls_private_key.compute_ssh_key.private_key_pem
  sensitive   = true
}

output "nat_public_ips" {
  description = "nat gateway public ips"
  value       = data.oci_core_nat_gateway.nat_gateway.nat_ip
}

output "private_zone" {
  value = local.private_zone
}

output "public_zone" {
  value = local.public_zone
}

output "vcn_id" {
  value = module.vcn.vcn_id
}

output "subnet_id" {
  value = module.vcn.subnet_id
}

output "public_subnet_id" {
  value = module.vcn.subnet_id.public-subnet
}

output "private_subnet_id" {
  value = module.vcn.subnet_id.private-subnet
}


output "private_subnets_cidr_blocks" {
  value = module.vcn.subnet_all_attributes.private_sub1.cidr_block
}

# output "default_security_group_id" {
#   value = module.vpc.default_security_group_id
# }

output "bastion_security_group_id" {
  value = oci_core_network_security_group.bastion.id
}


output "netmaker_public_ip" {
  description = "Netmaker Instance Hostname"
  value       = var.enable_netmaker ? oci_core_instance.netmaker[0].public_ip : null
}


output "key_pair_name" {
  value = local.cluster_domain
}

output "haproxy_server_fqdn" {
  description = "haproxy server Hostname"
  value       = var.create_haproxy_dns_record ? oci_dns_rrset.haproxy_server_private[0].domain : ""
}