pipeline {
    agent any

    tools {
        // Ensure Maven is configured in Jenkins Global Tool Configuration with this name
        maven 'maven-3'
    }

    stages {
        stage('Récupération du code source') {
            steps {
                // This step retrieves the code from the Git repository configured in the Job
                checkout scm
            }
        }

        stage('Nettoyage du projet') {
            steps {
                echo 'Cleaning the project...'
                sh 'mvn clean'
            }
        }

        stage('Compilation du projet') {
            steps {
                echo 'Compiling the project...'
                sh 'mvn compile'
            }
        }

        stage('Analyse SonarQube') {
            steps {
                echo 'Running SonarQube analysis...'
                // 'sonar-server' must be configured in Jenkins (Manage Jenkins > System > SonarQube servers)
                // SonarQube token should be handled via credentials or within withSonarQubeEnv
                withSonarQubeEnv('sq1') {
                    sh 'mvn sonar:sonar'
                }
            }
        }

        stage('Génération du fichier JAR') {
            steps {
                echo 'Packaging the application...'
                // Skip tests for faster packaging
                sh 'mvn package -DskipTests'
            }
        }

        stage('Building Docker Image') {
            steps {
                script {
                    echo 'Building Docker image...'
                    // Replace 'azizbf' with your Docker Hub username
                    sh 'docker build -t BenHajDahmenAhmed/tp-projet-2025:latest .'
                }
            }
        }

        stage('Pushing to Docker Hub') {
            steps {
                script {
                    // 'docker-hub-creds' must be configured in Jenkins as "Username with password"
                    withCredentials([usernamePassword(credentialsId: 'docker-hub-creds', passwordVariable: 'DOCKER_HUB_PASSWORD', usernameVariable: 'DOCKER_HUB_USERNAME')]) {
                        sh "echo $DOCKER_HUB_PASSWORD | docker login -u $DOCKER_HUB_USERNAME --password-stdin"
                        sh "docker push $DOCKER_HUB_USERNAME/tp-projet-2025:latest"
                    }
                }
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully!'
            // Archive the generated JAR artifact
            archiveArtifacts artifacts: 'target/*.jar', allowEmptyArchive: true
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}