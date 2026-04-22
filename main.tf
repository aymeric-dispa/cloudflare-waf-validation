resource "cloudflare_ruleset" "waf_attack_score_protection" {
  zone_id     = var.cloudflare_zone_id
  name        = "WAF Attack Score Protection"
  description = "Managed by Terraform - WAF attack score protection (OPA enforced)"
  kind        = "zone"
  phase       = "http_request_firewall_custom"

  rules = [
    {
<<<<<<< feat/log-admin-requests
      action      = "log"
      expression  = "(http.request.uri.path contains \"/admin\")"
      description = "Log requests to admin paths for audit"
=======
      action      = "skip"
      expression  = "ip.src in {10.0.0.0/8 192.168.0.0/16}"
      description = "Skip WAF for internal network ranges"
>>>>>>> main
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
