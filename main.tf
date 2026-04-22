resource "cloudflare_ruleset" "zone_ruleset" {
  zone_id     = var.cloudflare_zone_id
  name        = "Zone ruleset"
  description = "Zone ruleset"
  kind        = "zone"
  phase       = "http_request_firewall_custom"

  rules = [
    {
      action      = "log"
      expression  = "true"
      description = "Log all requests for audit"
      enabled     = true
    },
    {
      action = "skip"
      action_parameters = {
        phases = ["http_request_firewall_managed"]
      }
      expression  = "ip.src in {10.0.0.0/8 192.168.0.0/16}"
      description = "Skip WAF for internal network ranges"
      enabled     = true
    },
    {
      action      = "block"
      expression  = "(http.user_agent contains \"sqlmap\")"
      description = "Block known malicious scanner user agents"
      enabled     = true
    },
    {
      action      = "block"
      expression  = "(http.user_agent contains \"Nikto\")"
      description = "Block Nikto vulnerability scanner"
      enabled     = true
    },
    {
      action      = "block"
      expression  = "(http.user_agent eq \"\")"
      description = "Block requests with empty user agent"
      enabled     = true
    },
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
      action = "skip"
      action_parameters = {
        ruleset = "current"
      }
      expression  = "ip.src in {203.0.113.0/24}"
      description = "Exception: skip managed WAF for trusted partner IP range"
      enabled     = true
    },
    {
      action = "execute"
      action_parameters = {
        id = "efb7b8c949ac4650a09736fc376e9aee"
        overrides = {
          categories = [
            {
              category = "wordpress"
              enabled  = false
            }
          ]
        }
      }
      expression  = "true"
      description = "Execute Cloudflare Managed Ruleset"
      enabled     = true
    }
  ]
}
