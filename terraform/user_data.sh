#!/bin/bash
# Update system and install Docker
apt update -y
apt install -y docker.io

# Start and enable Docker
systemctl start docker
systemctl enable docker

# Add ubuntu user to docker group
usermod -aG docker ubuntu

# Pull and run the Docker image
docker pull sakthirangasamy/flask-docker-app
docker run -d \
  -p 8000:8000 \
  -e FLASK_ENV=production \
  --restart unless-stopped \
  sakthirangasamy/flask-docker-app

# Verify container is running
docker ps