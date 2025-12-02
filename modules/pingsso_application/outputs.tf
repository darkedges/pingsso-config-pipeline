output "oidc_client_id" {
  description = "Client ID for OIDC applications"
  value       = try(pingfederate_oauth_client.oidc_app[0].client_id, null)
}

output "oidc_client_secret" {
  description = "Client Secret for OIDC applications (sensitive) - Note: May not be available in provider response"
  value       = null # Not exposed by provider
  sensitive   = true
}

output "saml_entity_id" {
  description = "Entity ID for SAML applications"
  value       = try(pingfederate_idp_sp_connection.saml_app[0].entity_id, null)
}

output "saml_metadata_url" {
  description = "Metadata URL for SAML applications (construct from base_url and connection_id)"
  value       = try("${pingfederate_idp_sp_connection.saml_app[0].base_url}/pf/federation_metadata.ping?PartnerSpId=${pingfederate_idp_sp_connection.saml_app[0].connection_id}", null)
}

output "application_id" {
  description = "Unique identifier of the created application"
  value       = var.protocol == "OIDC" ? try(pingfederate_oauth_client.oidc_app[0].id, null) : try(pingfederate_idp_sp_connection.saml_app[0].id, null)
}

output "application_name" {
  description = "Name of the created application"
  value       = var.app_name
}

output "protocol_type" {
  description = "Protocol type used (OIDC or SAML)"
  value       = var.protocol
}
