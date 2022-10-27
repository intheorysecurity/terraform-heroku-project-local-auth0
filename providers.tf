terraform {
  required_providers {
    heroku = {
      source  = "heroku/heroku"
      version = "5.1.1"
    }
    auth0 = {
      source = "auth0/auth0"
      version = "0.37.0"
    }
  }
}

provider "heroku" {
  # Configuration options
  email   = var.heroku_email
  api_key = var.heroku_api_key
}

provider "auth0" {
  domain        = var.auth0_domain
  client_id     = var.auth0_client_id
  client_secret = var.auth0_client_secret
  debug         = var.auth0_debug
}