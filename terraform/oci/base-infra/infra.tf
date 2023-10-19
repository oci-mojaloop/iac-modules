module "subnet_addrs" {
  source = "hashicorp/subnets/cidr"

  base_cidr_block = var.vcn_cidr
  networks = [
    for subnet in concat(local.private_subnets_list, local.public_subnets_list) : {
      name     = subnet
      new_bits = var.block_size
    }
  ]

}

resource "tls_private_key" "compute_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

