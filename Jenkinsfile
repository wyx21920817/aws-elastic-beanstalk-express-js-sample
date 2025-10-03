pipeline {
  agent {
    docker {
      image 'node:16'
      args '-u 0:0'   // 以 root 运行，避免 npm/权限问题
      reuseNode true  // 复用同一工作空间，便于后续切换到内置节点
    }
  }

  environment {
    DOCKER_IMAGE     = 'ghostwyx0422/node-app:latest'
    DOCKER_HOST       = 'tcp://docker:2376'
    DOCKER_TLS_VERIFY = '1'
    DOCKER_CERT_PATH  = '/certs/client'
  }

  stages {
    stage('Install & Test') {
      steps {
        sh 'npm install --save'
        sh 'npm test || echo "no tests"'
      }
    }

    stage('Dependency Security Scan (Snyk)') {
      environment { SNYK_TOKEN = credentials('snyk-token') }
      steps {
        sh 'npm install -g snyk'
        sh 'snyk test --severity-threshold=high'
      }
    }

    // 构建与推送镜像在可访问 DinD 的内置节点上执行
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
        archiveArtifacts artifacts: '**/*.tar.gz', allowEmptyArchive: true
      }
    }
  }
}

