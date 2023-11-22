resource "tls_private_key" "user_external_dns_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}
