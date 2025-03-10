# lerning terraform

## command 

```sh
terraform init

terraform validate

terraform plan

terraform apply -auto-approve

terraform destroy -auto-approve
```

## terraform download

```
https://developer.hashicorp.com/terraform/downloads
```

## UBUNTU

```bash
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform
```

## FEDORA

```bash
sudo dnf install -y dnf-plugins-core
sudo dnf config-manager --add-repo https://rpm.releases.hashicorp.com/fedora/hashicorp.repo
sudo dnf -y install terraform
```

## main.tf

```tf
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}
provider "docker" {}
resource "docker_image" "nginx" {
  name         = "nginx:1.22.0"
  keep_locally = false
}
resource "docker_container" "nginx" {
  image = docker_image.nginx.image_id
  name  = "tutorial"
  ports {
    internal = 80
    external = 8199
  }
}
```

## loop develop

```
terraform fmt

terraform validate

terraform init

terraform apply

ANSWER => yes

Test Browser URL => http://172.16.1.5:8199

terraform destroy
```
