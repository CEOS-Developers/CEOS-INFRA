output "zone_id" {
  description = "Route 53 Hosted Zone ID"
  value       = var.create_hosted_zone ? aws_route53_zone.main[0].zone_id : var.zone_id
}

output "zone_name_servers" {
  description = "Name servers for the hosted zone"
  value       = var.create_hosted_zone ? aws_route53_zone.main[0].name_servers : []
}

output "zone_name" {
  description = "Domain name of the hosted zone"
  value       = var.create_hosted_zone ? aws_route53_zone.main[0].name : var.domain_name
}
