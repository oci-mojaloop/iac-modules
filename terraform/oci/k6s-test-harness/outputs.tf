output "test_harness_private_ip" {
  description = "ip to connect to test harness"
  value       = oci_core_instance.docker_server.private_ip
}

output "test_harness_fqdn" {
  description = "fqdn to connect to test harness"
  value       = oci_dns_rrset.test_harness_private.domain
}

output "var_map" {
  value = {
    docker_extra_volume_name    = "docker-extra"
    docker_extra_vol_mount      = true
    docker_extra_ebs_volume_id  = oci_core_volume.docker_server_block_volume.id
    docker_extra_volume_size_mb = var.docker_server_extra_vol_size * 1074
    k6s_callback_fqdn           = oci_dns_rrset.test_harness_private.domain
  }
}
