#!/bin/bash
#======================================
# Checking exist DB
#
aws rds delete-db-instance \
--db-instance-identifier $(aws ssm get-parameters --names DB_INST_NAME --with-decryption --output text | awk '{print $4}') \
--skip-final-snapshot 2>/dev/null

count=1
while [[ "$count" != "0" ]]; do
        count=`aws rds describe-db-instances --db-instance-identifier $(aws ssm get-parameters --names DB_INST_NAME --with-decryption --output text | awk '{print $4}') 2>/dev/null | wc -l`
        echo "Database : deleting ... "
        sleep 5
done
#======================================
# Create RDS instance
#
aws rds create-db-instance --db-instance-identifier $(aws ssm get-parameters --names DB_INST_NAME --with-decryption --output text | awk '{print $4}') \
--allocated-storage 5 --db-instance-class db.t2.micro --engine postgres \
--master-username $(aws ssm get-parameters --names DB_USER --with-decryption --output text | awk '{print $4}') \
--master-user-password $(aws ssm get-parameters --names DB_PASS --with-decryption --output text | awk '{print $4}') \
--storage-type gp2 --backup-retention-period 0 --db-name $(aws ssm get-parameters --names DB_NAME --with-decryption --output text | awk '{print $4}')
#======================================
# Checking create DB
#
TARGET_STATUS=available
STATUS=unknown
while [[ "$STATUS" != "$TARGET_STATUS" ]]; do
        STATUS=`aws rds describe-db-instances --db-instance-identifier $(aws ssm get-parameters --names DB_INST_NAME --with-decryption --output text | awk '{print $4}') | grep DBInstanceStatus | awk '{print$2}' | cut -d'"' -f2`
        echo "Database $INSTANCE : $STATUS ... "
        sleep 15
done
#======================================
# Set DB variables
#
EXISTING_DB_INSTANCE_INFO=`aws rds describe-db-instances --db-instance-identifier $(aws ssm get-parameters --names DB_INST_NAME --with-decryption --output text | awk '{print $4}') --query 'DBInstances[*].[DBInstanceIdentifier,Endpoint.Address,Endpoint.Port]' --output text`
aws ssm put-parameter --name "DB_HOST" --type "String" --value "$(echo ${EXISTING_DB_INSTANCE_INFO} | awk '{print $2}')" --overwrite
aws ssm put-parameter --name "DB_PORT" --type "String" --value "$(echo ${EXISTING_DB_INSTANCE_INFO} | awk '{print $3}')" --overwrite