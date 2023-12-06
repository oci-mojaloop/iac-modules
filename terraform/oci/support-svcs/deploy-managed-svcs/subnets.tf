module "subnet_addrs" {
  source = "hashicorp/subnets/cidr"

  base_cidr_block = var.vcn_cidr
  networks = [
    for subnet in concat(local.private_subnets_list, local.public_subnets_list, local.mysql_subnets_list) : {
      name     = subnet
      new_bits = var.new_bits
    }
  ]

}

resource "oci_core_subnet" "mysql_subnet" {
  cidr_block                 = local.mysql_subnets_cidrs[0]
  compartment_id             = var.compartment_id
  vcn_id                     = module.base_infra[0].vcn_id
  display_name               = "mysql-subnet"
  dns_label                  = "mysql"
  freeform_tags              = merge({ Name = "${var.deployment_name}-mgmt-svcs-subnet" }, local.common_tags)
  prohibit_public_ip_on_vnic = true
  route_table_id             = module.base_infra[0].nat_route_id
  security_list_ids          = [oci_core_security_list.managed_svcs.id]
}