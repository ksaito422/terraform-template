data "aws_iam_policy_document" "allow_describe_regions" {
  statement {
    effect    = "Allow"
    actions   = ["ec2.DescribeRegions"]
    resources = ["*"]
  }
}
