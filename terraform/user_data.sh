#!/bin/bash
apt update -y
apt install -y docker.io
systemctl start docker
usermod -aG docker ubuntu

# Pull & run your image
docker pull priyadharshiniro7/flask-docker-app1
docker run -d -p 8000:8000 priyadharshiniro7/flask-docker-app1
