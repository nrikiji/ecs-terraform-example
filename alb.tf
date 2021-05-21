
# セキュリティグループ
# ・外へは全許可
# ・外からはhttpのみ許可
resource "aws_security_group" "EcsAlbSG" {
  name        = "EcsAlbSG"
  description = "Allow Http trafic"
  vpc_id      = aws_vpc.ecs_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "EcsAlbSG"
  }
}

resource "aws_lb" "EcsAlb" {
  load_balancer_type = "application"
  name               = "EcsAlb"

  security_groups = [aws_security_group.EcsAlbSG.id]
  subnets         = [aws_subnet.public_subnet_1a.id, aws_subnet.public_subnet_1c.id]
}

# Backend
resource "aws_lb_target_group" "EcsAlbBackendTargetGroup" {
  name        = "EcsAlbBackendTargetGroup"
  vpc_id      = aws_vpc.ecs_vpc.id
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"

  health_check {
    port = 80
    path = "/"
  }
}

resource "aws_lb_listener" "EcsAlbBackendListener" {
  port              = "80"
  protocol          = "HTTP"
  load_balancer_arn = aws_lb.EcsAlb.arn

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      status_code  = "404"
      message_body = "Not Found"
    }
  }
}

resource "aws_lb_listener_rule" "EcsAlbBackendListenerRule" {
  listener_arn = aws_lb_listener.EcsAlbBackendListener.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.EcsAlbBackendTargetGroup.id
  }

  condition {
    host_header {
      values = [var.backend_host]
    }
  }
}

# Frontend
resource "aws_lb_target_group" "EcsAlbFrontendTargetGroup" {
  name        = "EcsAlbFrontendendTargetGroup"
  vpc_id      = aws_vpc.ecs_vpc.id
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"

  health_check {
    port = 80
    path = "/"
  }
}

resource "aws_lb_listener" "EcsAlbFrontendListener" {
  port              = "80"
  protocol          = "HTTP"
  load_balancer_arn = aws_lb.EcsAlb.arn

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      status_code  = "404"
      message_body = "Not Found"
    }
  }
}

resource "aws_lb_listener_rule" "EcsAlbFrontendListenerRule" {
  listener_arn = aws_lb_listener.EcsAlbFrontendListener.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.EcsAlbFrontendTargetGroup.id
  }

  condition {
    host_header {
      values = [var.frontend_host]
    }
  }
}
