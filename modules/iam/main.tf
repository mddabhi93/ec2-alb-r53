data "aws_iam_policy_document" "instance_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "ssm" {
  name               = "${var.project_name}-${var.environment}-ssm-role"
  assume_role_policy = data.aws_iam_policy_document.instance_assume_role.json

  tags = {
    Name = "${var.project_name}-${var.environment}-ssm-role"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm" {
  name = "${var.project_name}-${var.environment}-instance-profile"
  role = aws_iam_role.ssm.name

  lifecycle {
    prevent_destroy = true
  }
}
