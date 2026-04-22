package terraform

import rego.v1

requires_approval contains msg if {
    resource := input.resource_changes[_]
    resource.type == "cloudflare_ruleset"
    resource.change.actions[_] != "no-op"
    resource.change.after.phase == "http_request_firewall_managed"
    rule := resource.change.after.rules[_]
    rule.action == "execute"
    rule.action_parameters.overrides != null
    msg := sprintf("APPROVAL REQUIRED: Managed ruleset '%s' has overrides configured. Explicit security approval required.", [resource.change.after.name])
}

requires_approval contains msg if {
    resource := input.resource_changes[_]
    resource.type == "cloudflare_ruleset"
    resource.change.actions[_] != "no-op"
    resource.change.after.phase == "http_request_firewall_managed"
    rule := resource.change.after.rules[_]
    rule.action != "execute"
    msg := sprintf("APPROVAL REQUIRED: Managed ruleset '%s' contains a non-execute rule (action: '%s') that overrides or bypasses managed WAF behavior. Explicit security approval required.", [resource.change.after.name, rule.action])
}

requires_approval contains msg if {
    resource := input.resource_changes[_]
    resource.type == "cloudflare_ruleset"
    resource.change.actions[_] != "no-op"
    resource.change.after.phase == "http_request_firewall_custom"
    rule := resource.change.after.rules[_]
    rule.action == "skip"
    msg := sprintf("APPROVAL REQUIRED: Custom ruleset '%s' contains a skip rule that bypasses WAF checks. Explicit security approval required.", [resource.change.after.name])
}

