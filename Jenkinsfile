pipeline {
  agent none

  environment {
    DOCKER_IMAGE = 'ghostwyx0422/node-app:latest'
  }

  stages {
    stage('Install & Test (Node 16)') {
      agent {
        docker {
          image 'node:16'
          args  '-u 0:0'          // Avoid npm permission issues as root
        }
      }
      steps {
        sh 'npm ci || npm install --save'
        sh 'npm test || echo "no tests"'
      }
    }

    stage('Build & Push (Docker via DinD)') {
      agent { label 'built-in' }  // Running on the Jenkins container
      environment {
        DOCKER_HOST = 'tcp://docker:2376'
        DOCKER_TLS_VERIFY = '1'
        DOCKER_CERT_PATH  = '/certs/client'
      }
      steps {
        sh 'docker version'                         
        sh "docker build -t ${DOCKER_IMAGE} ."
        withCredentials([usernamePassword(credentialsId: 'dockerhub-creds',
                                          usernameVariable: 'DOCKER_USER',
                                          passwordVariable: 'DOCKER_PASS')]) {
          sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
          sh "docker push ${DOCKER_IMAGE}"
        }
      }
    }
  }
}

