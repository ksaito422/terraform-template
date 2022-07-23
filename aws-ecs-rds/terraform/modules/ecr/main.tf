################################################################################
# ECR 
# ・イメージタグの上書きを禁止とする。同じタグ名のイメージをpushしたら上書きすることが可能なため。
#   既存のイメージはタグが外されバージョン管理ができなくなる。
# ・脆弱性のイメージスキャンは有効にする（ECRコンソールで確認可能）
################################################################################

resource "aws_ecr_repository" "main" {
  name                 = "ecr-${var.name}-${var.env}"
  image_tag_mutability = var.image_tag_mutability

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    "Name" = "${var.env}-ecr"
  }
}


################################################################################
# ECR lifecycle policy
################################################################################

resource "aws_ecr_lifecycle_policy" "main" {
  repository = aws_ecr_repository.main.name

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Hold only ${var.holding_count} images",
            "selection": {
                "tagStatus": "any",
                "countType": "imageCountMoreThan",
                "countNumber": ${var.holding_count}
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}



