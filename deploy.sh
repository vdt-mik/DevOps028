#!/bin/bash
#SG
aws ec2 create-security-group --group-name $SG_NAME --description "Demo Security Group" --output text
#aws ec2 authorize-security-group-ingress --group-name $SG_NAME --protocol icmp --port -1 --cidr 0.0.0.0/0 --output text
aws ec2 authorize-security-group-ingress --group-name $SG_NAME --protocol tcp --port 22 --cidr 0.0.0.0/0 --output text
aws ec2 authorize-security-group-ingress --group-name $SG_NAME --protocol tcp --port 80 --cidr 0.0.0.0/0 --output text
aws ec2 describe-security-groups --filters "Name=group-name,Values=$SG_NAME" --output text  
ZONE=$(aws ec2 describe-availability-zones --query \'AvailabilityZones[0].ZoneName\' --profile $MY_PROFILE --output text)
aws elb create-load-balancer --load-balancer-name $ELB_NAME --listeners "Protocol=HTTP,LoadBalancerPort=80,InstanceProtocol=HTTP,InstancePort=80" --availability-zones $ZONE --output text
aws elb configure-health-check --load-balancer-name $ELB_NAME --health-check "Target=http:80/index.html,Interval=15,Timeout=30,UnhealthyThreshold=2,HealthyThreshold=2" --output text
aws elb describe-load-balancers --load-balancer-names $ELB_NAME --output text
lb_name=$(aws elb describe-load-balancers --load-balancer-names $ELB_NAME --query 'LoadBalancerDescriptions[].DNSName' --output text
dig +short $lb_name