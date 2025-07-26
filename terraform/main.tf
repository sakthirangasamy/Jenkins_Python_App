provider "aws" {
  region = "ap-southeast-2"
}

# ✅ 1. Key Pair (Correct file path using double backslashes or forward slashes)
resource "aws_key_pair" "deployer" {
  key_name   = "ec2-key"
  public_key = file("C:/Users/admin/.ssh/id_rsa.pub")  # or "C:\\Users\\admin\\.ssh\\id_rsa.pub"
}

# ✅ 2. Security Group for port 8000 + SSH
resource "aws_security_group" "allow_http" {
  name        = "allow_http"
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

# ✅ 3. EC2 Instance using proper key and security group reference
resource "aws_instance" "docker_app" {
  ami           = "ami-010876b9ddd38475e" # This is in ap-south-1; use correct AMI for ap-southeast-2
  instance_type = "t2.micro"

  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.allow_http.id]

  user_data = file("${path.module}/user_data.sh")

  tags = {
    Name = "DockerAppAutoDeploy"
  }
}

# ✅ 4. Output the public IP
output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.docker_app.public_ip
}
