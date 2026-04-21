output "waf_attack_score_ruleset_id" {
  description = "ID of the WAF attack score protection ruleset"
  value       = cloudflare_ruleset.waf_attack_score_protection.id
}

output "waf_managed_ruleset_id" {
  description = "ID of the WAF managed rules ruleset"
  value       = cloudflare_ruleset.waf_managed_rules.id
}

output "waf_protection_summary" {
  description = "Summary of WAF protection configuration"
  value = {
    attack_score_threshold = var.waf_attack_score_threshold
    action                 = var.waf_action
    zone_id                = var.cloudflare_zone_id
    rulesets_deployed      = 2
  }
}
