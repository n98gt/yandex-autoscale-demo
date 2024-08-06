provider "yandex" {
  service_account_key_file = "./credentials.json"
}

terraform {
  backend "local" {}
}
