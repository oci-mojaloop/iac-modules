
module "ubuntu_canonical_image" {
  source                         = "../ubuntu-img-id"
  compartment_id                 = var.compartment_id
  image_operating_system_version = "20.04"
}

module "base_infra" {
  source                    = "../base-infra"
  tenancy_id                = var.tenancy_id
  compartment_id            = var.compartment_id
  cluster_name              = var.cluster_name
  domain                    = var.domain
  tags                      = var.tags
  vcn_cidr                  = var.vcn_cidr
  create_public_zone        = var.create_public_zone
  create_private_zone       = var.create_private_zone
  manage_parent_domain      = var.manage_parent_domain
  manage_parent_domain_ns   = var.manage_parent_domain_ns
  ad_count                  = var.ad_count
  bastion_image_id          = module.ubuntu_canonical_image.id
  create_haproxy_dns_record = true
}

module "post_config" {
  source                     = "../post-config-k8s"
  tenancy_id                 = var.tenancy_id
  compartment_id             = var.compartment_id
  bucket_namespace           = var.bucket_namespace
  user_id                    = var.user_id
  api_fingerprint            = var.api_fingerprint
  api_private_key_path       = var.api_private_key_path
  name                       = var.cluster_name
  domain                     = var.domain
  tags                       = var.tags
  private_zone_id            = module.base_infra.private_zone.id
  public_zone_id             = module.base_infra.public_zone.id
  longhorn_backup_s3_destroy = var.longhorn_backup_object_store_destroy
}

module "k6s_test_harness" {
  count                       = var.enable_k6s_test_harness ? 1 : 0
  source                      = "../k6s-test-harness"
  compartment_id              = var.compartment_id
  cluster_name                = var.cluster_name
  domain                      = var.domain
  tags                        = var.tags
  vcn_cidr                    = var.vcn_cidr
  vcn_id                      = module.base_infra.vcn_id
  compute_image_id            = module.ubuntu_canonical_image.id
  docker_server_instance_type = var.k6s_docker_server_instance_type
  subnet_id                   = module.base_infra.private_subnet_id
  key_pair_name               = module.base_infra.key_pair_name
  public_zone_id              = module.base_infra.public_zone.id
  test_harness_hostname       = var.k6s_docker_server_fqdn
}

#############################
### Create Nodes
#############################
# resource "aws_launch_template" "master" {
#   name_prefix   = "${local.name}-master"
#   image_id      = module.ubuntu_focal_ami.id
#   instance_type = var.master_instance_type
#   user_data     = data.template_cloudinit_config.master.rendered
#   key_name      = module.base_infra.key_pair_name

#   block_device_mappings {
#     device_name = "/dev/sda1"

#     ebs {
#       encrypted   = true
#       volume_type = "gp2"
#       volume_size = var.master_volume_size
#     }
#   }

#   network_interfaces {
#     delete_on_termination = true
#     security_groups       = local.master_security_groups
#   }


#   tags = merge(
#     { Name = "${local.name}-master" },
#     local.common_tags
#   )


#   tag_specifications {
#     resource_type = "instance"

#     tags = merge(
#       { Name = "${local.name}-master" },
#       local.common_tags
#     )
#   }
#   tag_specifications {
#     resource_type = "volume"

#     tags = merge(
#       { Name = "${local.name}-master" },
#       local.common_tags
#     )
#   }
#   tag_specifications {
#     resource_type = "network-interface"

#     tags = merge(
#       { Name = "${local.name}-master" },
#       local.common_tags
#     )
#   }
#   lifecycle {
#     ignore_changes = [
#       image_id
#     ]
#   }
# }

# resource "aws_launch_template" "agent" {
#   name_prefix   = "${local.name}-agent"
#   image_id      = module.ubuntu_focal_ami.id
#   instance_type = var.agent_instance_type
#   user_data     = data.template_cloudinit_config.agent.rendered
#   key_name      = module.base_infra.key_pair_name

#   block_device_mappings {
#     device_name = "/dev/sda1"

#     ebs {
#       encrypted   = true
#       volume_type = "gp2"
#       volume_size = var.agent_volume_size
#     }
#   }

#   network_interfaces {
#     delete_on_termination = true
#     security_groups       = local.agent_security_groups
#   }

#   tags = merge(
#     { Name = "${local.name}-agent" },
#     local.common_tags
#   )

#   tag_specifications {
#     resource_type = "instance"

