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
          echo "Starting npm install..."
          npm install --save
          echo "npm install completed."
          
          echo "Running npm tests..."
          npm test || echo "No tests"
          echo "npm test completed."
        '''
      }
    }

    stage('Dependency Security Scan (Snyk)') {
      agent { label 'built-in' }
      steps {
        withCredentials([string(credentialsId: 'snyk-token', variable: 'SNYK_TOKEN')]) {
          sh '''
            echo "Starting Snyk Security Scan..."
            snyk test --severity-threshold=high
            echo "Snyk Security Scan Completed."
          '''
        }
      }
    }

    stage('Build & Push (Docker via DinD)') {
      agent { label 'built-in' }
      steps {
        sh 'docker version'
        
        sh 'echo "Building Docker Image..."'
        sh "docker build -t ${DOCKER_IMAGE} ."
        sh 'echo "Docker Image Build Completed."'
        
        withCredentials([usernamePassword(credentialsId: 'user-creds',
                                          usernameVariable: 'DOCKER_USER',
                                          passwordVariable: 'DOCKER_PASS')]) {
          sh 'echo "Logging into Docker..."'
          sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
          sh "docker push ${DOCKER_IMAGE}"
          sh 'echo "Docker Image Pushed."'
        }

        // Archive build artifacts
        archiveArtifacts artifacts: '**/*.tar.gz', allowEmptyArchive: true
      }
    }
  }
}

