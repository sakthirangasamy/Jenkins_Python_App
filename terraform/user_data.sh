#!/bin/bash
apt update -y
apt install -y docker.io
systemctl start docker
usermod -aG docker ubuntu

# Pull & run your image
docker pull sakthirangasamy/flask-docker-app
docker run -d -p 8000:8000 sakthirangasamy/flask-docker-app
