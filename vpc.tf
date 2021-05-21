
# VPC
resource "aws_vpc" "ecs_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "ECS-EXAMPLE"
  }
}


# パブリックサブネット(ALB、ECS、RDS)
# ・ECS、RDSはプライベートが良いがNATが高いのでパブリックに
# ・ECS、RDSへは外からアクセスできないようにSGで制御
resource "aws_subnet" "public_subnet_1a" {
  vpc_id            = aws_vpc.ecs_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-northeast-1a"
  tags = {
    Name = "ecs-example-public-1a"
  }
}

resource "aws_subnet" "public_subnet_1c" {
  vpc_id            = aws_vpc.ecs_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-northeast-1c"
  tags = {
    Name = "ecs-example-public-1c"
  }
}

# インターネットゲートウェイ
resource "aws_internet_gateway" "main-igw" {
  vpc_id = aws_vpc.ecs_vpc.id

  tags = {
    Name = "ECS-IGW"
  }
}

# ルーティング
resource "aws_route_table" "PublicRouteTable" {
  vpc_id = aws_vpc.ecs_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main-igw.id
  }

  tags = {
    Name = "ECS-Public-Routetable"
  }
}

resource "aws_route_table_association" "route_Publicsubnet_1a" {
  subnet_id      = aws_subnet.public_subnet_1a.id
  route_table_id = aws_route_table.PublicRouteTable.id
}

resource "aws_route_table_association" "route_Publicsubnet_1c" {
  subnet_id      = aws_subnet.public_subnet_1c.id
  route_table_id = aws_route_table.PublicRouteTable.id
}
