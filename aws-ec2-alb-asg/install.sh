#! /bin/bash
sudo yum update
sudo amazon-linux-extras enable nginx
sudo amazon-linux-extras install nginx1 -y
sudo systemctl start nginx
sudo systemctl enable nginx
