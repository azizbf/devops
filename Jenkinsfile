pipeline {
    agent any

    stages {

        stage('Checkout SCM') {
            steps {
                checkout scm
            }
        }

        stage('Clean') {
            steps {
                sh 'bash mvnw clean'
            }
        }

        stage('Compile') {
            steps {
                sh 'bash mvnw compile'
            }
        }

        stage('SonarQube Scan') {
            steps {
                withSonarQubeEnv('sq1') {
                    sh 'bash mvnw sonar:sonar'
                }
            }
        }

        stage('Package JAR') {
            steps {
                sh 'bash mvnw package'
            }
        }
    }

    post {
        success {
            echo 'Pipeline terminé avec succès ! ✅'
        }
        failure {
            echo 'Pipeline échoué ❌'
        }
    }
}
