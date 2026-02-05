# SES Email Identity
resource "aws_ses_email_identity" "main" {
  count = length(var.email_identities)
  email = var.email_identities[count.index]
}

# SES Domain Identity (optional)
resource "aws_ses_domain_identity" "main" {
  count  = var.domain_identity != "" ? 1 : 0
  domain = var.domain_identity
}

# SES Domain DKIM
resource "aws_ses_domain_dkim" "main" {
  count  = var.domain_identity != "" ? 1 : 0
  domain = aws_ses_domain_identity.main[0].domain
}

# SES Configuration Set
resource "aws_ses_configuration_set" "main" {
  name = "${var.project_name}-ses-config-${var.environment}"
}

# SES Event Destination (CloudWatch)
resource "aws_ses_event_destination" "cloudwatch" {
  name                   = "${var.project_name}-ses-cw-${var.environment}"
  configuration_set_name = aws_ses_configuration_set.main.name
  enabled                = true
  matching_types         = ["send", "reject", "bounce", "complaint", "delivery"]

  cloudwatch_destination {
    default_value  = var.environment
    dimension_name = "environment"
    value_source   = "messageTag"
  }
}
