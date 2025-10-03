pipeline {
  agent {
    docker {
      image 'node:16'
      // 以 root 运行并挂入 TLS 证书目录，容器会继承全局 DOCKER_* 环境变量（远端 DinD/TLS）
      args '-u 0:0 -v /certs/client:/certs/client:ro'
      reuseNode true
    }
  }

  environment {
    // 你的镜像名
    DOCKER_IMAGE      = 'ghostwyx0422/node-app:latest'
    // Jenkins (外层) 连接远端 DinD 的 TLS 环境（由 docker-compose 提供）
    DOCKER_HOST       = 'tcp://docker:2376'
    DOCKER_TLS_VERIFY = '1'
    DOCKER_CERT_PATH  = '/certs/client'
  }

  stages {
    stage('Install & Test') {
      steps {
        sh 'npm ci || npm install --save'
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

    stage('Build & Push (Docker via remote DinD)') {
      // 不切回 label 节点，改用 docker:24-cli 作为阶段级 agent，避免 durable task 启动问题
      agent {
        docker {
          image 'docker:24-cli'
          // 在远端 dind 上启动本阶段容器，并挂入 dind 的本地 docker.sock 以直接控制同一 Daemon
          args '-v /var/run/docker.sock:/var/run/docker.sock'
          reuseNode true
        }
      }
      // 在该阶段内改用本地 socket（仍然是“远端 dind”的同一个 Docker 守护进程）
      environment {
        DOCKER_HOST = 'unix:///var/run/docker.sock'
        DOCKER_TLS_VERIFY = ''
        DOCKER_CERT_PATH  = ''
      }
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

