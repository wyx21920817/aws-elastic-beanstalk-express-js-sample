pipeline {
  agent none
  environment {
    DOCKER_HOST       = 'tcp://docker:2376'
    DOCKER_TLS_VERIFY = '1'
    DOCKER_CERT_PATH  = '/certs/client'
    DOCKER_IMAGE      = 'ghostwyx0422/node-app:latest'
    SHARED_WS         = '/tmp/ws'          // Located inside the Jenkins container
  }

  stages {
    stage('Install & Test (Node 16)') {
      agent { label 'built-in' }           // Run on the control node (Jenkins container)
      steps {
        sh '''
          rm -rf "$SHARED_WS" && mkdir -p "$SHARED_WS"
          cp -a "$WORKSPACE/." "$SHARED_WS/"

          # Run npm using the node:16 container (the container runs on DinD)
          docker run --rm -u 0:0 \
            -v "$SHARED_WS":"$SHARED_WS" -w "$SHARED_WS" \
            node:16 bash -lc "npm ci || npm install --save; npm test || echo no tests"
        '''
      }
    }

    stage('Build & Push (Docker via DinD)') {
      agent { label 'built-in' }
      steps {
        sh '''
          docker version
          docker build -t "$DOCKER_IMAGE" "$SHARED_WS"
          echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
          docker push "$DOCKER_IMAGE"
        '''
      }
    }
  }
  post {
    always { sh 'rm -rf "$SHARED_WS" || true' }
  }
}

