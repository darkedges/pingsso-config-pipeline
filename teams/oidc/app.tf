module "marketing_portal_sso" {
  source = "../../modules/pingsso_application"

  app_name = "Marketing Portal"
  protocol = "OIDC"

  oidc_config = {
    redirect_uris  = ["https://marketing.example.com/callback"]
    grant_types    = ["AUTHORIZATION_CODE"]
    response_types = ["code"]
    scopes         = ["openid", "profile", "email"]
  }

  # Mapping "EmployeeID" in token to "uid" in AD
  attribute_mapping = {
    "email"      = "mail"
    "EmployeeID" = "uid"
  }

  tags = {
    team        = "marketing"
    environment = "production"
    cost_center = "CC-1234"
  }
}
