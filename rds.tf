
# セキュリティグループ
# ・外へは全許可
# ・外からはVPS内かつmysqlポートのみ許可
resource "aws_security_group" "EcsRdsSG" {
  name   = "EcsRdsSG"
  vpc_id = aws_vpc.ecs_vpc.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "EcsRdsSG"
  }
}

# MySQLの設定とサブネットグループ
resource "aws_db_subnet_group" "EcsRdsSubnetGroup" {
  name       = "ecs-rds-subnet-group"
  subnet_ids = [aws_subnet.public_subnet_1a.id, aws_subnet.public_subnet_1c.id]
  tags = {
    Name = "EcsRdsSubnetGroup"
  }
}

resource "aws_db_parameter_group" "EcsRdsParamGroup" {
  name   = "ecs-rds-param-group"
  family = "mysql8.0"

  parameter {
    name  = "time_zone"
    value = "Asia/Tokyo"
  }

  parameter {
    name  = "character_set_client"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_connection"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_database"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_results"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }
}

resource "aws_db_instance" "EcsRds" {
  identifier             = "ecs-rds"
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "8.0.20"
  instance_class         = var.mysql_instance_class
  name                   = var.mysql_name
  username               = var.mysql_username
  password               = var.mysql_password
  vpc_security_group_ids = [aws_security_group.EcsRdsSG.id]
  db_subnet_group_name   = aws_db_subnet_group.EcsRdsSubnetGroup.name
  parameter_group_name   = aws_db_parameter_group.EcsRdsParamGroup.name
  skip_final_snapshot    = true
}
