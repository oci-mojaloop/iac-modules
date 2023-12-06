resource "tls_private_key" "gitlab_ci_dns_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}
