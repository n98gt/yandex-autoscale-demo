resource "yandex_lockbox_secret" "service_acc_secrets" {
  folder_id = data.yandex_resourcemanager_folder.this.id
  name      = "queue_service_acc_secrets"
}

resource "yandex_lockbox_secret_version" "service_acc_secrets" {
  secret_id = yandex_lockbox_secret.service_acc_secrets.id
  entries {
    key        = "access_key"
    text_value = yandex_iam_service_account_static_access_key.queue_autoscale_sa.access_key
  }
  entries {
    key        = "secret_key"
    text_value = yandex_iam_service_account_static_access_key.queue_autoscale_sa.secret_key
  }
}
