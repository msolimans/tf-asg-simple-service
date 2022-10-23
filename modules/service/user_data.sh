#!/bin/bash
sudo yum update -y
sudo amazon-linux-extras install nginx1 -y 
sudo systemctl enable nginx
sudo systemctl start nginx

sudo aws s3 cp s3://${bucket}/ /usr/share/nginx/html/ --recursive --region us-east-1
sudo curl http://169.254.169.254/latest/meta-data/hostname >> /usr/share/nginx/html/index.html