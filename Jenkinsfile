pipeline {
    agent any
    
    environment {
        DOCKER_IMAGE = 'sathya10dock/my-java-app'
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
                bat '''
                    if not exist target mkdir target
                    javac -d target App.java
                    java -cp target App
                '''
            }
        }
        
        stage('SonarQube Analysis') {
    steps {
        script {
            def scannerHome = tool 'sonar-scanner'
            withSonarQubeEnv("${SONAR_SERVER}") {
                bat "${scannerHome}/bin/sonar-scanner"
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
                bat """
                    docker stop my-running-app || exit 0
                    docker rm my-running-app || exit 0
                    docker run -d --name my-running-app ${DOCKER_IMAGE}:latest
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
