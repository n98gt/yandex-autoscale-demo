resource "yandex_message_queue" "demo" {
  name                       = var.queue_name
  access_key                 = yandex_iam_service_account_static_access_key.queue_autoscale_sa.access_key
  secret_key                 = yandex_iam_service_account_static_access_key.queue_autoscale_sa.secret_key
  visibility_timeout_seconds = 600
  receive_wait_time_seconds  = 20
  message_retention_seconds  = 1209600
}
