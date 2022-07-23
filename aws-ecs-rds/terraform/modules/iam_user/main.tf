################################################################################
# iam user
################################################################################

resource "aws_iam_user" "main" {
  name = "${var.env}-${var.user_name}"
}

################################################################################
# iam policy
################################################################################

resource "aws_iam_policy" "main" {
  count = length(var.policies)

  name   = "${var.env}-${var.policies[count.index].name}"
  policy = data.aws_iam_policy_document.main[count.index].json
}

data "aws_iam_policy_document" "main" {
  count = length(var.policies)

  statement {
    effect = "Allow"

    actions   = var.policies[count.index].actions
    resources = var.policies[count.index].resources

    dynamic "condition" {
      for_each = var.policies[count.index].condition

      content {
        test     = condition.value.test
        variable = condition.value.variable
        values   = condition.value.values
      }
    }

  }
}

################################################################################
# iam user attachment policy
################################################################################

resource "aws_iam_user_policy_attachment" "main" {
  count = length(var.policies)

  user       = aws_iam_user.main.name
  policy_arn = aws_iam_policy.main[count.index].arn
}