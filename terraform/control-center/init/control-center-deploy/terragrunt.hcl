terraform {
  source = "git::${get_env("IAC_TERRAFORM_MODULES_REPO")}//terraform/${get_env("CONTROL_CENTER_CLOUD_PROVIDER")}/control-center-infra?ref=${get_env("IAC_TERRAFORM_MODULES_TAG")}"
}


generate "required_providers_override" {
  path = "required_providers_override.tf"

  if_exists = "overwrite_terragrunt"

  contents = <<EOF
terraform { 
  
  required_providers {
    %{ if get_env("CONTROL_CENTER_CLOUD_PROVIDER") == "aws" }
    aws = "${local.cloud_platform_vars.aws_provider_version}"
    awsutils = {
      source  = "cloudposse/awsutils"
      version = "${local.cloud_platform_vars.awsutils_provider_version}"
    }
    %{ endif }

    %{ if get_env("CONTROL_CENTER_CLOUD_PROVIDER") == "oci" }
    oci = {
      source  = "oracle/oci"
      version = "${local.cloud_platform_vars.oci_provider_version}"
    }
    %{ endif }
  }
}
%{ if get_env("CONTROL_CENTER_CLOUD_PROVIDER") == "aws" }
provider "aws" {
  region = "${local.env_vars.region}"
}
provider "awsutils" {
  region = "${local.env_vars.region}"
}
%{ endif }

%{ if get_env("CONTROL_CENTER_CLOUD_PROVIDER") == "oci" }
provider "oci" {
  region           = "${local.env_vars.region}"
  tenancy_ocid     = "${local.env_vars.tenancy_id}"
  user_ocid        = "${local.env_vars.user_id}"
  fingerprint      = "${local.env_vars.api_fingerprint}"
  private_key_path = "${local.env_vars.api_private_key_path}"
}
%{ endif }
EOF
}


inputs = {
  tags                           = local.tags
  domain                         = local.env_vars.domain
  cluster_name                   = local.env_vars.tenant
  gitlab_version                 = local.env_vars.gitlab_version
  gitlab_runner_version          = local.env_vars.gitlab_runner_version
  iac_group_name                 = local.env_vars.iac_group_name
  netmaker_image_version         = local.env_vars.netmaker_version
  delete_storage_on_term         = local.env_vars.delete_storage_on_term
  ad_count                       = local.env_vars.ad_count
  tenancy_id                     = local.env_vars.tenancy_id
  compartment_id                 = local.env_vars.compartment_id
}

locals {
  env_vars = yamldecode(
    file("${find_in_parent_folders("environment.yaml")}")
  )
  cloud_platform_vars = yamldecode(
    file("${find_in_parent_folders("${get_env("CONTROL_CENTER_CLOUD_PROVIDER")}-vars.yaml")}")
  )
  tags = local.env_vars.tags
}

include "root" {
  path = find_in_parent_folders()
}