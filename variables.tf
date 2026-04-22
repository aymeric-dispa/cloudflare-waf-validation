variable "cloudflare_api_token" {
  description = "Cloudflare API token with WAF permissions"
  type        = string
  sensitive   = true
}

variable "cloudflare_zone_id" {
  description = "Cloudflare Zone ID where WAF rules will be applied"
  type        = string
}

variable "waf_attack_score_threshold" {
  description = "WAF attack score threshold - rules trigger for cf.waf.score <= this value. Lower scores = higher attack probability. Must be >= 20."
  type        = number
  default     = 20
}

variable "waf_action" {
  description = "Action to take when WAF attack score is below threshold (block or challenge)"
  type        = string
  default     = "block"

  validation {
    condition     = contains(["block", "challenge"], var.waf_action)
    error_message = "WAF action must be one of: block, challenge"
  }
}
