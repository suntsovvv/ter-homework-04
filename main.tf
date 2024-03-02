/*resource "yandex_vpc_network" "develop" {
  name = var.vpc_name
}
resource "yandex_vpc_subnet" "develop" {
  name           = var.vpc_name
  zone           = var.default_zone
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = var.default_cidr
}
*/

module "vpc" {
  source       = "./vpc"
  env_name     = var.env_name
  zone =  var.default_zone
  v4_cidr_block = var.v4_cidr_block
}
module "test-vm" {
  labels = {
    label = "marketing"
  }
  source         = "git::https://github.com/udjin10/yandex_compute_instance.git?ref=main"
  env_name       = var.test_vm.env_name
  #network_id     = yandex_vpc_network.develop.id
  network_id     = module.vpc.vpc_network.id
  subnet_zones   = [var.test_vm.subnet_zones]
  #subnet_ids     = [yandex_vpc_subnet.develop.id]
  subnet_ids     = [module.vpc.vpc_subnet.id]
  instance_name  = var.test_vm.instance_name
  instance_count = var.test_vm.instance_count
  image_family   = var.test_vm.image_family
  public_ip      = var.test_vm.public_ip

    metadata = {
    user-data          = data.template_file.cloudinit.rendered 
    serial-port-enable = var.test_vm.serial-port-enable
  }
}

module "example-vm" {
  labels = {
    label = "analytics"
  }
  source         = "git::https://github.com/udjin10/yandex_compute_instance.git?ref=main"
  env_name       = var.example_vm.env_name
  #network_id     = yandex_vpc_network.develop.id
  network_id = module.vpc.vpc_network.id
  subnet_zones   = [var.example_vm.subnet_zones]
  #subnet_ids     = [yandex_vpc_subnet.develop.id]
  subnet_ids     = [module.vpc.vpc_subnet.id]
  instance_name  = var.example_vm.instance_name
  instance_count = var.example_vm.instance_count
  image_family   = var.example_vm.image_family
  public_ip      = var.example_vm.public_ip

    metadata = {
    user-data          = data.template_file.cloudinit.rendered 
    serial-port-enable = var.example_vm.serial-port-enable
  }
 
}


data "template_file" "cloudinit" {
  template = file("./cloud-init.yml")
  vars = {
     ssh_public_key = var.ssh_public_key
  }
}
