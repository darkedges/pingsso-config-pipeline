# PingSSO Application Module

This module creates a PingFederate SSO application using either SAML or OIDC protocol.

## Usage

### OIDC Application

```hcl
module "my_app" {
  source = "../../modules/pingsso_application"

  app_name = "My Web App"
  protocol = "OIDC"

  oidc_config = {
    redirect_uris = ["https://app.example.com/callback"]
    grant_types   = ["AUTHORIZATION_CODE"]
    response_types = ["code"]
    scopes        = ["openid", "profile", "email"]
  }

  attribute_mapping = {
    "email" = "mail"
    "sub"   = "uid"
  }

  tags = {
    team        = "platform"
    environment = "production"
  }
}
```

### SAML Application

```hcl
module "my_saml_app" {
  source = "../../modules/pingsso_application"

  app_name = "Enterprise SaaS"
  protocol = "SAML"

  saml_config = {
    entity_id = "https://saas.vendor.com/saml"
    acs_url   = "https://saas.vendor.com/sso/acs"
  }

  attribute_mapping = {
    "email"     = "mail"
    "firstName" = "givenName"
  }

  tags = {
    team        = "hr"
    environment = "production"
  }
}
```

## Inputs

| Name                     | Description            | Type        | Required    | Default           |
| ------------------------ | ---------------------- | ----------- | ----------- | ----------------- |
| app_name                 | Application name       | string      | yes         | -                 |
| protocol                 | SAML or OIDC           | string      | yes         | -                 |
| oidc_config              | OIDC configuration     | object      | conditional | {}                |
| saml_config              | SAML configuration     | object      | conditional | {}                |
| attribute_mapping        | Attribute mappings     | map(string) | no          | See variables.tf  |
| idp_adapter_ref          | IDP adapter ID         | string      | no          | "MyLDAPAdapter"   |
| access_token_manager_ref | OIDC token manager     | string      | no          | "default_jwt_atm" |
| saml_subject_attribute   | SAML subject attribute | string      | no          | "uid"             |
| tags                     | Resource tags          | map(string) | no          | {}                |

## Outputs

| Name               | Description                    |
| ------------------ | ------------------------------ |
| oidc_client_id     | OIDC client ID                 |
| oidc_client_secret | OIDC client secret (sensitive) |
| saml_entity_id     | SAML entity ID                 |
| saml_metadata_url  | SAML metadata URL              |
| application_id     | Application ID                 |
| application_name   | Application name               |
| protocol_type      | Protocol type                  |

## Requirements

- Terraform >= 1.0
- PingFederate provider >= 1.0, < 2.0
