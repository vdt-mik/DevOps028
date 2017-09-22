#!/bin/bash
# =====================================
sudo yum install epel-release -y && sudo yum update -y && sudo yum install nano curl wget vim git python-pip -y
sudo pip install --upgrade pip && sudo pip install awscli
# =====================================
# Create user
sudo adduser builder
#
# =====================================
# Get artifact from aws s3
#
mkdir -p ~/.aws
cat <<EOF> ~/.aws/config
[default]
aws_access_key_id=${AWS_ACCESS_KEY_ID}
aws_secret_access_key=${AWS_SECRET_ACCESS_KEY}
region=${AWS_DEFAULT_REGION}
output=${AWS_DEFAULT_OUTPUT}
EOF
aws rds create-db-instance --db-instance-identifier ${DB_INST_NAME} \
--allocated-storage 5 --db-instance-class db.t2.micro --engine postgres \
--master-username ${DB_USER} --master-user-password ${DB_PASS} --storage-type gp2 --backup-retention-period 0 --db-name ${DB_NAME}
TARGET_STATUS=available
STATUS=unknown
while [[ "$STATUS" != "$TARGET_STATUS" ]]; do
        STATUS=`aws rds describe-db-instances --db-instance-identifier ${DB_INST_NAME} | grep DBInstanceStatus | awk '{print$2}' | cut -d'"' -f2`
        echo "Database $INSTANCE : $STATUS ... "
        sleep 15
done
EXISTING_DB_INSTANCE_INFO=`aws rds describe-db-instances --db-instance-identifier ${DB_INST_NAME} --query 'DBInstances[*].[DBInstanceIdentifier,Endpoint.Address,Endpoint.Port]' --output text`
export DB_HOST=`echo ${EXISTING_DB_INSTANCE_INFO} | awk '{print $2}'`
export DB_PORT=`echo ${EXISTING_DB_INSTANCE_INFO} | awk '{print $3}'`
cd /tmp && aws s3 cp s3://mik-repo/jdk-8u144-linux-x64.rpm ./ && yum localinstall jdk-8u*-linux-x64.rpm -y
mkdir -p /opt/app && cd /opt/app
aws s3 cp s3://mik-repo/liquibase.tar.gz /opt/app
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
mkdir -p bin && cd bin && wget https://github.com/liquibase/liquibase/releases/download/liquibase-parent-3.5.3/liquibase-3.5.3-bin.tar.gz \
&& tar xzf liquibase-3.5.3-bin.tar.gz

./liquibase --classpath=../lib/postgresql-42.1.4.jar --changeLogFile=../changelogs/changelog-main.xml --defaultsFile=../liquibase.properties update
aws s3 cp s3://mik-repo/Samsara-1.3.5.RELEASE.jar /opt/app && cd /opt/app 
java -jar Samsara-1.3.5.RELEASE.jar &
