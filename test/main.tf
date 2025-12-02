terraform {
  required_providers {
    pingfederate = {
      source  = "pingidentity/pingfederate"
      version = "1.6.2"
    }
  }
}

provider "pingfederate" {
  username                            = var.pf_admin_username
  password                            = var.pf_admin_password
  https_host                          = var.pf_admin_base_url
  admin_api_path                      = var.pf_admin_context
  insecure_trust_all_tls              = var.pf_provider_trust_all_tls
  x_bypass_external_validation_header = var.pf_provider_bypass_external_validation_header
  product_version                     = var.pf_provider_product_version
}

# Import your team's app module
module "marketing_portal_sso" {
  source = "../modules/pingsso_application"

  app_name = "Marketing Portal"
  protocol = "OIDC"

  oidc_config = {
    redirect_uris  = ["https://marketing.example.com/callback"]
    grant_types    = ["AUTHORIZATION_CODE"]
    response_types = ["code"]
    scopes         = ["openid", "profile", "email"]
  }

  attribute_mapping = {
    "email"      = "mail"
    "EmployeeID" = "uid"
  }

  # Specify the correct Access Token Manager ID from your PingFederate
  access_token_manager_ref = var.access_token_manager_id

  tags = {
    team        = "marketing"
    environment = "development"
    cost_center = "CC-1234"
  }
}

module "hr_payroll_sso" {
  source = "../modules/pingsso_application"

  app_name = "HR Payroll"
  protocol = "SAML"

  saml_config = {
    entity_id = "https://payroll.provider.com/saml"
    acs_url   = "https://payroll.provider.com/sso/consume"
  }

  # Override default attribute mapping for SAML (remove OIDC-specific attributes)
  attribute_mapping = {}

  # Configure your actual IDP adapter ID from PingFederate
  idp_adapter_ref = var.idp_adapter_id
  signing_key_id  = var.signing_key_id

  # Set the SAML subject to an attribute that exists in your IDP adapter
  saml_subject_attribute = var.saml_subject_attribute

  tags = {
    team        = "hr"
    environment = "production"
    cost_center = "CC-5678"
  }
}
