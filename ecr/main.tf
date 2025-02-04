resource "aws_ecr_repository" "this" {
  name                 = var.repository_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  force_delete = var.force_delete
}

data "aws_ecr_authorization_token" "this" {}

resource "docker_image" "this" {
  count = var.dockerfile_path != null ? 1 : 0

  name         = "${aws_ecr_repository.this.repository_url}:${var.tag}"
  platform     = var.platform
  keep_locally = false
  build {
    context    = path.root
    dockerfile = var.dockerfile_path
  }

  triggers = {
    dir_sha1 = sha1(join(
      "",
      [
        for f in fileset(dirname(var.dockerfile_path), "**") :
        filesha1(join("/", [dirname(var.dockerfile_path), f]))
      ]
    ))
  }
}

resource "docker_registry_image" "this" {
  count = var.dockerfile_path != null ? 1 : 0

  name          = docker_image.this[0].name
  keep_remotely = false

  triggers = {
    digest = docker_image.this[0].repo_digest
  }
}
