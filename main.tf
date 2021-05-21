terraform {
  required_version = ">= 0.13.6"

  backend "s3" {
    bucket = "nrikiji-ecs-terraform-example-tfstate"
    region = "ap-northeast-1"
    key    = "terraform.tfstate"
  }
}

provider "aws" {
  region = "ap-northeast-1"
}
