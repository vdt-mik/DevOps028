#!/bin/bash
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
--key-name ec2-key --image-id ami-c7ee5ca8 --security-groups samsara-sg --instance-type t2.micro --user-data file://aws/user-data.sh --instance-monitoring Enabled=true --iam-instance-profile EC2
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