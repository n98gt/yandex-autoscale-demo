variable "cloud_name" {
  type = string
}

variable "folder_name" {
  type = string
}

variable "labels" {
  type = map(string)
  default = {
    created_by = "terraform"
  }
}
variable "subnet_name" {
  default = "subnet-ru-central1-a"
  type    = string
}

variable "packer_image_name" {
  description = "name of an image created by packer (==> yandex.builder: Creating image: queue-autoscale-image-v1722258604)"
  type        = string
  default     = "queue-autoscale-image-demo"
}

variable "packer_source_image_family" {
  description = "yc compute image list --folder-id standard-images"
  type        = string
  default     = "ubuntu-2004-lts-oslogin"
}

variable "queue_name" {
  type    = string
  default = "queue-autoscale-queue"
}

variable "vpc_name" {
  type    = string
  default = "autoscale-demo"
}

variable "instance_group_service_acc_name" {
  description = "service account that will be attached to instance_group"
  type        = string
  default     = "queue-autoscale-sa"
}

variable "instance_group_vm_service_acc_name" {
  description = "service account that will be attached to VMs in instance_group"
  type        = string
  default     = "queue-autoscale-vm-sa"
}

variable "instance_group_name" {
  type    = string
  default = "queue-autoscale-ig-demo"
}
