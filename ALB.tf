resource "aws_lb_target_group" "Pramodh_bjss" {
  name     = "tf-Pramodh_bjss-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id
}

resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_lb_target_group_attachment" "Pramodh_bjss_tga" {
  target_group_arn = aws_lb_target_group.Pramodh_bjss.arn
  target_id        = aws_autoscaling_group.asg.id
  port             = 80
}

resource "aws_lb" "Pramodh_bjss_lb" {
  name               = "pramodh_bjss-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.node.id]
  subnets            = [for subnet in aws_subnet.public : subnet.id]

  enable_deletion_protection = true


  tags = {
    Environment = "production"
  }
}

resource "aws_lb_listener" "pramodh_bjss" {
  load_balancer_arn = aws_lb.Pramodh_bjss_lb.arn
  port              = "80"
  protocol          = "HTTPS"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.Pramodh_bjss_tga.arn
  }
}
