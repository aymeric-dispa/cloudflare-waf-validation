output "zone_ruleset_id" {
  description = "ID of the zone custom ruleset"
  value       = cloudflare_ruleset.zone_ruleset.id
}

output "waf_managed_ruleset_id" {
  description = "ID of the WAF managed rules ruleset"
  value       = cloudflare_ruleset.waf_managed_rules.id
}
