terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "= 0.124.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.4.1"
    }
  }
  required_version = ">= 1.7.4"
}
