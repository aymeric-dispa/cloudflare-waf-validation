terraform {
  required_version = ">= 1.0"

  cloud {
    organization = "infra-aymeric-cfd"

    workspaces {
      name = "infra-aymeric-cfd"
    }
  }

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.0"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}
