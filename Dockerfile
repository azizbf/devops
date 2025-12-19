# Use a Java 17 base image
FROM eclipse-temurin:17-jdk-alpine

# Set working directory
WORKDIR /app

# Copy your built JAR into the container
COPY target/TP-Projet-2025-0.0.1-SNAPSHOT.jar app.jar

# Expose the port yo    gur app runs on (Spring Boot default 8080)
EXPOSE 8080

# Run the app
ENTRYPOINT ["java", "-jar", "app.jar"]
