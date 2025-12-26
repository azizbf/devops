pipeline {
    agent any

    tools {
        maven 'M2_HOME'
    }

    environment {
        DOCKER_IMAGE = 'benhajdahmenahmed/tp-projet-2025'
        DOCKER_TAG = 'latest'
        K8S_NAMESPACE = 'devops'
        EMAIL_RECIPIENTS = 'mrbhda@gmail.com, ahmed.benhajdahmen@esprit.tn, mrbda0@gmail.com'
    }

    stages {
        stage('Checkout') {
            steps {
                echo '📥 Fetching source code...'
                checkout scm
            }
        }

        stage('Build') {
            steps {
                echo '🔨 Cleaning and compiling...'
                sh 'mvn clean compile'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                echo '🔍 Running code quality analysis...'
                withSonarQubeEnv('sonarqube') {
                    sh 'mvn sonar:sonar'
                }
            }
        }

        stage('Génération du fichier JAR') {
            steps {
                echo '📦 Packaging application...'
                sh 'mvn package -DskipTests'
            }
        }

        stage('Docker Build & Push') {
            steps {
                script {
                    echo '🐳 Building and pushing Docker image...'

                    // Build image
                    sh "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} ."

                    // Push to Docker Hub
                    withCredentials([usernamePassword(
                        credentialsId: 'dockerhub-credentials',
                        passwordVariable: 'DOCKER_PASSWORD',
                        usernameVariable: 'DOCKER_USERNAME'
                    )]) {
                        sh """
                            echo \$DOCKER_PASSWORD | docker login -u \$DOCKER_USERNAME --password-stdin
                            docker push ${DOCKER_IMAGE}:${DOCKER_TAG}
                        """
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    echo '☸️ Deploying to Kubernetes...'

                    // Create namespace
                    sh "kubectl create namespace ${K8S_NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -"

                    // Deploy applications
                    sh """
                        kubectl apply -f k8s/mysql-k8s.yaml
                        kubectl apply -f k8s/spring-app-k8s.yaml
                    """

                    // Wait for deployments
                    echo '⏳ Waiting for deployments...'
                    sh """
                        kubectl rollout status deployment/mysql -n ${K8S_NAMESPACE} --timeout=10m
                        kubectl rollout status deployment/spring-app -n ${K8S_NAMESPACE} --timeout=10m
                    """

                    // Verify deployment
                    echo '✅ Verifying deployment status...'
                    sh """
                        kubectl get pods -n ${K8S_NAMESPACE}
                        kubectl get svc -n ${K8S_NAMESPACE}
                    """
                }
            }
        }
    }

    post {
        success {
            echo '✅ Pipeline completed successfully!'
            script {
                def recipients = env.EMAIL_RECIPIENTS.split(',').collect { it.trim() }
                recipients.each { recipient ->
                    emailext(
                        subject: "✅ Jenkins Build SUCCESS: ${env.JOB_NAME} - Build #${env.BUILD_NUMBER}",
                        body: """
                            <h2 style="color: green;">Build Successful! 🎉</h2>
                            <p><strong>Job:</strong> ${env.JOB_NAME}</p>
                            <p><strong>Build Number:</strong> ${env.BUILD_NUMBER}</p>
                            <p><strong>Build URL:</strong> <a href="${env.BUILD_URL}">${env.BUILD_URL}</a></p>
                            <p><strong>Duration:</strong> ${currentBuild.durationString}</p>
                            <hr>
                            <h3>Deployed Components:</h3>
                            <ul>
                                <li>Docker Image: ${DOCKER_IMAGE}:${DOCKER_TAG}</li>
                                <li>Kubernetes Namespace: ${K8S_NAMESPACE}</li>
                            </ul>
                            <p>Check the <a href="${env.BUILD_URL}console">console output</a> for details.</p>
                        """,
                        to: recipient,
                        mimeType: 'text/html'
                    )
                }
            }
        }

        failure {
            echo '❌ Pipeline failed!'
            script {
                def recipients = env.EMAIL_RECIPIENTS.split(',').collect { it.trim() }
                recipients.each { recipient ->
                    emailext(
                        subject: "❌ Jenkins Build FAILED: ${env.JOB_NAME} - Build #${env.BUILD_NUMBER}",
                        body: """
                            <h2 style="color: red;">Build Failed! ⚠️</h2>
                            <p><strong>Job:</strong> ${env.JOB_NAME}</p>
                            <p><strong>Build Number:</strong> ${env.BUILD_NUMBER}</p>
                            <p><strong>Build URL:</strong> <a href="${env.BUILD_URL}">${env.BUILD_URL}</a></p>
                            <p><strong>Duration:</strong> ${currentBuild.durationString}</p>
                            <hr>
                            <h3>Failed Stage:</h3>
                            <p>Check the <a href="${env.BUILD_URL}console">console output</a> for error details.</p>
                            <p style="color: red;"><strong>Action Required:</strong> Please investigate and fix the issues.</p>
                        """,
                        to: recipient,
                        mimeType: 'text/html'
                    )
                }
            }
        }

        always {
            // Clean up workspace if needed
            cleanWs(cleanWhenNotBuilt: false,
                    deleteDirs: true,
                    disableDeferredWipeout: true,
                    notFailBuild: true)
        }
    }
}