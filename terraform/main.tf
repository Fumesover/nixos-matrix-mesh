terraform {
  required_providers {
    exoscale = {
      source  = "exoscale/exoscale"
      version = "~> 0.69.3"
    }
  }
}

provider "exoscale" {}
