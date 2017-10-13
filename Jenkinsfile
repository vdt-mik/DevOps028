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
        sh 'aws ec2 create-security-group --group-name $SG_NAME --description "Demo Security Group" --output text'
        sh 'aws ec2 authorize-security-group-ingress --group-name $SG_NAME --protocol icmp --port -1 --cidr 0.0.0.0/0 --output text'
        sh 'aws ec2 authorize-security-group-ingress --group-name $SG_NAME --protocol tcp --port 22 --cidr 0.0.0.0/0 --output text'
        sh 'aws ec2 authorize-security-group-ingress --group-name $SG_NAME --protocol tcp --port 80 --cidr 0.0.0.0/0 --output text'
        sh 'aws ec2 describe-security-groups --filters "Name=group-name,Values=$SG_NAME" --output text'
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