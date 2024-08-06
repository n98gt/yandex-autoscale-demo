data "yandex_resourcemanager_cloud" "this" {
  name = var.cloud_name
}

data "yandex_resourcemanager_folder" "this" {
  name     = var.folder_name
  cloud_id = data.yandex_resourcemanager_cloud.this.id
}

data "yandex_iam_service_account" "queue_autoscale_sa" {
  folder_id = data.yandex_resourcemanager_folder.this.id
  name      = var.instance_group_service_acc_name
  depends_on = [
    terraform_data.instance_group_service_acc
  ]
}

data "yandex_compute_image" "demo" {
  folder_id = data.yandex_resourcemanager_folder.this.id
  name      = var.packer_image_name
  depends_on = [
    terraform_data.packer_image
  ]
}