#     tags = merge(
#       { Name = "${local.name}-agent" },
#       local.common_tags
#     )
#   }
#   tag_specifications {
#     resource_type = "volume"

#     tags = merge(
#       { Name = "${local.name}-agent" },
#       local.common_tags
#     )
#   }
#   tag_specifications {
#     resource_type = "network-interface"

#     tags = merge(
#       { Name = "${local.name}-agent" },
#       local.common_tags
#     )
#   }
#   lifecycle {
#     ignore_changes = [
#       image_id
#     ]
#   }
# }

# resource "aws_autoscaling_group" "master" {
#   name_prefix         = "${local.name}-master"
#   desired_capacity    = var.master_node_count
#   max_size            = var.master_node_count
#   min_size            = var.master_node_count
#   vpc_zone_identifier = module.base_infra.private_subnets

#   # Join the master to the internal load balancer for the kube api on 6443
#   target_group_arns = local.master_target_groups

#   launch_template {
#     id      = aws_launch_template.master.id
#     version = "$Latest"
#   }
#   tag {
#     key                 = "Name"
#     value               = "${local.name}-master"
#     propagate_at_launch = false
#   }
#   tag {
#     key                 = "Cluster"
#     value               = var.cluster_name
#     propagate_at_launch = false
#   }
#   tag {
#     key                 = "Domain"
#     value               = local.base_domain
#     propagate_at_launch = false
#   }
# }

# resource "aws_autoscaling_group" "agent" {
#   name_prefix         = "${local.name}-agent"
#   desired_capacity    = var.agent_node_count
#   max_size            = var.agent_node_count
#   min_size            = var.agent_node_count
#   vpc_zone_identifier = module.base_infra.private_subnets

#   target_group_arns = local.agent_target_groups

#   launch_template {
#     id      = aws_launch_template.agent.id
#     version = "$Latest"
#   }
#   tag {
#     key                 = "Name"
#     value               = "${local.name}-agent"
#     propagate_at_launch = false
#   }
#   tag {
#     key                 = "Cluster"
#     value               = var.cluster_name
#     propagate_at_launch = false
#   }
#   tag {
#     key                 = "Domain"
#     value               = local.base_domain
#     propagate_at_launch = false
#   }

# }

# data "aws_instances" "master" {
#   instance_tags = merge({ Name = "${local.name}-master" }, local.identifying_tags)
#   depends_on    = [aws_autoscaling_group.master]
# }

# data "aws_instances" "agent" {
#   count         = var.agent_node_count > 0 ? 1 : 0
#   instance_tags = merge({ Name = "${local.name}-agent" }, local.identifying_tags)
#   depends_on    = [aws_autoscaling_group.agent]
# }

# data "template_cloudinit_config" "agent" {
#   gzip          = true
#   base64_encode = true

#   # Main cloud-config configuration file.
#   part {
#     filename     = "init.cfg"
#     content_type = "text/cloud-config"
#     content      = templatefile("${path.module}/templates/cloud-config-base.yaml", { ssh_keys = local.ssh_keys })
#   }
# }

# data "template_cloudinit_config" "master" {
#   gzip          = true
#   base64_encode = true

#   # Main cloud-config configuration file.
#   part {
#     filename     = "init.cfg"
#     content_type = "text/cloud-config"
#     content      = templatefile("${path.module}/templates/cloud-config-base.yaml", { ssh_keys = local.ssh_keys })
#   }
# }

# locals {
#   base_security_groups    = [aws_security_group.self.id, module.base_infra.default_security_group_id]
#   traffic_security_groups = [aws_security_group.ingress.id]
#   kubeapi_target_groups = [
#     aws_lb_target_group.internal_kubeapi.arn
#   ]
#   traffic_target_groups = [
#     aws_lb_target_group.external_http.arn,
#     aws_lb_target_group.external_https.arn,
#     aws_lb_target_group.internal_http.arn,
#     aws_lb_target_group.internal_https.arn,
#     aws_lb_target_group.wireguard.arn
#   ]
#   master_target_groups   = var.master_node_supports_traffic ? concat(local.kubeapi_target_groups, local.traffic_target_groups) : local.kubeapi_target_groups
#   agent_target_groups    = local.traffic_target_groups
#   master_security_groups = var.master_node_supports_traffic ? concat(local.base_security_groups, local.traffic_security_groups) : local.base_security_groups
#   agent_security_groups  = concat(local.base_security_groups, local.traffic_security_groups)
# }