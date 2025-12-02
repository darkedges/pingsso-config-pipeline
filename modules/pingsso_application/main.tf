# --- OIDC Application Resource ---
resource "pingfederate_oauth_client" "oidc_app" {
  count = var.protocol == "OIDC" ? 1 : 0

  client_id   = lower(replace(var.app_name, " ", "-"))
  name        = var.app_name
  grant_types = var.oidc_config.grant_types

  redirect_uris = var.oidc_config.redirect_uris

  # Use a default Access Token Manager (ATM)
  default_access_token_manager_ref = {
    id = var.access_token_manager_ref
  }

  # Mapping Attributes (OIDC Policy)
  oidc_policy = {
    grant_access_session_revocation_api = false
    id_token_signing_algorithm          = "RS256"
  }
}

# --- SAML Application Resource ---
resource "pingfederate_idp_sp_connection" "saml_app" {
  count = var.protocol == "SAML" ? 1 : 0

  connection_id = lower(replace(var.app_name, " ", "-"))
  name          = var.app_name
  entity_id     = var.saml_config.entity_id
  base_url      = "https://${split("/", var.saml_config.acs_url)[2]}" # Extract domain
  active        = true

  credentials = {
    signing_settings = {
      signing_key_pair_ref = {
        id = var.signing_key_id
      }
      algorithm                    = "SHA256withRSA"
      include_cert_in_signature    = false
      include_raw_key_in_signature = false
    }
  }

  sp_browser_sso = {
    protocol         = "SAML20"
    enabled          = true
    enabled_profiles = ["IDP_INITIATED_SSO", "SP_INITIATED_SSO"]

    sp_saml_identity_mapping = "STANDARD"

    encryption_policy = {
      encrypt_assertion           = false
      encrypt_slo_subject_name_id = false
      encrypted_attributes        = []
    }

    assertion_lifetime = {
      minutes_before = 5
      minutes_after  = 5
    }

    incoming_bindings = ["POST"]

    sso_service_endpoints = [{
      url        = var.saml_config.acs_url
      binding    = "POST"
      is_default = true
      index      = 0
    }]

    attribute_contract = {
      core_attributes = [{
        name        = "SAML_SUBJECT"
        name_format = "urn:oasis:names:tc:SAML:1.1:nameid-format:unspecified"
      }]
      extended_attributes = [
        for attr_name in keys(var.attribute_mapping) : {
          name        = attr_name
          name_format = "urn:oasis:names:tc:SAML:2.0:attrname-format:basic"
        }
      ]
    }

    adapter_mappings = [{
      idp_adapter_ref = {
        id = var.idp_adapter_ref
      }

      attribute_contract_fulfillment = merge(
        {
          "SAML_SUBJECT" = {
            source = {
              type = "ADAPTER"
            }
            value = var.saml_subject_attribute
          }
        },
        {
          for attr_name, ldap_attr in var.attribute_mapping :
          attr_name => {
            source = {
              type = "ADAPTER"
            }
            value = ldap_attr
          }
        }
      )
    }]
  }
}
