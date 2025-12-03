#!/bin/bash
yum update -y
yum install -y httpd
echo "Hello world ${instance_number}" > /var/www/html/index.html
systemctl enable httpd
systemctl start httpd
