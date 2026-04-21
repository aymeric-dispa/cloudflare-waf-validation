package terraform

test_waf_attack_score_protection_exists {
    not deny[_] with input as {
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
                                    "expression": "(cf.threat_score ge 50)",
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

test_missing_waf_protection_fails {
    deny[msg] with input as {
        "planned_values": {
            "root_module": {
                "resources": []
            }
        }
    }
    count(deny) > 0
}

test_disabled_waf_rule_fails {
    deny[msg] with input as {
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
                                    "expression": "(cf.threat_score ge 50)",
                                    "enabled": false
                                }
                            ]
                        }
                    }
                ]
            }
        }
    }
    count(deny) > 0
}

test_wrong_action_fails {
    deny[msg] with input as {
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
                                    "expression": "(cf.threat_score ge 50)",
                                    "enabled": true
                                }
                            ]
                        }
                    }
                ]
            }
        }
    }
    count(deny) > 0
}

test_challenge_action_passes {
    not deny[_] with input as {
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
                                    "expression": "(cf.threat_score ge 50)",
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

test_high_threshold_warning {
    warn[msg] with input as {
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
                                    "expression": "(cf.threat_score ge 80)",
                                    "enabled": true
                                }
                            ]
                        }
                    }
                ]
            }
        }
    }
    count(warn) > 0
}
