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
