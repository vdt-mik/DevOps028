#!/bin/bash
sudo yum update -y && sudo yum install nano vim git -y
sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
#======================================
# Install JDK
#
cd /tmp && wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" \
"http://download.oracle.com/otn-pub/java/jdk/8u144-b01/090f390dda5b47b9b721c7dfaa008135/jdk-8u144-linux-x64.rpm" && sudo yum localinstall jdk-8u*-linux-x64.rpm -y
#======================================
# Create user
#
sudo adduser app
sudo su app
#======================================