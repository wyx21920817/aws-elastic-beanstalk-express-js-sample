pipeline {
    agent any
    environment {
        DOCKER_IMAGE = "ghostwyx0422/node-app:latest"
    }
    stages {
        stage('Install Dependencies') {
            agent { docker { image 'node:16'; reuseNode true } }
            steps {
                sh 'npm install --save'
            }
        }

        stage('Run Tests') {
            agent { docker { image 'node:16'; reuseNode true } }
            steps {
                sh 'npm test'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t $DOCKER_IMAGE ."
            }
        }

        stage('Security Scan') {
            agent { docker { image 'node:16'; reuseNode true } }
            steps {
                sh 'npx snyk test || exit 1'
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                    sh "docker push $DOCKER_IMAGE"
                }
            }
        }
    }
}

