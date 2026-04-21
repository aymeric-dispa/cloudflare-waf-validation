resource "cloudflare_ruleset" "waf_attack_score_protection" {
  zone_id     = var.cloudflare_zone_id
  name        = "WAF Attack Score Protection"
  description = "Managed by Terraform via GitOps - WAF attack score protection (OPA enforced)"
  kind        = "zone"
  phase       = "http_request_firewall_custom"

  rules = [
    {
      action      = var.waf_action
      expression  = "(cf.waf.score le ${var.waf_attack_score_threshold})"
      description = "Block/challenge requests with WAF attack score <= ${var.waf_attack_score_threshold}"
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
