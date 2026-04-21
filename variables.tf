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
  description = "Threshold for attack score to trigger blocking (default: 50)"
  type        = number
  default     = 50
}

variable "waf_action" {
  description = "Action to take when attack score exceeds threshold (block, challenge, or managed_challenge)"
  type        = string
  default     = "block"

  validation {
    condition     = contains(["block", "challenge", "managed_challenge"], var.waf_action)
    error_message = "WAF action must be one of: block, challenge, managed_challenge"
  }
}
