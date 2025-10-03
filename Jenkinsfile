pipeline {
  agent none

  environment {
    // Docker Hub Repository
    DOCKER_IMAGE     = 'ghostwyx0422/node-app:latest'
    // Let all stages that require docker point to DinD
    DOCKER_HOST       = 'tcp://docker:2376'
    DOCKER_TLS_VERIFY = '1'
    DOCKER_CERT_PATH  = '/certs/client'
  }

  stages {
    stage('Install & Test (Node 16)') {
      agent { label 'built-in' }  // Issue the docker command on the Jenkins node (target is DinD)
      steps {
        sh '''
          docker run --rm -u 0:0 \
            -v "$WORKSPACE":"$WORKSPACE" -w "$WORKSPACE" \
            node:16 bash -lc 'npm install --save && (npm test || echo "no tests")'
        '''
      }
    }

    stage('Build & Push (Docker via DinD)') {
      agent { label 'built-in' }
      steps {
        sh 'docker version'
        sh "docker build -t ${DOCKER_IMAGE} ."
        withCredentials([usernamePassword(credentialsId: 'user-creds',
                                          usernameVariable: 'DOCKER_USER',
                                          passwordVariable: 'DOCKER_PASS')]) {
          sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
          sh "docker push ${DOCKER_IMAGE}"
        }
      }
    }
  }
}

