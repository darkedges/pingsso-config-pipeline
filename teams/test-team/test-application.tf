module "test-application-oidc" {
  source = "../../modules/pingsso_application"

  app_name = "Test Application"
  protocol = "OIDC"

  oidc_config = {
    redirect_uris = [
      "- http://localhost:3000/auth/callback",
    ]
    grant_types = [
      "- AUTHORIZATION_CODE",
    ]
  }

  attribute_mapping = {
    email = "mail"
    sub   = "uid"
  }

  tags = {
    team            = "Test Team"
    jira_issue_key  = "SUP-23"
    jira_ticket_url = "https://darkedges.atlassian.net/browse/SUP-23"
    source          = "jsm-automation"
  }
}
