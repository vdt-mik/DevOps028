#!/bin/bash
sudo yum update -y && sudo yum install nano vim git -y
sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
#======================================
# Set variables
#
function get_pr {
    aws ssm get-parameters --names $1 --with-decryption --output text | awk '{print $4}'
}

export AWS_DEFAULT_REGION=`get_pr "region"`
export AWS_SECRET_ACCESS_KEY=`get_pr "access_key"`
export AWS_ACCESS_KEY_ID=`get_pr "key_id"`
#======================================
# Create AWS config file
#
mkdir -p ~/.aws
cat <<EOF> ~/.aws/config
[default]
aws_access_key_id=$AWS_ACCESS_KEY_ID
aws_secret_access_key=$AWS_SECRET_ACCESS_KEY
region=$AWS_DEFAULT_REGION
output=json
EOF
#======================================
# Install JDK
#
cd /tmp && aws s3 cp s3://mik-repo/jdk-8u144-linux-x64.rpm ./ && sudo yum localinstall jdk-8u*-linux-x64.rpm -y
#======================================
# Create user
#
sudo adduser app
sudo su app
#======================================
# Create AWS config file
#
mkdir -p ~/.aws
cat <<EOF> ~/.aws/config
[default]
aws_access_key_id=$AWS_ACCESS_KEY_ID
aws_secret_access_key=$AWS_SECRET_ACCESS_KEY
region=$AWS_DEFAULT_REGION
output=json
EOF
#======================================
# Set DB variables
#
export DB_NAME=`get_pr "DB_NAME"`
export DB_USER=`get_pr "DB_USER"`
export DB_PASS=`get_pr "DB_PASS"`
export DB_HOST=`get_pr "DB_HOST"`
export DB_PORT=`get_pr "DB_PORT"`
export DB_INST_NAME=`get_pr "DB_INST_NAME"`
# Create APP folder & download liquibase project setting from repo and jdbc_driver
#
mkdir -p ~/app && cd ~/app
aws s3 cp s3://$(`get_pr "S3_BUCKET"`)/liquibase.tar.gz ~/app
tar xzf liquibase.tar.gz && cd liquibase
mkdir -p lib && cd lib && wget https://jdbc.postgresql.org/download/postgresql-42.1.4.jar
cd .. && cat <<EOF> liquibase.properties
driver: org.postgresql.Driver
url: jdbc:postgresql://$DB_HOST:$DB_PORT/$DB_NAME
username: $DB_USER
password: $DB_PASS
# specifies packages where entities are and database dialect, used for liquibase:diff command
referenceUrl=hibernate:spring:academy.softserve.aura.core.entity?dialect=org.hibernate.dialect.PostgreSQL9Dialect
EOF
#======================================
# Download binary file liquibase & run liqubase 
#
mkdir -p bin && cd bin && wget https://github.com/liquibase/liquibase/releases/download/liquibase-parent-3.5.3/liquibase-3.5.3-bin.tar.gz \
&& tar xzf liquibase-3.5.3-bin.tar.gz
./liquibase --classpath=../lib/postgresql-42.1.4.jar --changeLogFile=../changelogs/changelog-main.xml --defaultsFile=../liquibase.properties update
#======================================
# Download APP JAR file and run APP
#
aws s3 cp s3://$(`get_pr "S3_BUCKET"`)/Samsara-1.3.5.RELEASE.jar ~/app && cd ~/app 
java -jar Samsara-1.3.5.RELEASE.jar &