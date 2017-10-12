pipeline {
  agent any
  tools {
        maven 'maven'
        jdk 'jdk8'
    }
  
  environment {
    MAJOR_VERSION = 1
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
        sh 'pwd'
      }    
  }
}