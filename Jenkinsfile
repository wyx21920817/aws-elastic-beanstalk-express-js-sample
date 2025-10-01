pipeline {
    agent {
        docker {
            image 'node:16'   // Use Node.js 16 as build environment
        }
    }
    environment {
        // Replace with your Docker Hub repo
        DOCKER_IMAGE = "ghostwyx0422/node-app:latest"
    }
    stages {
        stage('Install Dependencies') {
            steps {
                sh 'npm install --save'   // Install project dependencies
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

        stage('Push Docker Image') {
            steps {
                script {
                    // Use stored Docker Hub credentials (dockerhub-creds)
                    withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                        sh "docker push $DOCKER_IMAGE"
                    }
                }
            }
        }
    }
}
