pipeline {
  agent any
  tools {
        maven 'Maven 3.5.0'
    }
  
  environment {
    MAJOR_VERSION = 1
  }


  stages {
    stage('build') {
      agent any

      steps {
        sh 'mvn package'
      }
    }
  }
}