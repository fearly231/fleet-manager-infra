output "acm_certificate_arn" {
  description = "The ARN of the ACM certificate for the domain"
  value       = aws_acm_certificate.cert.arn
}
output "route53_zone_id" {
  description = "The ID of the Route 53 hosted zone for the domain"
  value       = aws_route53_zone.selected.zone_id
}

output "name_servers" {
  description = "The Name Servers for the Route 53 hosted zone to be set in Namecheap"
  value       = aws_route53_zone.selected.name_servers
}