FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY target/App.class .
ENTRYPOINT ["java", "App"]
