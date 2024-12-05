#!/bin/bash

sudo yum -y update

# Install and run docker
sudo yum install -y docker
sudo service docker start
sudo service docker status

# Install docker compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/bin/docker-compose
sudo chmod +x /usr/bin/docker-compose
echo "Installed Docker compose"

# Save the docker-compose.yml
echo "Saving docker compose.yml"
echo "
version: '3.7'
services:
  postgres:
    image: postgres:13
    ports:
      - '5432:5432'
    restart: always
    environment:
      POSTGRES_USER: 'airflow'
      POSTGRES_PASSWORD: 'airflow'
      POSTGRES_DB: 'airflow'
    logging:
      driver: 'json-file'
      options:
        max-size: '100m'
        max-file: '2'
" > /home/ec2-user/docker-compose.yml
echo "Saved docker compose"

# Run the docker-compose.yml
sudo docker-compose -f /home/ec2-user/docker-compose.yml up -d
