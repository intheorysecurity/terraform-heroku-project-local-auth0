//STEP 1 Update Tenant Info
resource "auth0_tenant" "company_tenant" {
  friendly_name = "${var.company_name} Portal"
  picture_url   = var.logo_url
  session_cookie {
    mode = "persistent"
  }
}

//STEP 2 create auth0 application and create API
resource "auth0_client" "nodejs_application" {
  name                = var.auth0_application_name
  app_type            = "regular_web"
  grant_types         = ["implicit", "authorization_code", "refresh_token", "client_credentials"]
  callbacks           = ["https://${var.heroku_app_name}.herokuapp.com", "https://${var.heroku_app_name}.herokuapp.com/callback"]
  allowed_origins     = ["https://${var.heroku_app_name}.herokuapp.com"]
  web_origins         = ["https://${var.heroku_app_name}.herokuapp.com"]
  allowed_logout_urls = ["https://${var.heroku_app_name}.herokuapp.com", "https://${var.heroku_app_name}.herokuapp.com/logout"]

  jwt_configuration {
    alg = "RS256"
  }
}

//STEP 3 Connect API with Application and enable required scopes
resource "auth0_resource_server" "my_resource_server" {
  name        = "Bill Payment API"
  identifier  = "https://${var.auth0_resource_server_identifier}"
  signing_alg = "RS256"

  allow_offline_access                            = true
  token_lifetime                                  = 8600
  skip_consent_for_verifiable_first_party_clients = true

  scopes {
    value       = "bill:payment"
    description = "Grants Ability to issue payment."
  }

  scopes {
    value       = "risky:transaction"
    description = "Grants Ability to complete Risky Transaction"
  }
}

//STEP 4 Connect Resource Service from Step 2 with Client from Step 1
resource "auth0_client_grant" "my_client_grant" {
  client_id = auth0_client.nodejs_application.client_id
  audience  = auth0_resource_server.my_resource_server.identifier
  scope     = ["bill:payment", "risky:transaction"]
}

//STEP 5  Connect Management API with Client
resource "auth0_client_grant" "my_management_grant" {
  client_id = auth0_client.nodejs_application.client_id
  audience  = "${var.auth0_domain}/api/v2/"
  scope     = ["read:users", "update:users"]
}

//Step 6 Add custom domain
resource "auth0_custom_domain" "my_custom_domain" {
  domain = var.auth0_custom_domain_url
  type   = "auth0_managed_certs"
}

//Step 7 Update Verify Email Template
resource "auth0_email_template" "verify_email" {
  template                = "verify_email"
  body                    = templatefile("${path.cwd}/customEmails/verification.html", { logo_url = "${var.logo_url}", company_name = "${var.company_name}" })
  from                    = "welcome@intheorysecurity.com"
  subject                 = "Hello {{user.email}}, please verify your email address!!!"
  syntax                  = "liquid"
  url_lifetime_in_seconds = 432000
  enabled                 = true
}

//Step 8 Update Verify Email Template
resource "auth0_email_template" "passwordreset_email" {
  template                = "reset_email"
  body                    = templatefile("${path.cwd}/customEmails/passwordreset.html", { logo_url = "${var.logo_url}", company_name = "${var.company_name}" })
  from                    = "password@intheorysecurity.com"
  subject                 = "So you forgot your password?"
  syntax                  = "liquid"
  url_lifetime_in_seconds = 432000
  enabled                 = true
}

//STEP 9 Create Heroku app
resource "heroku_app" "default" {
  name   = var.heroku_app_name
  region = "us"

  //Auth0 NodeJS vars
  sensitive_config_vars = {
    BASE_URL            = "${auth0_client.nodejs_application.allowed_origins[0]}"
    ISSUER_BASE_URL     = "${var.auth0_domain}",
    CLIENT_ID           = "${auth0_client.nodejs_application.client_id}",
    CLIENT_SECRET       = "${auth0_client.nodejs_application.client_secret}",
    AUDIENCE            = "${auth0_resource_server.my_resource_server.identifier}",
    USE_CUSTOM_DOMAIN   = "${var.auth0_use_custom_domain}",
    AUTH0_CUSTOM_DOMAIN = "https://${var.auth0_custom_domain_url}"
    DEBUG               = "${var.auth0_debug}"
    SECRET              = "LONG_RANDOM_SECRET"
  }

  buildpacks = [
    "heroku/nodejs"
  ]
}

//STEP 10 Upload Project Src to Heroku
resource "heroku_build" "nodejsapp" {
  app_id = heroku_app.default.id

  source {
    # A local directory, changing its contents will
    # force a new build during `terraform apply`
    path = var.app_local_path
  }
}

//STEP 11 Add Record to AWS instance Route63

//STEP 12 Add MFA Action and enhance AccessToken

//STEP 13 Update Bot Detection Config 

//OUTPUT Section
output "heroku_app_url" {
  value = heroku_app.default.web_url
}

output "auth0_customDomain_object" {
  value = auth0_custom_domain.my_custom_domain
}

output "auth0-nodejsapp-clientID" {
  value = auth0_client.nodejs_application.client_id
}