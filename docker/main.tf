# pull docker images

resource "docker_image" "ubuntu" {
    name = "ubuntu:focal"
    keep_locally = false
}

# run docker image

resource "docker_container" "ubuntu" {
  name = "ubuntu"
  image = docker_image.ubuntu.latest
#   rm = true
  must_run = false
}