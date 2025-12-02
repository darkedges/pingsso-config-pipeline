
# pingsso_application

## Usage

## Providers

| Name                                                                         | Version       |
| ---------------------------------------------------------------------------- | ------------- |
| <a name="provider_pingfederate"></a> [pingfederate](#provider\_pingfederate) | >= 1.0, < 2.0 |

## Modules

No modules.

## Resources

| Name                                                                                                                                                 | Type     |
| ---------------------------------------------------------------------------------------------------------------------------------------------------- | -------- |
| [pingfederate_idp_sp_connection.saml_app](https://registry.terraform.io/providers/pingidentity/pingfederate/latest/docs/resources/idp_sp_connection) | resource |
| [pingfederate_oauth_client.oidc_app](https://registry.terraform.io/providers/pingidentity/pingfederate/latest/docs/resources/oauth_client)           | resource |

## Inputs

| Name                                                                                                             | Description                                                                         | Type                                                                                                                                                                                                                                                                   | Default                                                      | Required |
| ---------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------ | :------: |
| <a name="input_access_token_manager_ref"></a> [access\_token\_manager\_ref](#input\_access\_token\_manager\_ref) | Reference ID of the Access Token Manager for OIDC applications                      | `string`                                                                                                                                                                                                                                                               | `"default_jwt_atm"`                                          |    no    |
| <a name="input_app_name"></a> [app\_name](#input\_app\_name)                                                     | Name of the application                                                             | `string`                                                                                                                                                                                                                                                               | n/a                                                          |   yes    |
| <a name="input_attribute_mapping"></a> [attribute\_mapping](#input\_attribute\_mapping)                          | Map of App Attribute Name -> LDAP User Attribute                                    | `map(string)`                                                                                                                                                                                                                                                          | <pre>{<br/>  "email": "mail",<br/>  "sub": "uid"<br/>}</pre> |    no    |
| <a name="input_idp_adapter_ref"></a> [idp\_adapter\_ref](#input\_idp\_adapter\_ref)                              | Reference ID of the LDAP/IDP adapter to use for attribute mapping                   | `string`                                                                                                                                                                                                                                                               | `"MyLDAPAdapter"`                                            |    no    |
| <a name="input_oidc_config"></a> [oidc\_config](#input\_oidc\_config)                                            | Configuration for OIDC apps                                                         | <pre>object({<br/>    redirect_uris  = optional(list(string))<br/>    grant_types    = optional(list(string))<br/>    response_types = optional(list(string), ["code"])<br/>    scopes         = optional(list(string), ["openid", "profile", "email"])<br/>  })</pre> | `{}`                                                         |    no    |
| <a name="input_protocol"></a> [protocol](#input\_protocol)                                                       | SAML or OIDC                                                                        | `string`                                                                                                                                                                                                                                                               | n/a                                                          |   yes    |
| <a name="input_saml_config"></a> [saml\_config](#input\_saml\_config)                                            | Configuration for SAML apps                                                         | <pre>object({<br/>    entity_id = optional(string)<br/>    acs_url   = optional(string)<br/>  })</pre>                                                                                                                                                                 | `{}`                                                         |    no    |
| <a name="input_saml_subject_attribute"></a> [saml\_subject\_attribute](#input\_saml\_subject\_attribute)         | LDAP attribute to use as the SAML subject (must exist in your IDP adapter contract) | `string`                                                                                                                                                                                                                                                               | `"subject"`                                                  |    no    |
| <a name="input_signing_key_id"></a> [signing\_key\_id](#input\_signing\_key\_id)                                 | Signing key pair ID for SAML connections                                            | `string`                                                                                                                                                                                                                                                               | `"defaultSigningKey"`                                        |    no    |
| <a name="input_tags"></a> [tags](#input\_tags)                                                                   | Tags to apply to the application for organization and cost tracking                 | `map(string)`                                                                                                                                                                                                                                                          | `{}`                                                         |    no    |

## Outputs

| Name                                                                                           | Description                                                                                       |
| ---------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------- |
| <a name="output_application_id"></a> [application\_id](#output\_application\_id)               | Unique identifier of the created application                                                      |
| <a name="output_application_name"></a> [application\_name](#output\_application\_name)         | Name of the created application                                                                   |
| <a name="output_oidc_client_id"></a> [oidc\_client\_id](#output\_oidc\_client\_id)             | Client ID for OIDC applications                                                                   |
| <a name="output_oidc_client_secret"></a> [oidc\_client\_secret](#output\_oidc\_client\_secret) | Client Secret for OIDC applications (sensitive) - Note: May not be available in provider response |
| <a name="output_protocol_type"></a> [protocol\_type](#output\_protocol\_type)                  | Protocol type used (OIDC or SAML)                                                                 |
| <a name="output_saml_entity_id"></a> [saml\_entity\_id](#output\_saml\_entity\_id)             | Entity ID for SAML applications                                                                   |
| <a name="output_saml_metadata_url"></a> [saml\_metadata\_url](#output\_saml\_metadata\_url)    | Metadata URL for SAML applications (construct from base\_url and connection\_id)                  |
