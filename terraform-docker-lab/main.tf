provider "docker" {}

resource "docker_image" "web" {
  name         = "nginx:${var.image_tag}"
  keep_locally = false
}

resource "docker_container" "web" {
  name  = "${var.lab_name}-web"
  image = docker_image.web.image_id

  labels {
    label = "devops.lab"
    value = var.lab_name
  }

  ports {
    internal = 80
    external = var.host_port
    ip       = "127.0.0.1"
  }

  upload {
    content = file("${path.module}/site/index.html")
    file    = "/usr/share/nginx/html/index.html"
  }
}
