FROM maven:3.9.9-eclipse-temurin-17 AS build
WORKDIR /app
# Copy the zipped monorepo archive into the container
COPY codex-syntaxify-main.zip .
# Install unzip and extract the project
RUN apt-get update && apt-get install -y unzip \
 && unzip -o codex-syntaxify-main.zip \
 && rm codex-syntaxify-main.zip
# Move into the backend folder and build the Spring Boot application, skipping tests
WORKDIR /app/codex-syntaxify-main/codex-syntaxify-main/backend
RUN mvn -ntp clean package -DskipTests

FROM eclipse-temurin:17-jre
WORKDIR /app
# Copy the built JAR from the build stage
COPY --from=build /app/codex-syntaxify-main/codex-syntaxify-main/backend/target/*.jar app.jar

# Provide default environment variables to avoid startup failures when secrets
# are not configured at runtime. These can be overridden by Render's environment
# settings or via docker run -e. A placeholder API key ensures that the
# application does not crash on startup due to a missing OPENAI_API_KEY. You
# should set a real key in Render's dashboard for production use.
ENV OPENAI_API_KEY=dummy \
    OPENAI_MODEL=gpt-4o-mini \
    ALLOWED_ORIGINS=https://syntaxify-frontend.onrender.com
EXPOSE 10000
# Run the JAR, binding to the PORT environment variable if provided (Render sets PORT)
CMD ["sh", "-c", "java -Dserver.port=${PORT:-10000} -jar app.jar"]