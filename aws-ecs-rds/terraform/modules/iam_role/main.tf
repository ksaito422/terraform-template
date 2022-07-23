################################################################################
# iam assume role
################################################################################

resource "aws_iam_role" "main" {
  name               = "${var.env}-${var.role_name}"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  tags = {
    Name = "${var.env}-${var.role_name}"
  }
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = var.identifiers
    }
    actions = ["sts:AssumeRole"]

    dynamic "condition" {
      for_each = var.condition

      content {
        test     = condition.value.test
        variable = condition.value.variable
        values   = condition.value.values
      }
    }
  }
}

################################################################################
# iam policy
################################################################################

resource "aws_iam_policy" "main" {
  count = length(var.policies)

  name   = "${var.env}-${var.policies[count.index].name}"
  policy = data.aws_iam_policy_document.main[count.index].json

  tags = {
    Name = "${var.env}-${var.policies[count.index].name}"
  }
}

data "aws_iam_policy_document" "main" {
  count = length(var.policies)

  statement {
    effect = "Allow"

    actions   = var.policies[count.index].actions
    resources = var.policies[count.index].resources
  }
}

################################################################################
# iam role policy attachment
################################################################################

resource "aws_iam_role_policy_attachment" "main" {
  count = length(var.policies)

  role       = aws_iam_role.main.name
  policy_arn = aws_iam_policy.main[count.index].arn
}

resource "aws_iam_role_policy_attachment" "aws_managed_policy" {
  count = length(var.managed_policy_arn)

  role       = aws_iam_role.main.name
  policy_arn = var.managed_policy_arn[count.index]
}
