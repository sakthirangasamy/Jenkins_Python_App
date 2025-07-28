provider "aws" {
  region = "ap-southeast-2"
}

resource "aws_key_pair" "deployer" {
  key_name   = "ec2-key-${formatdate("YYYYMMDD", timestamp())}"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_security_group" "app_sg" {
  name        = "flask-app-sg-${formatdate("YYYYMMDD", timestamp())}"
  description = "Allow HTTP and SSH traffic"

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "app_server" {
  ami           = "ami-0c55b159cbfafe1f0" # Ubuntu 20.04 LTS
  instance_type = "t2.micro"
  key_name      = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install -y docker.io
              systemctl start docker
              usermod -aG docker ubuntu
              docker pull sakthirangasamy/flask-docker-app
              docker run -d -p 8000:8000 sakthirangasamy/flask-docker-app
              EOF

  tags = {
    Name = "FlaskAppServer"
  }
}

output "app_url" {
  value = "http://${aws_instance.app_server.public_ip}:8000"
}

output "ssh_command" {
  value = "ssh -i ~/.ssh/id_rsa ubuntu@${aws_instance.app_server.public_ip}"
}