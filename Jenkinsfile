pipeline {
    agent any
    
    environment {
        DOCKER_IMAGE = 'sathya10dock/my-python-app'
        DOCKER_CRED_ID = 'dockerhub-token'
        SONAR_SERVER = 'sonarserver'
    }
    
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/Satz007-user/CI-CD-Pipeline-with-SonarQube-Docker.git'
            }
        }
        
        stage('Build & Test') {
            steps {
                sh '''
                    python3 -m venv venv
                    . venv/bin/activate
                    pip install flask pytest
                    pytest test_app.py
                '''
            }
        }
        
        stage('SonarQube Analysis') {
            steps {
                script {
                    withSonarQubeEnv("${SONAR_SERVER}") {
                        sh 'sonar-scanner'
                    }
                }
            }
        }
        
        stage('Quality Gate') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    script {
                        def qg = waitForQualityGate()
                        if (qg.status != 'OK') {
                            error "Pipeline failed: Quality Gate status is ${qg.status}"
                        }
                    }
                }
            }
        }
        
        stage('Docker Build & Push') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', "${DOCKER_CRED_ID}") {
                        def appImage = docker.build("${DOCKER_IMAGE}:${BUILD_NUMBER}")
                        appImage.push()
                        appImage.push('latest')
                    }
                }
            }
        }
        
        stage('Deploy Locally') {
            steps {
                sh """
                    docker stop my-running-app || true
                    docker rm my-running-app || true
                    docker run -d --name my-running-app -p 5000:5000 ${DOCKER_IMAGE}:latest
                """
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
    }
}
