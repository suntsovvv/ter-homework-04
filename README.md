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
### Задание 3
1. Выведите список ресурсов в стейте.
```
user@study:~/home_work/ter-homeworks/ter-homeworks-04$ terraform state list
data.template_file.cloudinit
module.example-vm.data.yandex_compute_image.my_image
module.example-vm.yandex_compute_instance.vm[0]
module.test-vm.data.yandex_compute_image.my_image
module.test-vm.yandex_compute_instance.vm[0]
module.vpc.yandex_vpc_network.network
module.vpc.yandex_vpc_subnet.subnet
```
2. Полностью удалите из стейта модуль vpc.
```
user@study:~/home_work/ter-homeworks/ter-homeworks-04$ terraform state rm module.vpc
Removed module.vpc.yandex_vpc_network.network
Removed module.vpc.yandex_vpc_subnet.subnet
Successfully removed 2 resource instance(s).
```
3. Полностью удалите из стейта модуль vm.
```
user@study:~/home_work/ter-homeworks/ter-homeworks-04$ terraform state rm module.test-vm
Removed module.test-vm.data.yandex_compute_image.my_image
Removed module.test-vm.yandex_compute_instance.vm[0]
Successfully removed 2 resource instance(s).
```
4. Импортируйте всё обратно. Проверьте terraform plan. Изменений быть не должно.
```
user@study:~/home_work/ter-homeworks/ter-homeworks-04$ terraform import module.vpc.yandex_vpc_network.network enpapie1gqevih07fjf2
data.template_file.cloudinit: Reading...
data.template_file.cloudinit: Read complete after 0s [id=0e4eef7ccc45c95b0fd066bfa8768e55f718d51e123c0528a8a2509f0a674271]
module.vpc.yandex_vpc_network.network: Importing from ID "enpapie1gqevih07fjf2"...
module.example-vm.data.yandex_compute_image.my_image: Reading...
module.test-vm.data.yandex_compute_image.my_image: Reading...
module.vpc.yandex_vpc_network.network: Import prepared!
  Prepared yandex_vpc_network for import
module.vpc.yandex_vpc_network.network: Refreshing state... [id=enpapie1gqevih07fjf2]
module.example-vm.data.yandex_compute_image.my_image: Read complete after 9s [id=fd8t849k1aoosejtcicj]
module.test-vm.data.yandex_compute_image.my_image: Read complete after 9s [id=fd8t849k1aoosejtcicj]

Import successful!

The resources that were imported are shown above. These resources are now in
your Terraform state and will henceforth be managed by Terraform.
```   
```
user@study:~/home_work/ter-homeworks/ter-homeworks-04$ terraform import module.vpc.yandex_vpc_subnet.subnet e9bt7lmeap8p2075eh0g
data.template_file.cloudinit: Reading...
data.template_file.cloudinit: Read complete after 0s [id=0e4eef7ccc45c95b0fd066bfa8768e55f718d51e123c0528a8a2509f0a674271]
module.example-vm.data.yandex_compute_image.my_image: Reading...
module.test-vm.data.yandex_compute_image.my_image: Reading...
module.vpc.yandex_vpc_subnet.subnet: Importing from ID "e9bt7lmeap8p2075eh0g"...
module.vpc.yandex_vpc_subnet.subnet: Import prepared!
  Prepared yandex_vpc_subnet for import
module.vpc.yandex_vpc_subnet.subnet: Refreshing state... [id=e9bt7lmeap8p2075eh0g]
module.example-vm.data.yandex_compute_image.my_image: Read complete after 8s [id=fd8t849k1aoosejtcicj]
module.test-vm.data.yandex_compute_image.my_image: Read complete after 8s [id=fd8t849k1aoosejtcicj]

Import successful!

The resources that were imported are shown above. These resources are now in
your Terraform state and will henceforth be managed by Terraform.
```   
```
user@study:~/home_work/ter-homeworks/ter-homeworks-04$ terraform import module.test-vm.yandex_compute_instance.vm[0] fhmahajga8dptrt7cbdj
module.example-vm.data.yandex_compute_image.my_image: Reading...
module.test-vm.data.yandex_compute_image.my_image: Reading...
data.template_file.cloudinit: Reading...
data.template_file.cloudinit: Read complete after 0s [id=0e4eef7ccc45c95b0fd066bfa8768e55f718d51e123c0528a8a2509f0a674271]
module.test-vm.data.yandex_compute_image.my_image: Read complete after 9s [id=fd8t849k1aoosejtcicj]
module.test-vm.yandex_compute_instance.vm[0]: Importing from ID "fhmahajga8dptrt7cbdj"...
module.test-vm.yandex_compute_instance.vm[0]: Import prepared!
  Prepared yandex_compute_instance for import
module.test-vm.yandex_compute_instance.vm[0]: Refreshing state... [id=fhmahajga8dptrt7cbdj]
module.example-vm.data.yandex_compute_image.my_image: Read complete after 9s [id=fd8t849k1aoosejtcicj]

Import successful!

The resources that were imported are shown above. These resources are now in
your Terraform state and will henceforth be managed by Terraform.
```   
```
user@study:~/home_work/ter-homeworks/ter-homeworks-04$ terraform plan
data.template_file.cloudinit: Reading...
data.template_file.cloudinit: Read complete after 0s [id=0e4eef7ccc45c95b0fd066bfa8768e55f718d51e123c0528a8a2509f0a674271]
module.test-vm.data.yandex_compute_image.my_image: Reading...
module.vpc.yandex_vpc_network.network: Refreshing state... [id=enpapie1gqevih07fjf2]
module.example-vm.data.yandex_compute_image.my_image: Reading...
module.test-vm.data.yandex_compute_image.my_image: Read complete after 9s [id=fd8t849k1aoosejtcicj]
module.example-vm.data.yandex_compute_image.my_image: Read complete after 9s [id=fd8t849k1aoosejtcicj]
module.vpc.yandex_vpc_subnet.subnet: Refreshing state... [id=e9bt7lmeap8p2075eh0g]
module.example-vm.yandex_compute_instance.vm[0]: Refreshing state... [id=fhm8tukpte1qfo121b7q]
module.test-vm.yandex_compute_instance.vm[0]: Refreshing state... [id=fhmahajga8dptrt7cbdj]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  ~ update in-place

Terraform will perform the following actions:

  # module.test-vm.yandex_compute_instance.vm[0] will be updated in-place
  ~ resource "yandex_compute_instance" "vm" {
      + allow_stopping_for_update = true
        id                        = "fhmahajga8dptrt7cbdj"
        name                      = "develop-web-0"
        # (11 unchanged attributes hidden)

        # (6 unchanged blocks hidden)
    }

Plan: 0 to add, 1 to change, 0 to destroy.

─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply" now.
user@study:~/home_work/ter-homeworks/ter-homeworks-04$ 
```
### Задание 4*
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
/*
resource "yandex_vpc_subnet" "subnet" {
  name           = "${var.env_name}-${var.zone}"
  zone           = var.zone
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = var.v4_cidr_block
}*/
resource "yandex_vpc_subnet" "subnet" {
  for_each = { for s in var.subnets : index(var.subnets,s)=> s }
  name           = "${var.env_name}-${each.value.zone}"
  zone           = each.value.zone
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = [each.value.cidr]
}
```
```
Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # module.vpc.yandex_vpc_network.network will be created
  + resource "yandex_vpc_network" "network" {
      + created_at                = (known after apply)
      + default_security_group_id = (known after apply)
      + folder_id                 = (known after apply)
      + id                        = (known after apply)
      + labels                    = (known after apply)
      + name                      = "develop"
      + subnet_ids                = (known after apply)
    }

  # module.vpc.yandex_vpc_subnet.subnet["0"] will be created
  + resource "yandex_vpc_subnet" "subnet" {
      + created_at     = (known after apply)
      + folder_id      = (known after apply)
      + id             = (known after apply)
      + labels         = (known after apply)
      + name           = "develop-ru-central1-a"
      + network_id     = (known after apply)
      + v4_cidr_blocks = [
          + "10.0.1.0/24",
        ]
      + v6_cidr_blocks = (known after apply)
      + zone           = "ru-central1-a"
    }

  # module.vpc.yandex_vpc_subnet.subnet["1"] will be created
  + resource "yandex_vpc_subnet" "subnet" {
      + created_at     = (known after apply)
      + folder_id      = (known after apply)
      + id             = (known after apply)
      + labels         = (known after apply)
      + name           = "develop-ru-central1-b"
      + network_id     = (known after apply)
      + v4_cidr_blocks = [
          + "10.0.2.0/24",
        ]
      + v6_cidr_blocks = (known after apply)
      + zone           = "ru-central1-b"
    }

  # module.vpc.yandex_vpc_subnet.subnet["2"] will be created
  + resource "yandex_vpc_subnet" "subnet" {
      + created_at     = (known after apply)
      + folder_id      = (known after apply)
      + id             = (known after apply)
      + labels         = (known after apply)
      + name           = "develop-ru-central1-c"
      + network_id     = (known after apply)
      + v4_cidr_blocks = [
          + "10.0.3.0/24",
        ]
      + v6_cidr_blocks = (known after apply)
      + zone           = "ru-central1-c"
    }

Plan: 4 to add, 0 to change, 0 to destroy.
```
![image](https://github.com/suntsovvv/ter-homework-04/assets/154943765/6f1ab022-ce40-44da-bf92-e25367e1f6dc)
