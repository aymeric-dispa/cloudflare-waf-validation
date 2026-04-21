package terraform

import rego.v1

deny contains msg if {
    not has_waf_attack_score_protection
    msg := "POLICY VIOLATION: No WAF rule found protecting against attack scores. At least one cloudflare_ruleset with attack score filtering must be defined."
}

deny contains msg if {
    resource := input.planned_values.root_module.resources[_]
    resource.type == "cloudflare_ruleset"
    resource.values.phase == "http_request_firewall_custom"
    has_attack_score_rule(resource)
    not is_rule_enabled(resource)
    msg := sprintf("POLICY VIOLATION: WAF attack score rule '%s' exists but is not enabled. All WAF rules must be enabled.", [resource.values.name])
}

deny contains msg if {
    resource := input.planned_values.root_module.resources[_]
    resource.type == "cloudflare_ruleset"
    resource.values.phase == "http_request_firewall_custom"
    has_attack_score_rule(resource)
    not has_blocking_action(resource)
    msg := sprintf("POLICY VIOLATION: WAF attack score rule '%s' must use 'block', 'challenge', or 'managed_challenge' action for security.", [resource.values.name])
}

has_waf_attack_score_protection if {
    resource := input.planned_values.root_module.resources[_]
    resource.type == "cloudflare_ruleset"
    resource.values.phase == "http_request_firewall_custom"
    has_attack_score_rule(resource)
}

has_attack_score_rule(resource) if {
    rule := resource.values.rules[_]
    contains(rule.expression, "cf.threat_score")
}

is_rule_enabled(resource) if {
    rule := resource.values.rules[_]
    contains(rule.expression, "cf.threat_score")
    rule.enabled == true
}

has_blocking_action(resource) if {
    rule := resource.values.rules[_]
    contains(rule.expression, "cf.threat_score")
    rule.action in ["block", "challenge", "managed_challenge"]
}

warn contains msg if {
    resource := input.planned_values.root_module.resources[_]
    resource.type == "cloudflare_ruleset"
    resource.values.phase == "http_request_firewall_custom"
    has_attack_score_rule(resource)
    rule := resource.values.rules[_]
    contains(rule.expression, "cf.threat_score")
    threshold := extract_threshold(rule.expression)
    threshold > 50
    msg := sprintf("WARNING: WAF attack score threshold is set to %d. Consider using a lower threshold (e.g., 50) for better protection.", [threshold])
}

extract_threshold(expression) := threshold if {
    regex.match(`cf\.threat_score\s+(ge|gt|>=|>)\s+(\d+)`, expression)
    matches := regex.find_n(`\d+`, expression, -1)
    count(matches) > 0
    threshold := to_number(matches[0])
}
