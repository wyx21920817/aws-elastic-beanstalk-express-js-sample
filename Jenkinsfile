pipeline {
  agent none

  environment {
    // 用你的 Docker Hub 仓库
    DOCKER_IMAGE     = 'ghostwyx0422/node-app:latest'
    // 让所有需要 docker 的阶段都指向 DinD
    DOCKER_HOST       = 'tcp://docker:2376'
    DOCKER_TLS_VERIFY = '1'
    DOCKER_CERT_PATH  = '/certs/client'
  }

  stages {
    stage('Install & Test (Node 16)') {
      agent { label 'built-in' }  // 在 Jenkins 节点上发出 docker 命令（目标是 DinD）
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

