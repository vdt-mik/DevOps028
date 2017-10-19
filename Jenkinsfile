pipeline {
  agent {label 'Slave'}
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
          sh 'aws s3 cp aws/user-data.sh s3://mik-bucket/'
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
    stage('Check APP') {
      steps {
        APP_URL = sh(
                script: "aws ssm get-parameters --names APP_URL --with-decryption --output text",
                returnStdout: true
        ).trim()
        try {
            new URL("$APP_UPR/login").getText()
            return true
        } catch (Exception e) {
            return false
        }
      } 
    }
  }
}