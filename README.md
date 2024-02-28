# Домашнее задание к занятию «Продвинутые методы работы с Terraform»   
   
### Задание 1   
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
