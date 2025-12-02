# 🚀 PingSSO Self-Service Onboarding

Welcome! This repository allows application teams to onboard their applications to **PingFederate** using Terraform. By defining your configuration here, you ensure your app is deployed securely, consistently, and automatically.

## 📂 Project Structure

```text
.
├── modules/               # Shared Terraform logic (Do not edit)
├── policies/              # Security Guardrails (OPA Policies)
├── platform/              # Main Terraform execution (Admins only)
└── teams/                 # 👈 YOUR WORKSPACE
    ├── marketing/         # Team Directory
    │   └── my-app.tf      # App Configurations
    └── engineering/
```

## ⚡️ Quick Start Guide

1. Create your fileNavigate to `teams/<your-team-name>/` and create a new file named `<your-app-name>.tf`.
1. Add the Module BlockCopy one of the templates below into your new file.

## 🅰️ Option A: OIDC App (Modern Web/Mobile)

Use this for Single Page Apps (React/Angular), Mobile Apps, or APIs.

```text
module "my_oidc_app" {
  source = "../../modules/pingsso_application"

  # 1. Identity Basics
  app_name = "Customer Portal (OIDC)"
  protocol = "OIDC"

  # 2. OIDC Configuration
  oidc_config = {
    # MUST be HTTPS. No localhost in Production.
    redirect_uris = ["[https://portal.example.com/callback](https://portal.example.com/callback)"]
    
    # Common Types: "AUTHORIZATION_CODE" (Web), "CLIENT_CREDENTIALS" (M2M)
    grant_types   = ["AUTHORIZATION_CODE"]
  }

  # 3. Attribute Mapping (Token Claims -> LDAP Attributes)
  attribute_mapping = {
    "email"      = "mail"
    "full_name"  = "cn"
    "username"   = "uid"
  }
}
```

## 🅱️ Option B: SAML App (Legacy/SaaS)

Use this for vendors like Salesforce, Zoom, or legacy internal apps.

```test
module "my_saml_app" {
  source = "../../modules/pingsso_application"

  # 1. Identity Basics
  app_name = "Vendor SaaS (SAML)"
  protocol = "SAML"

  # 2. SAML Configuration (Provided by your Vendor)
  saml_config = {
    entity_id = "[https://sp.vendor.com/saml2](https://sp.vendor.com/saml2)"
    acs_url   = "[https://sp.vendor.com/sso/consume](https://sp.vendor.com/sso/consume)" # Must be HTTPS
  }

  # 3. Attribute Mapping (SAML Assertions -> LDAP Attributes)
  attribute_mapping = {
    "Email"      = "mail"
    "FirstName"  = "givenName"
    "CostCenter" = "departmentNumber"
  }
}
```

1. Commit & PushPush your changes to a new branch and open a Pull Request.The CI/CD Pipeline will automatically:
   1. Validate your syntax.
   2. Check for security violations (OPA).
   3. Plan the changes.

## 🛡 Security Guardrails

To prevent build failures, ensure you follow these rules:

| Rule           | Description                                                                |
| -------------- | -------------------------------------------------------------------------- |
| HTTPS Only     | All redirect_uris and acs_urls must start with https://.                   |
| No Localhost   | localhost and 127.0.0.1 are blocked. Use the Dev tenant for local testing. |
| Valid Protocol | Protocol must be exactly "SAML" or "OIDC".                                 |

## ❓ Troubleshooting

Error: `OPA Policy Violation`

- Cause: You likely used http:// or localhost.
- Fix: Update your URLs to https://.

Error: `Module not found`

- Cause: Your source path is incorrect.
- Fix: Ensure source = "../../modules/pingsso_application".
