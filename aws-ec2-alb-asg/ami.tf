
####################################
# AMI
####################################

resource "aws_ami_from_instance" "this" {
  name               = "terraform-example"
  source_instance_id = aws_instance.this.id

  depends_on = [aws_instance.this]
}
