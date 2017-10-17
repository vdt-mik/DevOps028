#!/bin/bash
#======================================
# Create RDS instance
#
aws rds delete-db-instance \
--db-instance-identifier $(aws ssm get-parameters --names DB_INST_NAME --with-decryption --output text | awk '{print $4}') \
--skip-final-snapshot
# Wait deleted
count=1
while [[ "$count" != "0" ]]; do
        count=`aws rds describe-db-instances --db-instance-identifier $(aws ssm get-parameters --names DB_INST_NAME --with-decryption --output text | awk '{print $4}') 2>/dev/null | wc -l`
        echo "$count -> deleting ... "
        sleep 5
done

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
EXISTING_DB_INSTANCE_INFO=`aws rds describe-db-instances --db-instance-identifier 
$(aws ssm get-parameters --names DB_INST_NAME --with-decryption --output text | awk '{print $4}') --query 'DBInstances[*].[DBInstanceIdentifier,Endpoint.Address,Endpoint.Port]' --output text`
aws ssm put-parameter --name "DB_HOST" --type "String" --value "$(echo ${EXISTING_DB_INSTANCE_INFO} | awk '{print $2}')" --overwrite
aws ssm put-parameter --name "DB_PORT" --type "String" --value "$(echo ${EXISTING_DB_INSTANCE_INFO} | awk '{print $3}')" --overwrite

#delete ASG
aws autoscaling delete-auto-scaling-group --auto-scaling-group-name $(aws ssm get-parameters --names ASG_NAME --with-decryption --output text | awk '{print $4}') --force-delete 2>/dev/null
#Wait deleted
count=1
while [[ "$count" != "3" ]]; do
        count=`aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names $(aws ssm get-parameters --names ASG_NAME --with-decryption --output text | awk '{print $4}') 2>/dev/null | wc -l`
        echo "ASG : deleting ... "
        sleep 5
done
echo "ASG deleted ===============================>"
#delete LC
aws autoscaling delete-launch-configuration --launch-configuration-name $(aws ssm get-parameters --names LC_NAME --with-decryption --output text | awk '{print $4}') 2>/dev/null
#Wait deleted
count=1
while [[ "$count" != "3" ]]; do
        count=`aws autoscaling describe-launch-configurations --launch-configuration-names $(aws ssm get-parameters --names LC_NAME --with-decryption --output text | awk '{print $4}') 2>/dev/null | wc -l`
        echo "LC : deleting ... "
        sleep 5
done
echo "LC deleted ===============================>"
#create LC 
aws autoscaling create-launch-configuration --launch-configuration-name $(aws ssm get-parameters --names LC_NAME --with-decryption --output text | awk '{print $4}') \
--key-name ec2-key --image-id ami-c7ee5ca8 --security-groups samsara-sg --instance-type t2.micro --user-data s3://mik-bucket/user-data.sh --instance-monitoring Enabled=true
sleep 5
echo "LC created ===============================>"
#delete LB
aws elb delete-load-balancer --load-balancer-name $(aws ssm get-parameters --names LB_NAME --with-decryption --output text | awk '{print $4}') 2>/dev/null
#Wait deleted
count=1
while [[ "$count" != "0" ]]; do
        count=`aws elb describe-load-balancers --load-balancer-names $(aws ssm get-parameters --names LB_NAME --with-decryption --output text | awk '{print $4}') 2>/dev/null | wc -l`
        echo "LC : deleting ... "
        sleep 5
done
echo "LB deleted ===============================>"
#create LB
aws elb create-load-balancer --load-balancer-name $(aws ssm get-parameters --names LB_NAME --with-decryption --output text | awk '{print $4}') \
--listeners "Protocol=HTTP,LoadBalancerPort=80,InstanceProtocol=HTTP,InstancePort=9000" --subnets subnet-13828169 --security-groups sg-835e8ee9
aws elb configure-health-check --load-balancer-name $(aws ssm get-parameters --names LB_NAME --with-decryption --output text | awk '{print $4}') \
--health-check Target=HTTP:9000/png,Interval=5,UnhealthyThreshold=5,HealthyThreshold=2,Timeout=2
echo "LB created ===============================>"
#create ASG
aws autoscaling create-auto-scaling-group --auto-scaling-group-name $(aws ssm get-parameters --names ASG_NAME --with-decryption --output text | awk '{print $4}') \
--launch-configuration-name $(aws ssm get-parameters --names LC_NAME --with-decryption --output text | awk '{print $4}') --min-size 1 --max-size 3 --desired-capacity 2 \
--load-balancer-names $(aws ssm get-parameters --names LB_NAME --with-decryption --output text | awk '{print $4}') --health-check-type ELB --health-check-grace-period 300 --availability-zones eu-central-1b
echo "ASG created ===============================>"