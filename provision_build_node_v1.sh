#!/bin/bash
# =====================================
# Update system & install awscli
#
yum install epel-release -y && yum update -y && yum install nano curl wget vim git python-pip -y
pip install --upgrade pip && pip install awscli
#======================================
# Install JDK
#
cd /usr/local/src/ && wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" \
"http://download.oracle.com/otn-pub/java/jdk/8u144-b01/090f390dda5b47b9b721c7dfaa008135/jdk-8u144-linux-x64.rpm"
mkdir -p /tmp/source && cp jdk-8u144-linux-x64.rpm /tmp/source
yum localinstall jdk-8u*-linux-x64.rpm -y
#======================================
# Install Maven
#
cd /opt
wget http://mirror.linux-ia64.org/apache/maven/maven-3/3.5.0/binaries/apache-maven-3.5.0-bin.tar.gz
tar xzf apache-maven-*bin.tar.gz
ln -s apache-maven-3.5.0 maven
cat <<EOF> /etc/profile.d/maven.sh
export M2_HOME=/opt/maven
export PATH=${M2_HOME}/bin:${PATH}
EOF
#======================================
# Clone & Build
#
mkdir -p /opt/build && cd /opt/build/ && git clone https://github.com/vdt-mik/DevOps028.git && cd DevOps028
/opt/apache-maven-3.5.0/bin/mvn package
tar -czvf liquibase.tar.gz liquibase
#=====================================
# Put to aws s3
#
mkdir -p ~/.aws
cat <<EOF> ~/.aws/config
[default]
aws_access_key_id=${AWS_ACCESS_KEY_ID}
aws_secret_access_key=${AWS_SECRET_ACCESS_KEY}
region=${AWS_DEFAULT_REGION}
output=${AWS_DEFAULT_OUTPUT}
EOF
aws s3 cp /opt/build/DevOps028/target/Samsara-1.3.5.RELEASE.jar s3://mik-repo/
aws s3 cp /opt/build/DevOps028/liquibase.tar.gz s3://mik-repo/
aws s3 cp /tmp/source/ s3://mik-repo/ --recursive