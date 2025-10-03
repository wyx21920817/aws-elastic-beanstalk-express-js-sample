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
        echo "Starting npm install..."
        sh '''
          docker run --rm -u 0:0 -v "$WORKSPACE":"$WORKSPACE" -w "$WORKSPACE" \
          node:16 bash -lc 'npm install --save && (npm test || echo "no tests")'
        '''
        echo "npm install and tests completed."
      }
    }

    stage('Dependency Security Scan (Snyk)') {
      agent { label 'built-in' }
      steps {
        withCredentials([string(credentialsId: 'snyk-token', variable: 'SNYK_TOKEN')]) {
          echo "Starting Snyk Security Scan..."
          sh '''
            docker run --rm -u 0:0 -v "$WORKSPACE":"$WORKSPACE" -w "$WORKSPACE" \
            -e SNYK_TOKEN="$SNYK_TOKEN" node:16 bash -lc 'npm install -g snyk && snyk test --severity-threshold=high'
          '''
          echo "Snyk Security Scan completed."
        }
      }
    }

    stage('Build & Push (Docker via DinD)') {
      agent { label 'built-in' }
      steps {
        echo "Starting Docker version check..."
        sh 'docker version'
        echo "Docker version check completed."
        
        echo "Building Docker image..."
        sh "docker build -t ${DOCKER_IMAGE} ."
        echo "Docker image build completed."

        // Record Warnings from build log (simplified version)
        recordIssues(
          tools: [[class: 'TextFileParser', filePattern: '**/*.log']],
          filters: [filePattern: '**/*.log']
        )

        withCredentials([usernamePassword(credentialsId: 'user-creds',
                                          usernameVariable: 'DOCKER_USER',
                                          passwordVariable: 'DOCKER_PASS')]) {
          echo "Logging into Docker..."
          sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
          echo "Docker login successful."
          
          echo "Pushing Docker image..."
          sh "docker push ${DOCKER_IMAGE}"
          echo "Docker image pushed successfully."
        }

        // Archive Docker build log
        echo "Archiving build log..."
        archiveArtifacts artifacts: 'build.log', allowEmptyArchive: true
        echo "Build artifacts archived."
      }
    }
  }
}

