
resource "terraform_data" "packer_image" {
  triggers_replace = [
    var.packer_image_name,
    local_file.queue,
    local_file.paker_json,
  ]

  provisioner "local-exec" {
    when        = create
    working_dir = path.module
    command     = "packer build generated_files/server-packer.json"
  }

  depends_on = [
    yandex_vpc_subnet.demo,
    local_file.paker_json,
    local_file.queue,
    local_sensitive_file.key_json,
  ]
}

# create instance_group with yc cli, since terraform provider for instance_group does not support auto_scale_type param (https://github.com/yandex-cloud/terraform-provider-yandex/issues/214)
resource "terraform_data" "instance_group" {
  triggers_replace = [
    var.packer_image_name,
    local_file.instance_group_specs,
  ]

  provisioner "local-exec" {
    when        = create
    working_dir = path.module
    command     = "yc compute instance-group create --file generated_files/spec.yaml --folder-name ${var.folder_name}"
  }

  depends_on = [
    terraform_data.packer_image,
    yandex_lockbox_secret_version.service_acc_secrets,
    local_file.instance_group_specs,
  ]
}
