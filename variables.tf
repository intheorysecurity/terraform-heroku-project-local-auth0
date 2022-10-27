//Company Branding Block
variable "background_image_url" {
  type        = string
  description = "(String) Background image url."
}

variable "company_name" {
  type        = string
  default     = "Intheory Security"
  description = "Company's Names"
}


variable "logo_url" {
  type        = string
  description = "(String) Logo url."
}


//Auth0 Config Block
variable "auth0_application_name" {
  type    = string
  default = "Sample NodeJS Application"
}

variable "auth0_domain" {
  type    = string
  default = "domain.us.auth0.com"
}

//Client ID use to call Auth0 Management API to create an application
variable "auth0_client_id" {
  type = string
}

variable "auth0_client_secret" {
  type = string
}

variable "auth0_debug" {
  type        = bool
  default     = false
  description = "Indicates whether to turn on debug mode."
}

variable "auth0_resource_server_identifier" {
  type        = string
  description = "Identifiter for the custom bill payment resource server"
}

variable "auth0_use_custom_domain" {
  type        = bool
  description = "Enables if you are using a custom domain"
}

variable "auth0_custom_domain_url" {
  type = string
}

//HEROKU Config Block
variable "heroku_email" {
  type        = string
  description = "Heroku username"
}

variable "heroku_api_key" {
  type        = string
  description = "Heroku API Key"
}

variable "heroku_app_name" {
  type        = string
  description = "Heroku App Name"
}

variable "app_local_path" {
  type        = string
  description = "Location path of the application.  Could be a local or GIT path"
  default     = "src/project"
}