
# セキュリティグループ
#  外へのアクセスは全許可
#  外からのアクセスはVPC内かつhttpポートのみを許可
resource "aws_security_group" "EcsSG" {
  name        = "EcsSG"
  description = "Ecs SG"
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
    cidr_blocks = ["10.0.0.0/16"]
  }

  tags = {
    Name = "EcsSG"
  }
}

# IAMロール
#  ECRへのアクセスとログ出力
data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "EcsTaskRole"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "amazon_ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

################
# Backend
################

# ECSクラスター
resource "aws_ecs_cluster" "EcsBackendCluster" {
  name = "EcsBackendCluster"
}

# アプリケーションログ
resource "aws_cloudwatch_log_group" "ecs_backend_log_group" {
  name = "ecs-backend-log-group"
}

# タスク定義 : コンテナの起動方法
resource "aws_ecs_task_definition" "EcsBackendTaskDefinition" {
  family                   = "EcsBackendTaskDefinition"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  container_definitions = jsonencode([
    {
      "name" : "backend",
      "image" : "${var.ecr_base_entrypoint}/${var.ecr_backend_name}",
      "portMappings" : [
        {
          "containerPort" : 80,
          "hostPort" : 80
        }
      ],
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-group" : "ecs-backend-log-group",
          "awslogs-region" : "ap-northeast-1",
          "awslogs-stream-prefix" : "backend"
        }
      }
    }
  ])
}

# サービス : タスクをどこで起動するか、ALBのターゲットグループとして指定
resource "aws_ecs_service" "EcsBackendService" {
  name            = "EcsBackendService"
  depends_on      = [aws_lb_listener_rule.EcsAlbBackendListenerRule]
  cluster         = aws_ecs_cluster.EcsBackendCluster.name
  launch_type     = "FARGATE"
  desired_count   = "1"
  task_definition = aws_ecs_task_definition.EcsBackendTaskDefinition.arn

  network_configuration {
    subnets          = [aws_subnet.public_subnet_1a.id, aws_subnet.public_subnet_1c.id]
    security_groups  = [aws_security_group.EcsSG.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.EcsAlbBackendTargetGroup.arn
    container_name   = "backend"
    container_port   = "80"
  }
}

################
# Frontend
################

# ECSクラスター
resource "aws_ecs_cluster" "EcsFrontendCluster" {
  name = "EcsFrontendCluster"
}

# アプリケーションログ
resource "aws_cloudwatch_log_group" "ecs_frontend_log_group" {
  name = "ecs-frontend-log-group"
}

# タスク定義 : コンテナの起動方法
resource "aws_ecs_task_definition" "EcsFrontendTaskDefinition" {
  family                   = "EcsFrontendTaskDefinition"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  container_definitions = jsonencode([
    {
      "name" : "frontend",
      "image" : "${var.ecr_base_entrypoint}/${var.ecr_frontend_name}",
      "portMappings" : [
        {
          "containerPort" : 80,
          "hostPort" : 80
        }
      ],
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-group" : "ecs-frontend-log-group",
          "awslogs-region" : "ap-northeast-1",
          "awslogs-stream-prefix" : "frontend"
        }
      }
    }
  ])
}

# サービス : タスクをどこで起動するか、ALBのターゲットグループとして指定
resource "aws_ecs_service" "EcsFrontendService" {
  name            = "EcsFrontendService"
  depends_on      = [aws_lb_listener_rule.EcsAlbFrontendListenerRule]
  cluster         = aws_ecs_cluster.EcsFrontendCluster.name
  launch_type     = "FARGATE"
  desired_count   = "1"
  task_definition = aws_ecs_task_definition.EcsFrontendTaskDefinition.arn

  network_configuration {
    subnets          = [aws_subnet.public_subnet_1a.id, aws_subnet.public_subnet_1c.id]
    security_groups  = [aws_security_group.EcsSG.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.EcsAlbFrontendTargetGroup.arn
    container_name   = "frontend"
    container_port   = "80"
  }
}

