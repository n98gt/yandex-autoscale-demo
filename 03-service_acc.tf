#  ---------------------------------------------------------------------------------
#  instance group sa
#  ---------------------------------------------------------------------------------

resource "terraform_data" "instance_group_service_acc" {
  provisioner "local-exec" {
    when        = create
    working_dir = path.module
    command     = "yc iam service-account create --name '${var.instance_group_service_acc_name}' --description 'temporary acc for testing instance_group autoscale' --folder-name ${var.folder_name}"
  }
}

resource "yandex_resourcemanager_folder_iam_member" "queue_autoscale_sa_folder_editor" {
  folder_id = data.yandex_resourcemanager_folder.this.id
  role      = "editor"
  member    = "serviceAccount:${data.yandex_iam_service_account.queue_autoscale_sa.id}"
}

resource "yandex_iam_service_account_static_access_key" "queue_autoscale_sa" {
  service_account_id = data.yandex_iam_service_account.queue_autoscale_sa.id
  description        = "static access key for message queue tests"
}

resource "yandex_iam_service_account_key" "queue_autoscale_sa_auth_key" {
  service_account_id = data.yandex_iam_service_account.queue_autoscale_sa.id
  description        = "for packer image building"
  key_algorithm      = "RSA_4096"
}

locals {
  filtered_object = merge(
    {
      for key, value in yandex_iam_service_account_key.queue_autoscale_sa_auth_key :
      key => value
      if key != "pgp_key" && key != "key_fingerprint" && key != "format" && key != "encrypted_private_key"
    }
  )
}

#  ---------------------------------------------------------------------------------
#  instance group vm sa
#  ---------------------------------------------------------------------------------
resource "yandex_iam_service_account" "queue_autoscale_vm_sa" {
  folder_id   = data.yandex_resourcemanager_folder.this.id
  name        = var.instance_group_vm_service_acc_name
  description = "temporary acc for testing instance_group autoscale"
}

resource "yandex_resourcemanager_folder_iam_member" "queue_autoscale_vm_sa_lockbox_payload_viewer" {
  folder_id = data.yandex_resourcemanager_folder.this.id
  role      = "lockbox.payloadViewer"
  member    = "serviceAccount:${yandex_iam_service_account.queue_autoscale_vm_sa.id}"
}
