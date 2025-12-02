variable "pf_admin_base_url" {
  description = "Fully qualified URL where the Next.js UI will run."
  type        = string
  default     = "https://pfconsole.ping.internal.darkedges.com"
}

variable "pf_admin_context" {
  description = "The context path for the PingFederate admin API."
  type        = string
  default     = "/pf-admin-api/v1"
}


variable "pf_admin_username" {
  description = "Fully qualified URL where the Next.js UI will run."
  type        = string
  default     = "Administrator"
}

variable "pf_admin_password" {
  description = "Fully qualified URL where the Next.js UI will run."
  type        = string
  default     = "2FederateM0re"
}

variable "pf_provider_trust_all_tls" {
  description = "Whether to trust all TLS certificates, including self-signed certificates."
  type        = bool
  default     = true
}

variable "pf_provider_bypass_external_validation_header" {
  description = "Whether to set the X-Bypass-External-Validation header on API requests."
  type        = bool
  default     = true
}

variable "pf_provider_product_version" {
  description = "The PingFederate product version."
  type        = string
  default     = "12.3"
}
