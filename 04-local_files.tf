resource "local_sensitive_file" "key_json" {
  filename        = "${path.module}/generated_files/key.json"
  file_permission = "400"
  content         = jsonencode(local.filtered_object)
}

resource "local_sensitive_file" "access_key" {
  filename        = "${path.module}/generated_files/access_key"
  file_permission = "400"
  content = templatefile("${path.module}/templates/access_key.tftpl", {
    access_key = yandex_iam_service_account_static_access_key.queue_autoscale_sa.access_key
    secret_key = yandex_iam_service_account_static_access_key.queue_autoscale_sa.secret_key
    }
  )
}

resource "local_sensitive_file" "access_key_for_aws_cli" {
  filename        = "${path.module}/generated_files/access_key_aws_cli"
  file_permission = "400"
  content = templatefile("${path.module}/templates/access_key_aws_cli.tftpl", {
    access_key = yandex_iam_service_account_static_access_key.queue_autoscale_sa.access_key
    secret_key = yandex_iam_service_account_static_access_key.queue_autoscale_sa.secret_key
    }
  )
}

resource "local_file" "paker_json" {
  filename        = "${path.module}/generated_files/server-packer.json"
  file_permission = "644"
  content = templatefile("${path.module}/templates/server-packer.json.tftpl", {
    service_acc_id             = data.yandex_iam_service_account.queue_autoscale_sa.id
    folder_id                  = data.yandex_resourcemanager_folder.this.id
    subnet_id                  = yandex_vpc_subnet.demo.id
    packer_image_name          = var.packer_image_name
    packer_source_image_family = var.packer_source_image_family
    }
  )
}

resource "local_file" "queue" {
  filename        = "${path.module}/generated_files/queue"
  file_permission = "644"
  content = templatefile("${path.module}/templates/queue.tftpl", {
    queue_url = yandex_message_queue.demo.id
    }
  )
}

resource "local_file" "messages_script" {
  filename        = "${path.module}/generated_files/messages.sh"
  file_permission = "755"
  content = templatefile("${path.module}/templates/messages.sh.tftpl", {
    queue_url = yandex_message_queue.demo.id
    }
  )
}

resource "local_file" "instance_group_specs" {
  filename        = "${path.module}/generated_files/spec.yaml"
  file_permission = "755"
  content = templatefile("${path.module}/templates/spec.yaml.tftpl", {
    folder_id         = data.yandex_resourcemanager_folder.this.id
    image_id          = data.yandex_compute_image.demo.id
    network_id        = yandex_vpc_network.demo.id
    subnet_id         = yandex_vpc_subnet.demo.id
    service_acc_id    = data.yandex_iam_service_account.queue_autoscale_sa.id
    vm_service_acc_id = yandex_iam_service_account.queue_autoscale_vm_sa.id
    launch_script_content = templatefile("${path.module}/templates/launch.sh.tftpl", {
      secret_id = yandex_lockbox_secret.service_acc_secrets.id
    })
    instance_group_name = var.instance_group_name
  })
  depends_on = [terraform_data.packer_image]
}
