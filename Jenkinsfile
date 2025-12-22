pipeline {
    agent any

    tools {
            maven 'Maven-3.6.3'
    }

    stages {
        stage('Récupération du code source') {
            steps {
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
                withSonarQubeEnv('sq1') {
                    sh 'mvn sonar:sonar'
                }
            }
        }

        stage('Génération du fichier JAR') {
            steps {
                echo 'Packaging the application...'
                sh 'mvn package -DskipTests'
            }
        }

        stage('Building Docker Image') {
            steps {
                script {
                    echo 'Building Docker image...'
                    sh 'docker build -t benhajdahmenahmed/tp-projet-2025:latest .'
                }
            }
        }

        stage('Pushing to Docker Hub') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', passwordVariable: 'DOCKER_HUB_PASSWORD', usernameVariable: 'DOCKER_HUB_USERNAME')]) {
                        sh "echo \$DOCKER_HUB_PASSWORD | docker login -u \$DOCKER_HUB_USERNAME --password-stdin"
                        retry(3) {
                            sh "docker push benhajdahmenahmed/tp-projet-2025:latest"
                        }
                    }
                }
            }
        }



        stage('Kubernetes Deploy') {
            steps {
                script {
                    echo 'Deploying to Kubernetes...'

                    // Create namespace if it doesn't exist
                    sh 'kubectl create namespace devops --dry-run=client -o yaml | kubectl apply -f -'

                    // Apply Kubernetes manifests
                    sh 'kubectl apply -f k8s/mysql-k8s.yaml'
                    sh 'kubectl apply -f k8s/spring-app-k8s.yaml'

                    echo 'Waiting for deployments to be ready...'
                    sh 'kubectl rollout status deployment/mysql -n devops --timeout=10m'
                    sh 'kubectl rollout status deployment/spring-app -n devops --timeout=10m'

                    echo 'Deployment successful! Verifying status...'
                    sh 'kubectl get pods -n devops'
                    sh 'kubectl get svc -n devops'
                }
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully!'
            archiveArtifacts artifacts: 'target/*.jar', allowEmptyArchive: true
        }
        failure {
            echo 'Pipeline failed!'
        }
        always {
            echo 'Cleaning up Docker images...'
            sh "docker rmi ${DOCKER_IMAGE}:${BUILD_NUMBER} || true"
        }
    }
}