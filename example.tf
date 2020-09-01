terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = var.region
}

resource "aws_instance" "mastermnd-tf" {
  ami           = "ami-0873b46c45c11058d"
  instance_type = "t2.micro"

  tags = {
    Name = "mastermnd-terraF"
  }
}


resource "aws_instance" "mastermnd-terF" {
  ami           = "ami-0873b46c45c11058d"
  instance_type = "t2.micro"

  tags = {
    Name = "mastermnd-terraF1"
  }
}
