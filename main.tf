resource "cloudflare_ruleset" "waf_attack_score_protection" {
  zone_id     = var.cloudflare_zone_id
  name        = "WAF Attack Score Protection"
  description = "Managed by Terraform - GitOps enforced WAF rules for attack score protection"
  kind        = "zone"
  phase       = "http_request_firewall_custom"

  rules = [
    {
      action      = var.waf_action
      expression  = "(cf.threat_score ge ${var.waf_attack_score_threshold})"
      description = "Block requests with high attack score (>= ${var.waf_attack_score_threshold})"
      enabled     = true
    }
  ]
}

resource "cloudflare_ruleset" "waf_managed_rules" {
  zone_id     = var.cloudflare_zone_id
  name        = "WAF Managed Rules"
  description = "Managed by Terraform - Cloudflare Managed WAF Ruleset"
  kind        = "zone"
  phase       = "http_request_firewall_managed"

  rules = [
    {
      action = "execute"
      action_parameters = {
        id = "efb7b8c949ac4650a09736fc376e9aee"
      }
      expression  = "true"
      description = "Execute Cloudflare Managed Ruleset"
      enabled     = true
    }
  ]
}
