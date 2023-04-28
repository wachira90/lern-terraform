# docker nginx php

## Create a new directory for your Terraform project and navigate to it:

```
mkdir my-terraform-project
cd my-terraform-project
```

## Create a new file named main.tf and add the following code to it:

```
provider "docker" {
  host = "tcp://127.0.0.1:2376/"
}

resource "docker_image" "nginx" {
  name         = "nginx:latest"
  keep_locally = true
}

resource "docker_container" "nginx" {
  name  = "my-nginx-container"
  image = docker_image.nginx.latest

  port {
    internal = 80
    external = 8080
  }

  volumes {
    host_path      = "/var/www/html"
    container_path = "/usr/share/nginx/html"
  }
}

resource "docker_image" "php" {
  name         = "php:latest"
  keep_locally = true
}

resource "docker_container" "php" {
  name  = "my-php-container"
  image = docker_image.php.latest

  volumes {
    host_path      = "/var/www/html"
    container_path = "/var/www/html"
  }

  depends_on = [
    docker_container.nginx
  ]
}
```

This Terraform code will create two Docker containers: one running nginx and another running PHP. The docker_image resource is used to download the latest versions of the nginx and PHP images from Docker Hub. The docker_container resource is used to create a new container from each image and configure them as follows:

- The nginx container is named my-nginx-container, exposes port 80 internally and port 8080 externally, and mounts the /var/www/html directory from the host machine to /usr/share/nginx/html in the container.

- The PHP container is named my-php-container, mounts the /var/www/html directory from the host machine to /var/www/html in the container, and depends on the nginx container to be running first.


## Initialize the Terraform project and download the required provider plugins:

```
terraform init
```

## Apply the Terraform code to create the Docker containers:

```
terraform apply
```


This will create the two Docker containers, download the nginx and PHP images, and configure the containers as specified in the main.tf file. Once the containers are running, you can access the web server by visiting http://localhost:8080 in your web browser.



