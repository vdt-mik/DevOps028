#!/bin/bash
# =====================================
# Update system & install awscli
#
sudo yum install epel-release -y && sudo yum update -y && sudo yum install nano curl wget vim git python-pip -y
sudo pip install --upgrade pip && sudo pip install awscli
#======================================
# Install JDK
#
mkdir -p ~/source && cd ~/source && wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" \
"http://download.oracle.com/otn-pub/java/jdk/8u144-b01/090f390dda5b47b9b721c7dfaa008135/jdk-8u144-linux-x64.rpm"
sudo yum localinstall jdk-8u*-linux-x64.rpm -y
#======================================
# Create user
#
sudo adduser builder
#======================================
# Install Maven
#
sudo su builder -c "cd ~/ && wget http://mirror.linux-ia64.org/apache/maven/maven-3/3.5.0/binaries/apache-maven-3.5.0-bin.tar.gz && tar xzf apache-maven-*bin.tar.gz"
#======================================
# Clone & Build
#
sudo su builder -c "mkdir -p ~/build && cd ~/build/ && git clone https://github.com/vdt-mik/DevOps028.git && cd DevOps028 && ~/apache-maven-3.5.0/bin/mvn package"
sudo su builder -c "cd ~/build/DevOps028/ && tar -czf liquibase.tar.gz liquibase"
#=====================================
# Put to aws s3
#
sudo su builder -c "mkdir -p ~/.aws && cat <<EOF> ~/.aws/config
[default]
aws_access_key_id=${AWS_ACCESS_KEY_ID}
aws_secret_access_key=${AWS_SECRET_ACCESS_KEY}
region=${AWS_DEFAULT_REGION}
output=${AWS_DEFAULT_OUTPUT}
EOF"
cd ~/source && sudo cp jdk-8u144-linux-x64.rpm /home/builder/build/DevOps028/
sudo su builder -c "aws s3 cp ~/build/DevOps028/target/Samsara-1.3.5.RELEASE.jar s3://mik-repo/ && aws s3 cp ~/build/DevOps028/liquibase.tar.gz s3://mik-repo/"
sudo su builder -c "aws s3 cp ~/build/DevOps028/jdk-8u144-linux-x64.rpm s3://mik-repo/"