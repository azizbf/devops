pipeline {
    agent any

    stages {
        stage('Build') {
            steps {
                sh './mvnw clean compile'
            }
        }

        stage('SonarQube Scan') {
            steps {
                withSonarQubeEnv('sq1') {
                    sh './mvnw sonar:sonar'
                }
            }
        }
    }
}
