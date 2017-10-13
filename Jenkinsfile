pipeline {
  agent any
  tools {
        maven 'maven'
        jdk 'jdk8'
    }
  
  environment {
    MAJOR_VERSION = 2
  }


  stages {
    stage('test') {
      agent any

      steps {
        sh 'mvn clean test'
      }
    }
    stage('build') {
      agent any

      steps {
        sh 'mvn package'
      }
    }
    stage('safe') {
      agent any

      steps {
        sh 'tar -czf liquibase.tar.gz liquibase'
        sh 'aws s3 cp target/Samsara-*.jar s3://mik-bucket/'
        sh 'aws s3 cp liquibase.tar.gz s3://mik-bucket/'
      }    
    }
    stage('create_ec2-instance') {
      agent any

      steps {
        sh 'aws ec2 create-security-group --group-name $SG_NAME --description "Demo Security Group" --profile $MY_PROFILE --output text'
        sh 'aws ec2 authorize-security-group-ingress --group-name $SG_NAME --protocol icmp --port -1 --cidr 0.0.0.0/0 --profile $MY_PROFILE --output text'
        sh 'aws ec2 authorize-security-group-ingress --group-name $SG_NAME --protocol tcp --port 22 --cidr 0.0.0.0/0 --profile $MY_PROFILE --output text'
        sh 'aws ec2 authorize-security-group-ingress --group-name $SG_NAME --protocol tcp --port 80 --cidr 0.0.0.0/0 --profile $MY_PROFILE --output text'
        sh 'aws ec2 describe-security-groups --filters "Name=group-name,Values=$SG_NAME" --profile $MY_PROFILE --output text'
        ZONE = sh 'aws ec2 describe-availability-zones --query 'AvailabilityZones[0].ZoneName' --profile $MY_PROFILE --output text'
        sh 'echo $ZONE'
        sh 'aws elb create-load-balancer --load-balancer-name $ELB_NAME --listeners "Protocol=HTTP,LoadBalancerPort=80,InstanceProtocol=HTTP,InstancePort=80" --availability-zones $ZONE --profile $MY_PROFILE --output text'
        sh 'aws elb configure-health-check --load-balancer-name $ELB_NAME --health-check "Target=http:80/index.html,Interval=15,Timeout=30,UnhealthyThreshold=2,HealthyThreshold=2" --profile $MY_PROFILE --output text'
        sh 'aws elb describe-load-balancers --load-balancer-names $ELB_NAME --profile $MY_PROFILE --output text'
        lb_name = sh 'aws elb describe-load-balancers --load-balancer-names $ELB_NAME --query 'LoadBalancerDescriptions[].DNSName' --profile $MY_PROFILE --output text)'
        sh 'dig +short $lb_name'
      }    
    }
    stage('create_rds-instance') {
      agent any

      steps {
        sh 'echo $NAME_PROJECT'
      }    
    }
  }
}