package terraform

import rego.v1

test_waf_attack_score_protection_exists if {
    count(deny) == 0 with input as {
        "planned_values": {
            "root_module": {
                "resources": [
                    {
                        "type": "cloudflare_ruleset",
                        "values": {
                            "name": "WAF Attack Score Protection",
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
                ]
            }
        }
    }
}

test_missing_waf_protection_fails if {
    violations := deny with input as {
        "planned_values": {
            "root_module": {
                "resources": []
            }
        }
    }
    count(violations) > 0
}

test_disabled_waf_rule_fails if {
    violations := deny with input as {
        "planned_values": {
            "root_module": {
                "resources": [
                    {
                        "type": "cloudflare_ruleset",
                        "values": {
                            "name": "WAF Attack Score Protection",
                            "phase": "http_request_firewall_custom",
                            "rules": [
                                {
                                    "action": "block",
                                    "expression": "(cf.waf.score le 20)",
                                    "enabled": false
                                }
                            ]
                        }
                    }
                ]
            }
        }
    }
    count(violations) > 0
}

test_wrong_action_fails if {
    violations := deny with input as {
        "planned_values": {
            "root_module": {
                "resources": [
                    {
                        "type": "cloudflare_ruleset",
                        "values": {
                            "name": "WAF Attack Score Protection",
                            "phase": "http_request_firewall_custom",
                            "rules": [
                                {
                                    "action": "log",
                                    "expression": "(cf.waf.score le 20)",
                                    "enabled": true
                                }
                            ]
                        }
                    }
                ]
            }
        }
    }
    count(violations) > 0
}

test_challenge_action_passes if {
    count(deny) == 0 with input as {
        "planned_values": {
            "root_module": {
                "resources": [
                    {
                        "type": "cloudflare_ruleset",
                        "values": {
                            "name": "WAF Attack Score Protection",
                            "phase": "http_request_firewall_custom",
                            "rules": [
                                {
                                    "action": "challenge",
                                    "expression": "(cf.waf.score le 20)",
                                    "enabled": true
                                }
                            ]
                        }
                    }
                ]
            }
        }
    }
}

test_threshold_below_20_fails if {
    violations := deny with input as {
        "planned_values": {
            "root_module": {
                "resources": [
                    {
                        "type": "cloudflare_ruleset",
                        "values": {
                            "name": "WAF Attack Score Protection",
                            "phase": "http_request_firewall_custom",
                            "rules": [
                                {
                                    "action": "block",
                                    "expression": "(cf.waf.score le 10)",
                                    "enabled": true
                                }
                            ]
                        }
                    }
                ]
            }
        }
    }
    count(violations) > 0
}

test_high_threshold_warning if {
    warnings := warn with input as {
        "planned_values": {
            "root_module": {
                "resources": [
                    {
                        "type": "cloudflare_ruleset",
                        "values": {
                            "name": "WAF Attack Score Protection",
                            "phase": "http_request_firewall_custom",
                            "rules": [
                                {
                                    "action": "block",
                                    "expression": "(cf.waf.score le 80)",
                                    "enabled": true
                                }
                            ]
                        }
                    }
                ]
            }
        }
    }
    count(warnings) > 0
}
