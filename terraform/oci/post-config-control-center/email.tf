resource "oci_email_email_domain" "domain" {
    compartment_id = var.compartment_id
    name = var.domain
}

resource "oci_email_dkim" "dkim" {
    email_domain_id = oci_email_email_domain.domain.id
}


resource "oci_dns_rrset" "dkim_record" {
  domain          = "${oci_email_dkim.dkim.dns_subdomain_name}"
  rtype           = "CNAME"
  zone_name_or_id = var.public_zone_id
  compartment_id  = var.compartment_id
  items {
    domain = "${oci_email_dkim.dkim.dns_subdomain_name}"
    rdata  = oci_email_dkim.dkim.cname_record_value
    rtype  = "CNAME"
    ttl    = "300"
  }
}

resource "oci_email_sender" "approved_sender" {
    compartment_id = var.compartment_id
    email_address = "controlcenter@${var.domain}"
}


resource "oci_dns_rrset" "spf_record" {
  domain          = "${var.domain}"
  rtype           = "TXT"
  zone_name_or_id = var.public_zone_id
  compartment_id  = var.compartment_id
  items {
    domain = "${var.domain}"
    rdata  = var.spf_record
    rtype  = "TXT"
    ttl    = "300"
  }
}

## Not sure on the need of creating smtp creds...keep this for reference in case we need to create
# resource "oci_identity_smtp_credential" "smtp_credential" {
#     count = var.generate_smtp_credentials ? 1 : 0
#     provider = oci.homeregion
#     description = var.smtp_credential_description
#     user_id = var.current_user_ocid
# }
