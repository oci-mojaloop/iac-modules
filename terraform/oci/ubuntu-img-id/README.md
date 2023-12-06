# Image ID Finder for Ubuntu Images

Use this module to find the OCI ID for the version of Ubuntu for your region

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0.0 |
| oci | ~> 4.67.3 |

## Providers

| Name | Version |
|------|---------|
| oci | ~> 4.67.3 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| compartment\_id | compartment ocid where resources to be created | `string` | `None` | yes |
| image\_operating\_system\_version | ubuntu os version | `string` | `20.04` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | ocid of the Image |

