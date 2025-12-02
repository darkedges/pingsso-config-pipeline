# Copy from platform/variables.tf
variable "pf_admin_username" {
  description = "PingFederate admin username"
  type        = string
  sensitive   = true
}

variable "pf_admin_password" {
  description = "PingFederate admin password"
  type        = string
  sensitive   = true
}

variable "pf_admin_base_url" {
  description = "PingFederate base URL"
  type        = string
  sensitive   = true
}

variable "pf_admin_context" {
  description = "PingFederate admin API context path"
  type        = string
  default     = "/pf-admin-api/v1"
}

variable "pf_provider_trust_all_tls" {
  description = "Whether to trust all TLS certificates"
  type        = bool
  default     = false
}

variable "access_token_manager_id" {
  description = "Access Token Manager ID"
  type        = string
  default     = "AccessTokenManagement"
}
variable "pf_provider_bypass_external_validation_header" {
  description = "Bypass external validation header"
  type        = bool
  default     = false
}

variable "pf_provider_product_version" {
  description = "The PingFederate product version."
  type        = string
  default     = "12.3"
}

variable "idp_adapter_id" {
  description = "IDP Adapter ID for SAML attribute mapping"
  type        = string
  default     = "IDENTIFIERFIRST"
}

variable "signing_key_id" {
  description = "Signing key pair ID for SAML connections"
  type        = string
  default     = "ulwwb71v5nmhh7v56tnb42a9k"
}
