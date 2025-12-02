module "hr_payroll_sso" {
  source = "../../modules/pingsso_application"

  app_name = "HR Payroll"
  protocol = "SAML"

  saml_config = {
    entity_id = "https://payroll.provider.com/saml"
    acs_url   = "https://payroll.provider.com/sso/consume"
  }

  tags = {
    team        = "hr"
    environment = "production"
    cost_center = "CC-5678"
  }
}
