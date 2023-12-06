data "oci_identity_availability_domain" "ad" {
  compartment_id = var.compartment_id
  ad_number      = var.ad_number
}

data "oci_core_subnet" "public_subnet" {
  subnet_id = module.base_infra.public_subnet_id
}

data "oci_core_instance" "gitlab_server_instance" {
  instance_id = oci_core_instance.gitlab_server.id
}


data "oci_identity_tenancy" "tenant_details" {
  tenancy_id = var.tenancy_id
}

data "oci_identity_regions" "home_region" {
  filter {
    name   = "key"
    values = [data.oci_identity_tenancy.tenant_details.home_region_key]
  }
}