# resource "aws_iam_role" "dlm_lifecycle_role" {
#   name = "dlm-lifecycle-role-${var.domain}"

#   assume_role_policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Action": "sts:AssumeRole",
#       "Principal": {
#         "Service": "dlm.amazonaws.com"
#       },
#       "Effect": "Allow",
#       "Sid": "1"
#     }
#   ]
# }
# EOF
# }

# resource "aws_iam_role_policy" "dlm_lifecycle" {
#   name = "dlm-lifecycle-policy-${var.domain}"
#   role = aws_iam_role.dlm_lifecycle_role.id

#   policy = <<EOF
# {
#    "Version": "2012-10-17",
#    "Statement": [
#       {
#          "Effect": "Allow",
#          "Action": [
#             "ec2:CreateSnapshot",
#             "ec2:DeleteSnapshot",
#             "ec2:DescribeVolumes",
#             "ec2:DescribeSnapshots"
#          ],
#          "Resource": "*"
#       },
#       {
#          "Effect": "Allow",
#          "Action": [
#             "ec2:CreateTags"
#          ],
#          "Resource": "arn:aws:ec2:*::snapshot/*"
#       }
#    ]
# }
# EOF
# }

# resource "aws_dlm_lifecycle_policy" "backup-gitlab" {
#   description        = "Gitlab DLM lifecycle policy"
#   execution_role_arn = aws_iam_role.dlm_lifecycle_role.arn
#   state              = "ENABLED"

#   policy_details {
#     resource_types = ["VOLUME"]

#     schedule {
#       name = "${var.days_retain_gitlab_snapshot} days of daily snapshots"

#       create_rule {
#         interval      = 24
#         interval_unit = "HOURS"
#         times         = ["23:15"]
#       }

#       retain_rule {
#         count = var.days_retain_gitlab_snapshot
#       }

#       tags_to_add = {
#         SnapshotCreator = "DLM"
#       }

#       copy_tags = true
#     }

#     target_tags = {
#       Snapshot = "gitlab.${var.domain}"
#     }
#   }

#   tags = var.tags
# }


resource "oci_core_volume_backup_policy" "backup_gitlab" {
  compartment_id = var.compartment_id
  display_name   = "Gitlab Backup Policy"
  freeform_tags  = var.tags
  schedules {
    backup_type       = "INCREMENTAL"
    period            = "ONE_DAY"
    retention_seconds = var.days_retain_gitlab_snapshot * 86400
    offset_seconds    = "82800"
    offset_type       = "NUMERIC_SECONDS"
    time_zone         = "REGIONAL_DATA_CENTER_TIME"
  }
}

resource "oci_core_volume_backup_policy_assignment" "test_volume_backup_policy_assignment" {
  asset_id  = var.gitlab_block_volume_id
  policy_id = oci_core_volume_backup_policy.backup_gitlab.id
}