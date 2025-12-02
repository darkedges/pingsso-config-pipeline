variable "app_name" {
  description = "Name of the application"
  type        = string
}

variable "protocol" {
  description = "SAML or OIDC"
  type        = string
  validation {
    condition     = contains(["SAML", "OIDC"], var.protocol)
    error_message = "Protocol must be exactly 'SAML' or 'OIDC'."
  }
}

variable "saml_config" {
  description = "Configuration for SAML apps"
  type = object({
    entity_id = optional(string)
    acs_url   = optional(string)
  })
  default = {}

  # Validation: If Protocol is SAML, these must be set
  validation {
    condition     = var.protocol != "SAML" || (var.saml_config.entity_id != null && var.saml_config.entity_id != "" && var.saml_config.acs_url != null && var.saml_config.acs_url != "" && can(startswith(var.saml_config.acs_url, "https://")))
    error_message = "If protocol is SAML, Entity ID is required and must not be empty, and ACS URL must start with https://"
  }
}

variable "oidc_config" {
  description = "Configuration for OIDC apps"
  type = object({
    redirect_uris  = optional(list(string))
    grant_types    = optional(list(string))
    response_types = optional(list(string), ["code"])
    scopes         = optional(list(string), ["openid", "profile", "email"])
  })
  default = {}

  validation {
    condition     = var.protocol != "OIDC" || can(length(var.oidc_config.redirect_uris) > 0)
    error_message = "If protocol is OIDC, at least one Redirect URI is required."
  }
}

variable "attribute_mapping" {
  description = "Map of App Attribute Name -> LDAP User Attribute"
  type        = map(string)
  default = {
    # Default mappings
    "email" = "mail"
    "sub"   = "uid"
  }

  validation {
    condition     = var.protocol != "SAML" || length(var.attribute_mapping) >= 0
    error_message = "Attribute mapping is required."
  }
}

variable "idp_adapter_ref" {
  description = "Reference ID of the LDAP/IDP adapter to use for attribute mapping"
  type        = string
  default     = "MyLDAPAdapter"
}

variable "access_token_manager_ref" {
  description = "Reference ID of the Access Token Manager for OIDC applications"
  type        = string
  default     = "default_jwt_atm"
}

variable "saml_subject_attribute" {
  description = "LDAP attribute to use as the SAML subject (must exist in your IDP adapter contract)"
  type        = string
  default     = "subject"
}

variable "tags" {
  description = "Tags to apply to the application for organization and cost tracking"
  type        = map(string)
  default     = {}
}

variable "signing_key_id" {
  description = "Signing key pair ID for SAML connections"
  type        = string
  default     = "defaultSigningKey"
}
