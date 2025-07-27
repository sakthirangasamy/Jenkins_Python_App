provider "aws" {
  region = "ap-southeast-2"
}

resource "aws_key_pair" "deployer" {
  key_name   = "ec2-key"  # Or "ec2-key-new" if duplicate error persists
  public_key = file("C:/Users/admin/.ssh/id_rsa.pub")
}

resource "aws_security_group" "allow_http" {
  name        = "allow_http"  # Or "allow_http_new" if duplicate error persists
  description = "Allow HTTP (8000) and SSH"

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

resource "aws_instance" "docker_app" {
  ami           = "ami-04f5097681773b989"  # Use valid AMI for ap-southeast-2
  instance_type = "t2.micro"

  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.allow_http.id]

  user_data = file("${path.module}/user_data.sh")

  tags = {
    Name = "DockerAppAutoDeploy"
  }

  depends_on = [
    aws_key_pair.deployer,
    aws_security_group.allow_http
  ]
}

output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.docker_app.public_ip
}

output "ssh_connection_command" {
  value = "ssh -i ~/.ssh/id_rsa ec2-user@${aws_instance.docker_app.public_ip}"
}
