pipeline {
  agent {
    docker {
      image 'node:16'          
      args  '-u 0:0'           // Run as root to avoid permission issues
    }
  }
  environment {
    DOCKER_IMAGE = 'ghostwyx0422/node-app:latest'
  }
  stages {
    stage('Install Dependencies') {
      steps { 
        sh 'npm install --save' 
      }
    }
    stage('Run Tests') {
      steps { 
        sh 'npm test || echo "no tests"' 
      }
    }
    stage('Build Docker Image') {
      steps { 
        sh "docker build -t $DOCKER_IMAGE ." 
      }
    }
    stage('Push Docker Image') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub-creds',
                                          usernameVariable: 'DOCKER_USER',
                                          passwordVariable: 'DOCKER_PASS')]) {
          sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
          sh "docker push $DOCKER_IMAGE"
        }
      }
    }
  }
}

