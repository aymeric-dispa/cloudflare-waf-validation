package terraform

import rego.v1

requires_approval contains msg if {
    resource := input.planned_values.root_module.resources[_]
    resource.type == "cloudflare_ruleset"
    resource.values.phase == "http_request_firewall_managed"
    rule := resource.values.rules[_]
    rule.action == "execute"
    overrides := rule.action_parameters.overrides
    overrides != null
    msg := sprintf("APPROVAL REQUIRED: Managed ruleset '%s' has overrides configured. Explicit security approval required.", [resource.values.name])
}

requires_approval contains msg if {
    resource := input.planned_values.root_module.resources[_]
    resource.type == "cloudflare_ruleset"
    resource.values.phase == "http_request_firewall_custom"
    rule := resource.values.rules[_]
    rule.action == "skip"
    msg := sprintf("APPROVAL REQUIRED: Ruleset '%s' contains a skip rule that bypasses WAF checks. Explicit security approval required.", [resource.values.name])
}

