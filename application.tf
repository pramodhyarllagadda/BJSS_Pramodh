resource "aws_autoscaling_group" "asg" {
  name                      = "${var.candidate}-frontend"
  min_size                  = 1
  max_size                  = 1
  desired_capacity          = 1
  health_check_grace_period = 300
  health_check_type         = "EC2"
  vpc_zone_identifier       = ["${aws_subnet.public.id}"]

  launch_template {
    id      = "${aws_launch_template.frontend.id}"
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.candidate}"
    propagate_at_launch = true
  }
}

resource "aws_launch_template" "frontend" {
  name          = "${var.candidate}-frontend"
  image_id      = "" # TODO: Work out the Amazon Linux 2 AMI ID
  instance_type = "t2.micro"

  user_data = filebase64("${path.module}/scripts/bootstrap.sh")

  iam_instance_profile {
    name = aws_iam_instance_profile.node.name
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups = [
      "${aws_security_group.node.id}"
    ]
  }

  tag_specifications {
    resource_type = "volume"
    tags = {
      Name = var.candidate
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = var.candidate
    }
  }

  tags = {
    Name = "${var.candidate}"
  }
}

resource "aws_iam_instance_profile" "node" {
  name = "${var.candidate}_instance_profile"
  role = aws_iam_role.node.name

  tags = {
    Name = "${var.candidate}"
  }
}

resource "aws_iam_role" "node" {
  name = "${var.candidate}_node"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF

  tags = {
    Name = "${var.candidate}"
  }
}

resource "aws_iam_role_policy_attachment" "node" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_security_group" "node" {
  vpc_id = "${aws_vpc.vpc.id}"
  name   = "${var.candidate}-node"

  tags = {
    Name = "${var.candidate}"
  }
}

resource "aws_security_group_rule" "node_ingress" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "all"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.node.id}"
}

resource "aws_security_group_rule" "node_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "all"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.node.id}"
}
