resource "aws_ecr_repository" "tride-ci-app" {
  name                 = "tride-ci"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    IAC = "True"
  }
}
