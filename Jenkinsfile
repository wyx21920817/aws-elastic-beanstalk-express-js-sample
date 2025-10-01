pipeline {
    agent any   // Run on any available agent; Jenkins container uses DinD for Docker builds
    environment {
        DOCKER_IMAGE = "ghostwyx0422/node-app:latest"   // Replace with your Docker Hub repo
    }
    stages {
        stage('Install Dependencies') {
            steps {
                sh 'npm install'   // Install project dependencies
            }
        }

        stage('Run Tests') {
            steps {
                sh 'npm test'   // Run unit tests
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t $DOCKER_IMAGE ."
                }
            }
        }

        stage('Security Scan') {
            steps {
                script {
                    // Example with Snyk CLI (must be installed in Jenkins container or node)
                    sh 'snyk test || exit 1'
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                        sh "docker push $DOCKER_IMAGE"
                    }
                }
            }
        }
    }
}

