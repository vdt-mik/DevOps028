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

        sh 'chmod +x deploy.sh && ./deploy.sh'
      }      r
    }
    stage('create_rds-instance') {
      agent any

      steps {
        sh 'echo $NAME_PROJECT'
      }    
    }
  }
}