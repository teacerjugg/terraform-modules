output "repository_url" {
  value = aws_ecr_repository.this.repository_url
}

output "digest" {
  value = docker_registry_image.this[0].sha256_digest
}
