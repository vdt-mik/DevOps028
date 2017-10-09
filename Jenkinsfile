pipeline {
  agent none

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