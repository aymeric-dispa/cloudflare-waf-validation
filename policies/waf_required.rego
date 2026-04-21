package terraform

import rego.v1

deny contains msg if {
    not has_waf_attack_score_protection
    msg := "POLICY VIOLATION: No WAF rule found for cf.waf.score. At least one cloudflare_ruleset with cf.waf.score filtering must be defined."
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
    msg := sprintf("POLICY VIOLATION: WAF attack score rule '%s' must use 'block' or 'challenge' action.", [resource.values.name])
}

deny contains msg if {
    resource := input.planned_values.root_module.resources[_]
    resource.type == "cloudflare_ruleset"
    resource.values.phase == "http_request_firewall_custom"
    has_attack_score_rule(resource)
    rule := resource.values.rules[_]
    contains(rule.expression, "cf.waf.score")
    threshold := extract_threshold(rule.expression)
    threshold < 20
    msg := sprintf("POLICY VIOLATION: WAF attack score threshold is %d. Must be >= 20 to ensure all high-risk requests (score 1-20) are covered.", [threshold])
}

has_waf_attack_score_protection if {
    resource := input.planned_values.root_module.resources[_]
    resource.type == "cloudflare_ruleset"
    resource.values.phase == "http_request_firewall_custom"
    has_attack_score_rule(resource)
}

has_attack_score_rule(resource) if {
    rule := resource.values.rules[_]
    contains(rule.expression, "cf.waf.score")
}

is_rule_enabled(resource) if {
    rule := resource.values.rules[_]
    contains(rule.expression, "cf.waf.score")
    rule.enabled == true
}

has_blocking_action(resource) if {
    rule := resource.values.rules[_]
    contains(rule.expression, "cf.waf.score")
    rule.action in ["block", "challenge"]
}

warn contains msg if {
    resource := input.planned_values.root_module.resources[_]
    resource.type == "cloudflare_ruleset"
    resource.values.phase == "http_request_firewall_custom"
    has_attack_score_rule(resource)
    rule := resource.values.rules[_]
    contains(rule.expression, "cf.waf.score")
    threshold := extract_threshold(rule.expression)
    threshold > 50
    msg := sprintf("WARNING: WAF attack score threshold is set to %d. A high threshold may allow some attacks through. Consider a value between 20-50.", [threshold])
}

extract_threshold(expression) := threshold if {
    regex.match(`cf\.waf\.score\s+(le|lt|<=|<)\s+\d+`, expression)
    matches := regex.find_n(`\d+`, expression, -1)
    count(matches) > 0
    threshold := to_number(matches[0])
}
