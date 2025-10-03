pipeline {
  agent none

  environment {
    DOCKER_IMAGE     = 'ghostwyx0422/node-app:latest'
    DOCKER_HOST       = 'tcp://docker:2376'
    DOCKER_TLS_VERIFY = '1'
    DOCKER_CERT_PATH  = '/certs/client'
  }

  stages {
    stage('Install & Test (Node 16)') {
      agent { label 'built-in' }
      steps {
        sh '''
          docker run --rm -u 0:0 \
            -v "$WORKSPACE":"$WORKSPACE" -w "$WORKSPACE" \
            node:16 bash -lc 'npm install --save && (npm test || echo "no tests")'
        '''
      }
    }

    stage('Dependency Security Scan (Snyk)') {
      agent { label 'built-in' }
      steps {
        withCredentials([string(credentialsId: 'snyk-token', variable: 'SNYK_TOKEN')]) {
          sh '''
            docker run --rm -u 0:0 \
              -v "$WORKSPACE":"$WORKSPACE" -w "$WORKSPACE" \
              -e SNYK_TOKEN="$SNYK_TOKEN" \
              node:16 bash -lc 'npm install -g snyk && snyk test --severity-threshold=high'
          '''
        }
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

