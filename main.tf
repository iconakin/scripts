provider "aws" {
    profile = "default"
    region = "us-east-1"
}


resource "aws_vpc" "TerraProd-VPC" {
  cidr_block = "10.0.0.0/16"

 tags = {
    Name = "TerraProd-VPC"
  }
}

resource "aws_internet_gateway" "TerraProd-IGW" {
  vpc_id = aws_vpc.TerraProd-VPC.id

  tags = {
    Name = "TerraProd-IGW"
  }
}

resource "aws_route_table" "TerraProd-RT" {
  vpc_id = aws_vpc.TerraProd-VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.TerraProd-IGW.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id             = aws_internet_gateway.TerraProd-IGW.id
  }

  tags = {
    Name = "TerraProd-RT-Public"
  }
}

resource "aws_subnet" "TerraProd-subnet1" {
  vpc_id     = aws_vpc.TerraProd-VPC.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "TerraProd-Pub-Prod"
  }
}

resource "aws_subnet" "TerraProd-subet2" {
  vpc_id     = aws_vpc.TerraProd-VPC.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "TerraProd-Priv-Dev"
  }
}

resource "aws_route_table_association" "TerraProd" {
  # gateway_id     = aws_internet_gateway.TerraProd-IGW.id
  # route_table_id = aws_route_table.TerraProd-RT.id
# }

# resource "aws_route_table_association" "TerraProd" {
  subnet_id      = aws_subnet.TerraProd-subnet1.id
  route_table_id = aws_route_table.TerraProd-RT.id
}


resource "aws_security_group" "TerraProd-SG" {
  name        = "TerraProd-SG"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.TerraProd-VPC.id

  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["162.208.166.234/32"]
  }

  tags = {
    Name = "TerraProd-SG"
  }
}

resource "aws_network_interface" "TerraProd-IF" {
  subnet_id       = aws_subnet.TerraProd-subnet1.id
  private_ips     = ["10.0.0.50"]
  security_groups = [aws_security_group.TerraProd-SG.id]

  # attachment {
  #   instance     = aws_instance.TerraProdWebServer.id
  #   device_index = 1
  # }
}

resource "aws_eip" "one" {
  vpc                       = true
  network_interface         = aws_network_interface.TerraProd-IF.id
  associate_with_private_ip = "10.0.0.50"
  depends_on = [aws_internet_gateway.TerraProd-IGW]
}

resource "aws_instance" "TerraProdWebServer" {
  ami               = "ami-0bcc094591f354be2"
  instance_type     = "t2.micro"
  availability_zone = "us-east-1a"
  key_name          = "ForManjaro-KP"

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.TerraProd-IF.id
  }
  
  user_data = <<-EOF
              #!/usr/bin/bash
              sudo apt update -y
              sudo apt install apache2 -y
              sudo systemctl start apache2
              sudo bash -c "echo your very first web server > /var/www/html/index.html"
              EOF
  tags = {
    Name = "TerraProdWebServer"
  }
}