package terraform

import rego.v1

test_no_overrides_no_approval_required if {
    count(requires_approval) == 0 with input as {
        "resource_changes": [
            {
                "type": "cloudflare_ruleset",
                "change": {
                    "actions": ["update"],
                    "after": {
                        "name": "WAF Managed Rules",
                        "phase": "http_request_firewall_managed",
                        "rules": [
                            {
                                "action": "execute",
                                "action_parameters": {
                                    "id": "efb7b8c949ac4650a09736fc376e9aee"
                                },
                                "expression": "true",
                                "enabled": true
                            }
                        ]
                    }
                }
            }
        ]
    }
}

test_noop_override_no_approval_required if {
    count(requires_approval) == 0 with input as {
        "resource_changes": [
            {
                "type": "cloudflare_ruleset",
                "change": {
                    "actions": ["no-op"],
                    "after": {
                        "name": "WAF Managed Rules",
                        "phase": "http_request_firewall_managed",
                        "rules": [
                            {
                                "action": "execute",
                                "action_parameters": {
                                    "id": "efb7b8c949ac4650a09736fc376e9aee",
                                    "overrides": {
                                        "rules": [{"id": "some-rule-id", "enabled": false}]
                                    }
                                },
                                "expression": "true",
                                "enabled": true
                            }
                        ]
                    }
                }
            }
        ]
    }
}

test_managed_ruleset_override_requires_approval if {
    msgs := requires_approval with input as {
        "resource_changes": [
            {
                "type": "cloudflare_ruleset",
                "change": {
                    "actions": ["update"],
                    "after": {
                        "name": "WAF Managed Rules",
                        "phase": "http_request_firewall_managed",
                        "rules": [
                            {
                                "action": "execute",
                                "action_parameters": {
                                    "id": "efb7b8c949ac4650a09736fc376e9aee",
                                    "overrides": {
                                        "rules": [{"id": "some-rule-id", "enabled": false}]
                                    }
                                },
                                "expression": "true",
                                "enabled": true
                            }
                        ]
                    }
                }
            }
        ]
    }
    count(msgs) > 0
}

test_managed_exception_any_non_execute_requires_approval if {
    msgs := requires_approval with input as {
        "resource_changes": [
            {
                "type": "cloudflare_ruleset",
                "change": {
                    "actions": ["update"],
                    "after": {
                        "name": "WAF Managed Rules",
                        "phase": "http_request_firewall_managed",
                        "rules": [
                            {
                                "action": "log",
                                "expression": "ip.src == 1.2.3.4",
                                "enabled": true
                            }
                        ]
                    }
                }
            }
        ]
    }
    count(msgs) > 0
}

test_skip_rule_requires_approval if {
    msgs := requires_approval with input as {
        "resource_changes": [
            {
                "type": "cloudflare_ruleset",
                "change": {
                    "actions": ["update"],
                    "after": {
                        "name": "WAF Custom Rules",
                        "phase": "http_request_firewall_custom",
                        "rules": [
                            {
                                "action": "skip",
                                "expression": "ip.src == 1.2.3.4",
                                "enabled": true
                            }
                        ]
                    }
                }
            }
        ]
    }
    count(msgs) > 0
}

test_no_skip_rule_no_approval_required if {
    count(requires_approval) == 0 with input as {
        "resource_changes": [
            {
                "type": "cloudflare_ruleset",
                "change": {
                    "actions": ["update"],
                    "after": {
                        "name": "WAF Custom Rules",
                        "phase": "http_request_firewall_custom",
                        "rules": [
                            {
                                "action": "block",
                                "expression": "(cf.waf.score le 20)",
                                "enabled": true
                            }
                        ]
                    }
                }
            }
        ]
    }
}
