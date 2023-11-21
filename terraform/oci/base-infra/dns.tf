resource "oci_dns_zone" "private" {
  count          = (var.configure_dns && var.create_private_zone) ? 1 : 0
  compartment_id = var.compartment_id
  name           = "${local.cluster_domain}.internal."
  zone_type      = "PRIMARY"
  freeform_tags  = merge({ Name = "${local.cluster_domain}-private" }, local.common_tags)
  scope          = "PRIVATE"
  view_id        = oci_dns_view.private_view[0].id
  lifecycle {
    ignore_changes = [
      freeform_tags,
      name,
    ]
  }
}

resource "oci_dns_view" "private_view" {
  count          = (var.configure_dns && var.create_private_zone) ? 1 : 0
  compartment_id = var.compartment_id
  display_name   = "dnsview.${local.cluster_domain}.internal"
  freeform_tags  = merge({ Name = "dnsview-${local.cluster_domain}-private" }, local.common_tags)
  scope          = "PRIVATE"
}


resource "oci_dns_zone" "cluster_parent" {
  count          = (var.configure_dns && var.manage_parent_domain) ? 1 : 0
  compartment_id = var.compartment_id
  name           = "${local.cluster_parent_domain}."
  zone_type      = "PRIMARY"
  freeform_tags  = merge({ Name = "${local.cluster_domain}-cluster-parent" }, local.common_tags)
  lifecycle {
    ignore_changes = [
      freeform_tags,
      name,
    ]
  }
}

resource "oci_dns_zone" "public" {
  count          = (var.configure_dns && var.create_public_zone) ? 1 : 0
  compartment_id = var.compartment_id
  name           = "${local.cluster_domain}."
  zone_type      = "PRIMARY"
  freeform_tags  = merge({ Name = "${local.cluster_domain}-public" }, local.common_tags)
  lifecycle {
    ignore_changes = [
      freeform_tags,
      name,
    ]
  }
}

resource "oci_dns_rrset" "haproxy_server_private" {
  count           = (var.configure_dns && var.create_haproxy_dns_record) ? 1 : 0
  domain          = "haproxy.${local.cluster_domain}"
  rtype           = "A"
  zone_name_or_id = oci_dns_zone.public[0].id
  compartment_id  = var.compartment_id
  items {
    domain = "haproxy.${local.cluster_domain}"
    rdata  = oci_core_instance.bastion.private_ip
    rtype  = "A"
    ttl    = "300"
  }
}