resource "aws_ecr_repository" "bastion" {
  name                 = "${var.prefix}-ecr"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "${var.prefix}-ecr"
  }
}

