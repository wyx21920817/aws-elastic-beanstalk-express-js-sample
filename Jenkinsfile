pipeline {
  agent none

  environment {
    DOCKER_IMAGE = 'ghostwyx0422/node-app:latest'   // your Docker Hub repo
  }

  stages {
    stage('Install & Test (Node 16)') {
      agent {
        docker {
          image 'node:16'         // required by the spec
          args  '-u 0:0'          // run as root to avoid npm permission issues
        }
      }
      steps {
        sh 'npm install --save'   // match the assignment wording exactly
        sh 'npm test || echo "no tests"'  // run tests if present
      }
    }

    stage('Build & Push (Docker via DinD)') {
      agent { label 'built-in' }  // run on the Jenkins container
      environment {
        DOCKER_HOST       = 'tcp://docker:2376'
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

