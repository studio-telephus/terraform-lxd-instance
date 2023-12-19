terraform {
  required_version = ">= 0.13"
  required_providers {
    lxd = {
      source  = "terraform-lxd/lxd"
      version = "~> 1.10"
    }
  }
}
