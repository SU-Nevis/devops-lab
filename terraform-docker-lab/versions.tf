terraform {
  required_version = "= 1.16.6"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "= 3.8.0"
    }
  }
}
