resource "yandex_vpc_network" "demo" {
  folder_id = data.yandex_resourcemanager_folder.this.id
  name      = var.vpc_name
  labels    = var.labels
}

resource "yandex_vpc_subnet" "demo" {
  name           = var.subnet_name
  folder_id      = data.yandex_resourcemanager_folder.this.id
  v4_cidr_blocks = ["10.2.0.0/16"]
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.demo.id
  labels         = var.labels
}
