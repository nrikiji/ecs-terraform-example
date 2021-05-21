
# Backend
resource "aws_ecr_repository" "EcsEcrBackend" {
  name                 = "ecs-example-backend"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

# Frontend
resource "aws_ecr_repository" "EcsEcrFrontend" {
  name                 = "ecs-example-frontend"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
