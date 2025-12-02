terraform {
  backend "s3" {
    bucket         = "pingfederates3bucket"
    key            = "pingsso/prod.tfstate"
    region         = "ap-southeast-2"
    encrypt        = true
    dynamodb_table = "pingfederates3bucket_tf_lockid"
  }
  required_providers {
    pingfederate = {
      source  = "pingidentity/pingfederate"
      version = "1.6.2"
    }
  }
}

provider "pingfederate" {
  username                            = var.pf_admin_username
  password                            = var.pf_admin_password
  https_host                          = var.pf_admin_base_url
  admin_api_path                      = var.pf_admin_context
  insecure_trust_all_tls              = var.pf_provider_trust_all_tls
  x_bypass_external_validation_header = var.pf_provider_bypass_external_validation_header
  product_version                     = var.pf_provider_product_version
}
