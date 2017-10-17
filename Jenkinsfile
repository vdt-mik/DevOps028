pipeline {
  agent any
  tools {
        maven 'maven'
        jdk 'jdk8'
    }

  stages {
    stage('Checkout') {
            steps {git url: 'https://github.com/vdt-mik/DevOps028'}
        }
    stage('Test & Build') {
      steps {
        sh 'mvn clean test'
        sh 'mvn clean package'
      }
      post {
        success {
          archiveArtifacts artifacts: 'target/*.jar', onlyIfSuccessful: true
          sh 'tar -czf liquibase.tar.gz liquibase'
          sh 'aws s3 cp target/Samsara-*.jar s3://mik-bucket/'
          sh 'aws s3 cp liquibase.tar.gz s3://mik-bucket/'
        }
      }
    }
    stage('Deploy RDS') {
      steps {
        sh 'chmod +x aws/rds.sh && ./aws/rds.sh'
      }
    }
    stage('Deploy ASG') {
      steps {
        sh 'chmod +x aws/asg.sh && ./aws/asg.sh'
      }
    }
  }
}