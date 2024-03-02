# Домашнее задание к занятию «Продвинутые методы работы с Terraform»   
   
### Задание 1   
main.tf:   
```hcl
resource "yandex_vpc_network" "develop" {
  name = var.vpc_name
}
resource "yandex_vpc_subnet" "develop" {
  name           = var.vpc_name
  zone           = var.default_zone
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = var.default_cidr
}


module "test-vm" {
  labels = {
    label = "marketing"
  }
  source         = "git::https://github.com/udjin10/yandex_compute_instance.git?ref=main"
  env_name       = var.test_vm.env_name
  network_id     = yandex_vpc_network.develop.id
  subnet_zones   = [var.test_vm.subnet_zones]
  subnet_ids     = [yandex_vpc_subnet.develop.id]
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
  network_id     = yandex_vpc_network.develop.id
  subnet_zones   = [var.example_vm.subnet_zones]
  subnet_ids     = [yandex_vpc_subnet.develop.id]
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
```

```yml
#cloud-config
users:
  - name: ubuntu
    groups: sudo
    shell: /bin/bash
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    ssh_authorized_keys:
      - ${ssh_public_key}

package_update: true
package_upgrade: false
packages:
 - vim
 - nginx
```
![image](https://github.com/suntsovvv/ter-homework-04/assets/154943765/e9aaf9a4-e54b-4461-b78b-0fe347785718)   

```
ubuntu@develop-web-0:~$ sudo nginx -t
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
ubuntu@develop-web-0:~$
```
```
user@study:~/home_work/ter-homeworks/ter-homeworks-04$ terraform console
> module.test-vm
{
  "external_ip_address" = [
    "178.154.201.121",
  ]
  "fqdn" = [
    "develop-web-0.ru-central1.internal",
  ]
  "internal_ip_address" = [
    "10.0.1.27",
  ]
  "labels" = [
    tomap({
      "label" = "marketing"
    }),
  ]
  "network_interface" = [
    tolist([
      {
        "dns_record" = tolist([])
        "index" = 0
        "ip_address" = "10.0.1.27"
        "ipv4" = true
        "ipv6" = false
        "ipv6_address" = ""
        "ipv6_dns_record" = tolist([])
        "mac_address" = "d0:0d:17:85:a4:37"
        "nat" = true
        "nat_dns_record" = tolist([])
        "nat_ip_address" = "178.154.201.121"
        "nat_ip_version" = "IPV4"
        "security_group_ids" = toset([])
        "subnet_id" = "e9bnqlm66utu29dtee3q"
      },
    ]),
  ]
}
>
```
### Задание 2    
main.tf root модуля:   
```hcl
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
```
main.tf модуля vpc:   
```hcl
terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">=1.5"
}
 

resource "yandex_vpc_network" "network" {
  name = var.env_name
}

resource "yandex_vpc_subnet" "subnet" {
  name           = "${var.env_name}-${var.zone}"
  zone           = var.zone
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = var.v4_cidr_block
}
```
outputs.tf модуля vpc:
```hcl
output "vpc_network"{
    value=yandex_vpc_network.network
    description="Yandex vpc network"
}
output "vpc_subnet"{
    value=yandex_vpc_subnet.subnet
    description="Yandex vpc subnet"
}
```
Вывод terraform console:
```
user@study:~/home_work/ter-homeworks/ter-homeworks-04$ terraform console
> module.vpc
{
  "vpc_network" = {
    "created_at" = "2024-03-02T12:37:26Z"
    "default_security_group_id" = "enp5p629e82o4dv45bib"
    "description" = ""
    "folder_id" = "b1gksj8p2pj7de0re301"
    "id" = "enpapie1gqevih07fjf2"
    "labels" = tomap({})
    "name" = "develop"
    "subnet_ids" = tolist([])
    "timeouts" = null /* object */
  }
  "vpc_subnet" = {
    "created_at" = "2024-03-02T12:37:29Z"
    "description" = ""
    "dhcp_options" = tolist([])
    "folder_id" = "b1gksj8p2pj7de0re301"
    "id" = "e9bt7lmeap8p2075eh0g"
    "labels" = tomap({})
    "name" = "develop-ru-central1-a"
    "network_id" = "enpapie1gqevih07fjf2"
    "route_table_id" = ""
    "timeouts" = null /* object */
    "v4_cidr_blocks" = tolist([
      "10.0.1.0/24",
    ])
    "v6_cidr_blocks" = tolist([])
    "zone" = "ru-central1-a"
  }
}
>
```
Сгенерирoвал документацию к модулю с помощью terraform-docs:   

```
user@study:~/home_work/ter-homeworks/ter-homeworks-04$ sudo terraform-docs markdown table --output-file Readme.md ./vpc
vpc/Readme.md updated successfully
user@study:~/home_work/ter-homeworks/ter-homeworks-04$
```
```
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.5 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_yandex"></a> [yandex](#provider\_yandex) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [yandex_vpc_network.network](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/vpc_network) | resource |
| [yandex_vpc_subnet.subnet](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/vpc_subnet) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_env_name"></a> [env\_name](#input\_env\_name) | n/a | `any` | n/a | yes |
| <a name="input_v4_cidr_block"></a> [v4\_cidr\_block](#input\_v4\_cidr\_block) | n/a | `any` | n/a | yes |
| <a name="input_zone"></a> [zone](#input\_zone) | n/a | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vpc_network"></a> [vpc\_network](#output\_vpc\_network) | Yandex vpc network |
| <a name="output_vpc_subnet"></a> [vpc\_subnet](#output\_vpc\_subnet) | Yandex vpc subnet |
<!-- END_TF_DOCS -->
```