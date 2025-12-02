terraform {
  required_version = ">= 1.0"

  required_providers {
    pingfederate = {
      source  = "pingidentity/pingfederate"
      version = ">= 1.0, < 2.0"
    }
  }
}
